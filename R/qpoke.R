#' Keep queuing system nodes warm/available
#'
#' Submits trivial, short-lived jobs (`sleep 1`) to the queuing system via
#' \code{qsub} in order to keep nodes available/active in the queue. This
#' avoids the common delay (often 5-10 minutes) of waiting for a new node to
#' spin up when submitting a "real" job after a period of queue inactivity.
#' Jobs are submitted in bursts, repeated at a fixed interval, and the whole
#' process is launched in the background (fully detached using `setsid`) so
#' \code{qpoke} returns immediately. Each batch tops up the total number of
#' jobs in the queue (any job, not just `qpoke` jobs) to `n`, submitting
#' only as many new `qpoke` jobs as needed to reach that target.
#'
#' @param n Target total number of jobs (of any kind, not just `qpoke`
#' jobs) to maintain in the queue. Each batch submits enough new `qpoke`
#' jobs to bring the total queue size up to `n`. If the queue already has
#' `n` or more jobs, no new jobs are submitted in that batch.
#' @param dur Total duration (in minutes) to keep poking the queue. If
#' provided (not `NULL`), this overrides `nrep` by calculating
#' `nrep <- dur/nsecs*60`.
#' @param nrep Number of times to repeat the batch of `n` submissions, with
#' `nsecs` seconds between each batch. Ignored if `dur` is provided.
#' @param nsecs Number of seconds to wait between repeated batches.
#'
#' @details Only linux systems are supported. On other systems, `qpoke`
#' prints a message and returns \code{invisible(NULL)} without doing
#' anything.
#'
#' @return Nothing. Called for its side effect of submitting jobs to the
#' queuing system via a background bash script.
#' @examples
#' \dontrun{
#' ## Submit 1 dummy job to wake up a node
#' qpoke()
#'
#' ## Keep one note awake for one hour. One job will be submitted every 60 seconds.
#' qpoke(dur=60)
#'
#' ## Submit 5 dummy jobs every 30 seconds, repeated 10 times
#' qpoke(n=5,nrep=10,nsecs=30)
#'
#' ## Keep poking the queue for 30 minutes, every 60 seconds
#' qpoke(n=5,dur=30,nsecs=60)
#' }
#' @export
qpoke <- function(n=1,dur,nrep=1,nsecs=10){

  ## dur is in minutes
  if(!missing(dur)&&!is.null(dur)) nrep <- dur/nsecs*60

  systype <- getSystemType()
  if(systype!="linux") {
    message("qpoke only supports linux. Exiting.")
    return(invisible(NULL))
  }
  
  nsecs.sleep <- nsecs+10

  ## submit enough qpoke jobs to bring the total queue size up to n;
  ## does nothing if the queue already has n or more jobs
  cmd.batch <- c(
    "NQ=$(qstat | tail -n +3 | wc -l)",
    sprintf("NADD=$((%d - NQ))",n),
    "if [ \"$NADD\" -gt 0 ]; then",
    "for I in $(seq 1 $NADD); do",
    sprintf("echo \"sleep %d\" | qsub -N qpoke${J:-0}_$I -o /dev/null -e /dev/null > /dev/null 2>&1",nsecs.sleep),
    "done",
    "fi"
  )

  cmd <- cmd.batch

  if(nrep>1) {
    cmd <- c(sprintf("for J in $(seq 1 %d); do",nrep),
             cmd.batch,
             sprintf("sleep %d",nsecs),
             "done"
             )
  }


  lines.script <- c("#!/bin/bash","",cmd)



  ## write to bash script
  file.script <- tempfile(fileext=".sh")
  writeTextFile(lines.script,file.script)

  ## message(file.script)

  ## execute bash script, naming the process "qpoke" (visible in ps/top)
  ## system(sprintf("exec -a qpoke bash %s > /dev/null 2>&1 &",file.script))
  ## system(sprintf("bash -c 'exec -a qpoke bash %s > /dev/null 2>&1 &'",file.script))
  system(sprintf("setsid bash -c 'exec -a qpoke bash %s > /dev/null 2>&1 &' < /dev/null &",file.script))

}
