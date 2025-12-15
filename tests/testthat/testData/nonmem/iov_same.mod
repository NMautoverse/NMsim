
$PROBLEM BOV SAME non-working model


$INPUT
RECSEQ EXCLF ID NTIME TIME TAPD EVID CMT AMT RATE DV MDV OCC BLQFN LLOQ

$DATA doesNotExist.csv

IGNORE	= @

$SUB ADVAN4 TRANS4

$PK

MEDWTBL	= 77
TVCL	= THETA(1)*(WTBL/MEDWTBL)**0.75
CL	= TVCL*EXP(ETA(1))

TVV2	= THETA(2)*V2COV*(WTBL/MEDWTBL)
V2	= TVV2*EXP(ETA(2))

TVQ3	= THETA(3)*(WTBL/MEDWTBL)**0.75
Q3	= TVQ3*EXP(ETA(3))

TVV3	= THETA(4)*(WTBL/MEDWTBL)
V3	= TVV3*EXP(ETA(4))

TVQ4	= THETA(5)*(WTBL/MEDWTBL)**0.75
Q4	= TVQ4*EXP(ETA(5))

TVV4	= THETA(6)*(WTBL/MEDWTBL)
V4	= TVV4*EXP(ETA(6))

TVKA	= THETA(7)*KACOV
IIVKA	= ETA(7)
IOVKA	= 0
IF (OCC==1) THEN
  IOVKA	= ETA(8)
ENDIF
IF (OCC==2) THEN
  IOVKA	= ETA(9)
ENDIF
IF (OCC==3) THEN
  IOVKA	= ETA(10)
ENDIF
IIKA	= IIVKA+IOVKA
KA 	= TVKA*EXP(IIKA)

TVD1	= THETA(8)*D1COV
IIVD1	= ETA(11)
IOVD1	= 0
IF (OCC==1) THEN
  IOVD1	= ETA(12)
ENDIF
IF (OCC==2) THEN
  IOVD1	= ETA(13)
ENDIF
IF (OCC==3) THEN
  IOVD1	= ETA(14)
ENDIF
IID1	= IIVD1+IOVD1
D1	= TVD1*EXP(IID1)

TVF	= THETA(9)
TVF1	= LOG(TVF/(1-TVF)) + F1COV
F1	= EXP(TVF1)/(1+EXP(TVF1))

S2	= V2

$ERROR
IPRED	= F
IRES	= DV-IPRED
W	= SQRT(SIGMA(1,1)*IPRED**2)
DEL	= 0
IF (W.EQ.0) DEL=1
IWRES	= IRES/(W+DEL)
Y	= IPRED + IPRED*EPS(1)

; param labels listed in $THETA/$OMEGA:
; init		; symbol	; trans		; num	; panel		; label					; unit
$THETA
(0, 4.4)	; CL		; none		; 1	; struct	; Clearance				; L/h	
(0, 10)		; V2		; none		; 2	; struct	; Central volume			; L
(0, 300)	; Q3		; none		; 3	; struct	; Intercompartment transport 23		; L/h	
(0, 50)		; V3		; none		; 4	; struct	; Peripheral volume 2			; L
(0, 15)		; Q4		; none		; 5	; struct	; Intercompartment trasnport 24		; L/h	
(0, 60)		; V4		; none		; 6	; struct	; Peripheral volume 3			; L
(0, 1)		; KA		; none  	; 7	; struct	; Absorption rate	  		; 1/h
(0, 0.4)	; D1		; none  	; 8	; struct	; Zero-order entry into depot	  	; h
(0, 0.9, 1)	; F1		; logit  	; 9	; struct	; Bioavailability			; -
(-1, -0.69)	; FED on KA	; none		; 10	; covs		; Effect of food on KA			; -
(1.3)		; FED on F1	; logit		; 11	; covs		; Effect of food on F1			; -
(-0.3)		; DOSE on KA	; none		; 12	; covs		; Effect of dose on KA			; -
(0.9)		; FED on D1	; none		; 13	; covs		; Effect of food on D1			; -
(-0.7)		; FORM on F1	; logit		; 14	; covs		; Effect of formulation on F1		; -
(-1, 0.9)	; FORM on D1	; none  	; 15	; covs		; Effect of formulation on D1		; -
(-1, 1.2)	; SEX on V2	; none  	; 16	; covs		; V2 of males				; -
(-1, -0.5)	; FORM on KA	; none  	; 17	; covs		; KA of tablet fasted			; -
(-1, -0.2)	; FORM on KA	; none  	; 18	; covs		; KA of tablet fed	 		; -

$OMEGA
0.05		; IIV.CL	; lognormal 	; 1	; IIV		; Between-subject variability on CL 	; -
0.2		; IIV.V2	; lognormal 	; 2	; IIV		; Between-subject variability on V2 	; -
0.7		; IIV.Q3	; lognormal 	; 3	; IIV		; Between-subject variability on Q3 	; -
0.05		; IIV.V3	; lognormal 	; 4	; IIV		; Between-subject variability on V3 	; -
0.05		; IIV.Q4	; lognormal 	; 5	; IIV		; Between-subject variability on Q4 	; -
0.05		; IIV.V4	; lognormal 	; 6	; IIV		; Between-subject variability on V4 	; -
0.15		; IIV.KA	; lognormal 	; 7	; IIV		; Between-subject variability on KA 	; -
$OMEGA BLOCK(1)
0.15		; IOV1.KA	; lognormal 	; 8	; IOV		; Between-occasion variability on KA 	; -
$OMEGA BLOCK(1) SAME ; IOV2.KA	; lognormal 	; 9	; IOV		; Between-occasion variability on KA 	; -
$OMEGA BLOCK(1) SAME ; IOV3.KA	; lognormal 	; 10	; IOV		; Between-occasion variability on KA 	; -
$OMEGA BLOCK(1)
0.2		; IIV.D1	; lognormal 	; 11	; IIV		; Between-subject variability on D1 	; -
$OMEGA BLOCK(1)
0.3		; IOV1.D1	; lognormal 	; 12	; IOV		; Between-occasion variability on D1 	; -
$OMEGA BLOCK(1) SAME ; IOV2.D1	; lognormal 	; 13	; IOV		; Between-occasion variability on D1 	; -
$OMEGA BLOCK(1) SAME ; IOV3.D1	; lognormal 	; 14	; IOV		; Between-occasion variability on D1 	; -

$SIGMA
0.02		; PROP		; none		; 2	; RV		; Proportional error (Var)		; -

$ESTIMATION METHOD=1 INTER MAXEVALS=9999 NOABORT PRINT=5 POSTHOC
$COVARIANCE PRINT=E MATRIX=S
$TABLE RECSEQ EXCLF ID NTIME TIME TAD PRED IPRED
