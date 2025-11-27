# Test if file modification times indicate that Nonmem models should be re-run

Test if file modification times indicate that Nonmem models should be
re-run

## Usage

``` r
checkTimes(
  file,
  use.input = TRUE,
  nminfo.input = NULL,
  file.mod,
  tz.lst = NULL,
  use.tmp = TRUE
)
```

## Arguments

- file:

  Path to Nonmem-created file. Typically an output control stream.

- use.input:

  Scan input data for updates too? Default is TRUE.

- nminfo.input:

  If you do want to take into account input data but avoid re-reading
  the information, you can pass the NMdata meta data object.

- file.mod:

  The input control stream

- tz.lst:

  If files are moved around on or between file systems, the file
  modification time may not be reflective of the Nonmem runtime. In that
  case, you can choose to extract the time stamp from the output control
  stream. The issue is that Nonmem does not write the time zone, so you
  have to pass that to checkTimes if this is wanted.
