; model from: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7894400/
$PROBLEM lorlatinib 2-cmt analytical w/ autoinduction


$INPUT  REC ID TIME EVID CMT AMT II ADDL RATE DV MDV BALB BWT 
        DOSCUMA DOSCUMN PDOSAMT PPI ROUT SD TAPD TDOSE TPDOS WNCL


$DATA ../derived_data/simulated_nonmem_dataset_mod_lorlatinib.csv IGNORE=@
$SUBROUTINE ADVAN4 TRANS4
$PK

;covariates
; typical: BWT=70; PPI=0; WNCL=100; BALB=4; TDOSE=100; PPI=0
IF(PPI.EQ.0) KAPPI = 1  ; Most common
IF(PPI.EQ.1) KAPPI = ( 1 + THETA(15))
KACOV=KAPPI
CLWNCL = ((WNCL/100.00)**THETA(14))
CLTDOSE = ( 1 + THETA(13)*(TDOSE - 100.00))
CLBALB = ( 1 + THETA(12)*(BALB - 4.00))
CLCOV=CLBALB*CLTDOSE*CLWNCL

; model

TVCLI = THETA(1) * ((BWT / 70) ** 0.75)
TVV2 = THETA(2) * (BWT / 70)

TVKA = THETA(3)
TVKA = KACOV * TVKA

TVQ = THETA(4)
TVV3 = THETA(5)
TVIN = THETA(6)
TVD1 = THETA(7)
TVF1 = THETA(8)
TVCLMX = THETA(9) * ((BWT / 70) ** 0.75)


V2 =  TVV2 * EXP(ETA(3))
KA = EXP(TVKA + ETA(5))
Q = TVQ
V3 = TVV3 * EXP(ETA(4))
IND = TVIN
D1 = TVD1
F1 = TVF1 * EXP(ETA(2))
TVCL = TVCLI
IF(SD.NE.1) TVCL = TVCLMX * (1 - EXP(-IND * (TIME+0.0001)))

TVCL = CLCOV * TVCL
CL = TVCL * EXP(ETA(1))

S2 = V2 / 1000

$ERROR 
IPRD=F
IF(IPRD.LE.0)IPRD=0.0001
IPRED=LOG(IPRD)
IRES=DV-IPRED

IF(ROUT.EQ.28) THEN
W= SQRT(THETA(10)**2)
ELSE
W= SQRT(THETA(11)**2)
ENDIF

IWRES=IRES/W
Y = IPRED+W*ERR(1)


$THETA  
 (0,9.035) ; CLI
 (0,120.511) ; V2
 (1.13) ; KA
 (0,22.002) ; Q
 (0,154.905) ; V3
 (0,0.020) ; IND
 (0,1.148) ; D1
 (0,0.759,1) ; F1
 (14.472) ; CLMX
 (0.11) ; prop error for IV
 (0.438) ; prop error for PO
 (0.067) ; CLBALB1
 (0.00138 FIX) ; CLTDOSE1 ;  TDOSE, total daily lorlatinib dose
 (0.235) ; CLWNCL1  ;WNCL, baseline standardized creatinine clearance
 (-0.2) ; KAPPI1
$OMEGA  BLOCK(2)
 0.030  ; CL
 0.005 0.022  ; F1
$OMEGA  BLOCK(2)
 0.086 ;V2
 0.01 0.101  ; V3
$OMEGA  2.32  ; KA
$SIGMA  1  FIX

;$SIMULATION (123456) ONLY

;$ESTIMATION METHOD=COND INTER MAXEVAL=9999 NOABORT NSIG=2 SIGL=6
;                PRINT=5 POSTHOC
                
$ESTIMATION METHOD=SAEM INTERACTION AUTO=1 NBURN=500 NITER=250
            SEED=231023 PRINT=5 RANMETHOD=P  

$ESTIMATION METHOD=IMP INTERACTION AUTO=1 EONLY=1 NITER=20 SEED=231023
            PRINT=1 RANMETHOD=P

$COVARIANCE COMPRESS PRINT=E UNCONDITIONAL
$TABLE  ID TIME CMT ROUT BWT WNCL PPI BALB TDOSE
        CL TVCLI TVCLMX V2 KA Q V3 D1 F1 IND TIME
        ETA1 ETA2 ETA3 ETA4 ETA5 
        ONEHEADER NOPRINT  FILE=mod_lorlatinib_estimate.ext