C
      SUBROUTINE ADV5AR(IN)
C **********************************************************************
C THIS SUBROUTINE ALLOCATES SPACE FOR ARRAYS NEEDED BY THE ADVECTION
C (ADV) PACKAGE.
C **********************************************************************
C last modified: 02-20-2010
C
      USE MT3DMS_MODULE, ONLY: IOUT,NCOL,NROW,NLAY,MCOMP,MIXELM,MXPART,
     &                         PERCEL,INADV,
     &                         NADVFD,ITRACK,ISEED,NPLANE,NPL,NPH,NPMIN,
     &                         NPMAX,INTERP,NLSINK,NPSINK,WD,DCEPS,
     &                         SRMULT,DCHMOC,NCOUNT,NPCHEK,INDEXX,
     &                         INDEXY,INDEXZ,XP,YP,ZP,CNPT,
     &                         IALTFM,NOCREWET                 !# LINE 4 ADV
      USE MIN_SAT, ONLY: DOMINSAT,DRYON                        !# LINE 11 ADV
C
      IMPLICIT  NONE
      INTEGER   IN,INDEX,IERR
C
      INADV=IN
C
C--ALLOCATE
      ALLOCATE(NADVFD,ITRACK,ISEED,NPLANE,NPL,NPH,NPMIN,NPMAX,INTERP,
     &         NLSINK,NPSINK,WD,DCEPS,SRMULT,DCHMOC)
C
C--PRINT PACKAGE NAME AND VERSION NUMBER
      WRITE(IOUT,7) INADV
    7 FORMAT(1X,'ADV5 -- ADVECTION PACKAGE,',
     & ' VERSION 5, FEBRUARY 2010, INPUT READ FROM UNIT',I3)
C
C--READ ADVECTION SOLUTION OPTION AND MAXIMUM PARTICLES ALLOWED
      MIXELM=0
      PERCEL=0
      MXPART=0
      NADVFD=0
      IALTFM=0                                                 !# LINE 29 ADV
      NOCREWET=0                                               !# LINE 30 ADV
      READ(INADV,'(I10,F10.0,4I10)',ERR=10,IOSTAT=IERR)        !# Amended
     & MIXELM,PERCEL,MXPART,NADVFD,IALTFM,NOCREWET             !# Amended
   10 IF(IERR.NE.0) THEN
        REWIND(INADV)
        READ(INADV,'(I10,F10.0,I10)')
     &   MIXELM,PERCEL,MXPART
      ENDIF       
      IF(MIXELM.EQ.0 .AND. NADVFD.NE.1.AND.NADVFD.NE.2) NADVFD=1
      IF(MIXELM.GT.0) NADVFD=1
C
C--ECHO AND CHECK POTENTIAL INPUT ERRORS
C
      IF(MIXELM.EQ.1) WRITE(IOUT,2000)
      IF(MIXELM.EQ.2) WRITE(IOUT,2002)
      IF(MIXELM.EQ.3) WRITE(IOUT,2004)
      IF(MIXELM.EQ.0.AND.NADVFD.EQ.1) WRITE(IOUT,2006)
      IF(MIXELM.EQ.0.AND.NADVFD.EQ.2) WRITE(IOUT,3007)
      IF(IALTFM.EQ.1) WRITE(IOUT,1054)                         !# LINE 48 ADV
      IF(NOCREWET.EQ.1) WRITE(IOUT,1056)                       !# LINE 49 ADV
      IF(MIXELM.EQ.-1) WRITE(IOUT,2007)
      IF(MIXELM.LT.-1.OR.MIXELM.GT.3) THEN
        WRITE(*,2008) MIXELM
        CALL USTOP(' ')
      ENDIF
C
      WRITE(IOUT,2038) PERCEL
      IF(PERCEL.LE.1.E-5) THEN
        WRITE(*,1040)
        CALL USTOP(' ')
      ENDIF
      IF(MIXELM.LT.0.AND.PERCEL.GT.1.0) THEN
        WRITE(*,2043)
        PERCEL=1.0
      ENDIF
C
      IF(MIXELM.EQ.1.OR.MIXELM.EQ.3) THEN
        WRITE(IOUT,2050) MXPART
        IF(MXPART.LE.0) THEN
          WRITE(*,2052)
          CALL USTOP(' ')
        ENDIF
      ENDIF
C
 2000 FORMAT(1X,'ADVECTION IS SOLVED WITH THE [MOC] SCHEME')
 2002 FORMAT(1X,'ADVECTION IS SOLVED WITH THE [MMOC] SCHEME')
 2004 FORMAT(1X,'ADVECTION IS SOLVED WITH',
     & ' THE HYBRID [MOC]/[MMOC] SCHEME')
 2006 FORMAT(1X,'ADVECTION IS SOLVED WITH',
     & ' THE UPSTREAM FINITE DIFFERENCE SCHEME')
 3007 FORMAT(1X,'ADVECTION IS SOLVED WITH',
     & ' THE CENTRAL FINITE DIFFERENCE SCHEME')
 2007 FORMAT(1X,'ADVECTION IS SOLVED WITH',
     & ' THE ULTIMATE SCHEME')
 2008 FORMAT(/1X,'ERROR: INPUT VALUE FOR [MIXELM] =',I3,
     & /1X,'ENTER A VALUE BETWEEN -1 AND 3')
 2038 FORMAT(1X,'COURANT NUMBER ALLOWED IN SOLVING',
     & ' THE ADVECTION TERM =',G10.3)
 2040 FORMAT(/1X,'ERROR: COURANT NUMBER [PERCEL] MUST BE >0.',
     & /1X,'ENTER A VALID VALUE OF [PERCEL] IN ADVECTION INPUT FILE.')
 2043 FORMAT(/1X,'WARNING: COURANT NUMBER [PERCEL] MUST NOT EXCEED 1.0',
     &/1X,'FOR THE 3RD-ORDER ULTIMATE SCHEME; RESET TO DEFAULT OF 1.0.')
 2050 FORMAT(1X,'MAXIMUM NUMBER OF MOVING PARTICLES ALLOWED =',I8)
 2052 FORMAT(/1X,'ERROR: MAXIMUM NUMBER OF PARTICLES MUST BE >0 ',
     & ' FOR MOC/HMOC SOLUTION OPTION',
     & /1X,'ENTER A VALID VALUE FOR [MXPART] IN ADVECTION INPUT FILE')
1054  FORMAT(1X,'ALTERNATE FORMULATION IS USED')                      !# LINE 96 ADV
1056  FORMAT(1X,'FUNCTION CREWET IS DEACTIVATED: ZERO CONCENTRATION', !# LINE 97 ADV
     1       ' ASSIGNED TO REWET CELLS')                              !# LINE 98 ADV
C                                                                     !# LINE 99 ADV
C-----MST AND DRY OPTIONS ONLY AVAILABLE WITH FINITE-DIFFERENCE OPTION (MIXELM=0) !# LINE 100 ADV
      IF(DOMINSAT.OR.DRYON) THEN                                      !# LINE 101 ADV
        IF(MIXELM.GT.0) THEN                                          !# LINE 102 ADV
          WRITE(IOUT,'(2A)')                                          !# LINE 103 ADV
     &    '*** MST AND DRY OPTIONS AVAILABLE ONLY WHEN (MIXELM<=0)'   !# LINE 104 ADV
          WRITE(*,'(2A)')                                             !# LINE 105 ADV
     &    '*** MST AND DRY OPTIONS AVAILABLE ONLY WHEN (MIXELM<=0)'   !# LINE 106 ADV
          STOP                                                        !# LINE 107 ADV
        ENDIF                                                         !# LINE 108 ADV
      ENDIF                                                           !# LINE 109 ADV
C                                                                     !# LINE 110 ADV
C
C--ALLOCATE AND INITIALIZE
C--INTEGER ARRAYS
      ALLOCATE(NCOUNT(MCOMP))
      IF(MIXELM.GT.0) THEN
        ALLOCATE(NPCHEK(NCOL,NROW,NLAY,MCOMP))
      ELSE
        ALLOCATE(NPCHEK(1,1,1,1))
      ENDIF
      IF(NCOL.GT.1.AND.MIXELM.GT.0) THEN
        ALLOCATE(INDEXX(MXPART,MCOMP))
      ELSE
        ALLOCATE(INDEXX(1,1))
      ENDIF
      
      IF(NROW.GT.1.AND.MIXELM.GT.0) THEN
        ALLOCATE(INDEXY(MXPART,MCOMP))
      ELSE
        ALLOCATE(INDEXY(1,1))
      ENDIF
      IF(NLAY.GT.1.AND.MIXELM.GT.0) THEN
        ALLOCATE(INDEXZ(MXPART,MCOMP))
      ELSE
        ALLOCATE(INDEXZ(1,1))
      ENDIF
C--REAL ARRAYS
      IF(NCOL.GT.1.AND.MIXELM.GT.0) THEN
        ALLOCATE(XP(MXPART,MCOMP))
      ELSE
        ALLOCATE(XP(1,1))
      ENDIF
      IF(NROW.GT.1.AND.MIXELM.GT.0) THEN
        ALLOCATE(YP(MXPART,MCOMP))
      ELSE
        ALLOCATE(YP(1,1))
      ENDIF
      IF(NLAY.GT.1.AND.MIXELM.GT.0) THEN
        ALLOCATE(ZP(MXPART,MCOMP))
      ELSE
        ALLOCATE(ZP(1,1))
      ENDIF
      IF(MIXELM.GT.0) THEN
        ALLOCATE(CNPT(MXPART,2,MCOMP))
      ELSE
        ALLOCATE(CNPT(1,1,1))
      ENDIF
      NCOUNT=0
      NPCHEK=0
      INDEXX=0
      INDEXY=0
      INDEXZ=0
      XP=0.
      YP=0.
      ZP=0.
      CNPT=0.
C
C--READ AND PRINT SOLUTION OPTIONS
      WRITE(IOUT,1000)
 1000 FORMAT(//1X,'ADVECTION SOLUTION OPTIONS'/1X,26('-')/)
C
      IF(MIXELM.EQ.1) WRITE(IOUT,100)
      IF(MIXELM.EQ.2) WRITE(IOUT,102)
      IF(MIXELM.EQ.3) WRITE(IOUT,104)
      IF(MIXELM.EQ.0.AND.NADVFD.EQ.1) WRITE(IOUT,106)
      IF(MIXELM.EQ.0.AND.NADVFD.EQ.2) WRITE(IOUT,107)
      IF(MIXELM.EQ.-1) WRITE(IOUT,207)
      WRITE(IOUT,238) PERCEL
      IF(MIXELM.GT.0) WRITE(IOUT,250) MXPART
  100 FORMAT(1X,'ADVECTION IS SOLVED WITH THE [MOC] SCHEME')
  102 FORMAT(1X,'ADVECTION IS SOLVED WITH THE [MMOC] SCHEME')
  104 FORMAT(1X,'ADVECTION IS SOLVED WITH',
     & ' THE HYBRID [MOC]/[MMOC] SCHEME')
  106 FORMAT(1X,'ADVECTION IS SOLVED WITH',
     & ' THE UPSTREAM FINITE DIFFERENCE SCHEME')
  107 FORMAT(1X,'ADVECTION IS SOLVED WITH',
     & ' THE CENTRAL FINITE DIFFERENCE SCHEME')
  207 FORMAT(1X,'ADVECTION IS SOLVED WITH',
     & ' THE ULTIMATE SCHEME')
  238 FORMAT(1X,'COURANT NUMBER ALLOWED IN SOLVING',
     & ' THE ADVECTION TERM =',G10.3)
  250 FORMAT(1X,'MAXIMUM NUMBER OF MOVING PARTICLES ALLOWED =',I8)

      IF(MIXELM.EQ.1.OR.MIXELM.EQ.2.OR.MIXELM.EQ.3) THEN
        READ(IN,'(I10,F10.0)') ITRACK,WD
        IF(ITRACK.EQ.1) THEN
          WRITE(IOUT,1030)
        ELSEIF(ITRACK.EQ.2) THEN
          WRITE(IOUT,1032)
        ELSEIF(ITRACK.EQ.3) THEN
          WRITE(IOUT,1034)
        ELSE
          WRITE(IOUT,1036)
          ITRACK=1
        ENDIF
        WRITE(IOUT,1040) WD
        IF(WD.LT.0.5) THEN
          WRITE(IOUT,1042)
          WD=0.5
        ENDIF
      ELSE
        WD=0.
      ENDIF
 1030 FORMAT(1X,'METHOD FOR PARTICLE TRACKING IS [1ST ORDER]')
 1032 FORMAT(1X,'METHOD FOR PARTICLE TRACKING IS [4TH ORDER]')
 1034 FORMAT(1X,'METHOD FOR PARTICLE TRACKING IS [MIXED ORDER]')
 1036 FORMAT(1X,'METHOD FOR PARTICLE TRACKING IS UNDEFINED.',
     & /1X,'THE 1ST ORDER METHOD IS USED AS DEFAULT.')
 1040 FORMAT(1X,'CONCENTRATION WEIGHTING FACTOR [WD] =',F10.3)
 1042 FORMAT(1X,'ERROR: [WD] MUST BE GREATER OR EQUAL TO 0.5;',
     &      /1X,'       THE DEFAULT VALUE OF 0.5 IS USED.')
C
C--IF MIXELM=1 OR 3, READ PARTICLE CONTROL PARAMETERS
      IF(MIXELM.EQ.1.OR.MIXELM.EQ.3) THEN
        READ(IN,1045) DCEPS,NPLANE,NPL,NPH,NPMIN,NPMAX
 1045   FORMAT(F10.0,5I10)
C
C--SET [SRMULT] TO DEFAULT VALUE OF 1.
        SRMULT=1.0
C
        WRITE(IOUT,1020) DCEPS
        IF(NPLANE.GT.0) THEN
          WRITE(IOUT,1022) NPLANE
        ELSE
          WRITE(IOUT,1025)
        ENDIF
        WRITE(IOUT,1050) NPL,NPH,NPMIN,NPMAX,SRMULT
      ENDIF
 1020 FORMAT(1X,'THE CONCENTRATION GRADIENT CONSIDERED NEGLIGIBLE',
     & ' [DCEPS] =',G15.7)
 1022 FORMAT(1X,'INITIAL PARTICLES ARE PLACED ON ',I2,
     & ' VERTICAL PLANE(S) WITHIN CELL BLOCK')
 1025 FORMAT(1X,'INITIAL PARTICLES ARE PLACED RANDOMLY',
     & ' WITHIN CELL BLOCK')
 1050 FORMAT(1X,'PARTICLE NUMBER PER CELL IF DCCELL =< DCEPS =',I5,
     &      /1X,'PARTICLE NUMBER PER CELL IF DCCELL  > DCEPS =',I5,
     &      /1X,'MINIMUM PARTICLE NUMBER ALLOWD PER CELL     =',I5,
     &      /1X,'MAXIMUM PARTICLE NUMBER ALLOWD PER CELL     =',I5,
     &      /1X,'MULTIPLIER OF PARTICLE NUMBER AT SOURCE     =',G10.3)
C
C--IF MIXELM=2 OR 3, READ INTERPOLATION OPTION
      IF(MIXELM.EQ.2.OR.MIXELM.EQ.3) THEN
        READ(IN,'(3I10)') INTERP,NLSINK,NPSINK
        INTERP=1
        WRITE(IOUT,1052)
        IF(NLSINK.GT.0) THEN
          WRITE(IOUT,1058) NLSINK
        ELSE
          WRITE(IOUT,1059)
        ENDIF
        WRITE(IOUT,1060) NPSINK
      ENDIF
 1052 FORMAT(1X,'SCHEME FOR CONCENTRATION INTERPOLATION IS [LINEAR]')
 1058 FORMAT(1X,'PARTICLES FOR APPROXIMATING',
     & ' A SINK CELL IN THE [MMOC] SCHEME'/1X,'ARE PLACED ON ',I2,
     & ' VERTICAL PLANE(S) WITHIN CELL BLOCK')
 1059 FORMAT(1X,'PARTICLES FOR APPROXIMATING',
     & ' A SINK CELL IN THE [MMOC] SCHEME',
     & /1X,'ARE PLACED RANDOMLY WITHIN CELL BLOCK')
 1060 FORMAT(1X,'NUMBER OF PARTICLES USED TO APPROXIMATE A SINK CELL',
     & ' IN THE [MMOC] SCHEME =',I4)
C
C--READ IF HYBRID [MOC]/[MMOC] SCHEME IS USED
      IF(MIXELM.EQ.3) THEN
        READ(IN,'(F10.0)') DCHMOC
        WRITE(IOUT,1070) DCHMOC
      ENDIF
 1070 FORMAT(1X,'CRITICAL CONCENTRATION GRADIENT USED IN ',
     & 'THE "HMOC" SCHEME [DCHMOC] =',G11.4,
     & /1X,'THE "MOC"  SOLUTION IS USED WHEN DCCELL  > DCHMOC'
     & /1X,'THE "MMOC" SOLUTION IS USED WHEN DCCELL =< DCHMOC')
C
C--INITIALIZE PARTICLE NUMBER COUNTER [NCOUNT]
C--AND RANDOM NUMBER GENERATOR SEED [ISEED] IN CASE IT IS NEEDED
      DO INDEX=1,MCOMP
        NCOUNT(INDEX)=0
      ENDDO
      ISEED=-NCOL*NROW*NLAY
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE ADV5SV(ICOMP,DTRANS)
C **********************************************************************
C THIS SUBROUTINE CALCULATES CONCENTRATIONS AT THE INTERMEDIATE TIME
C LEVEL DUE TO ADVECTION WITH THE MIXED EULERIAN-LAGRANGIAN SCHEMES.
C ALSO INCLUDED ARE EXPLICIT UPSTREAM FINITE DIFFERENCE AND THIRD-ORDER
C TVD (ULTIMATE) SCHEMES.
C **********************************************************************
C last modified: 02-15-2005
C
      USE MT3DMS_MODULE, ONLY: IOUT,NCOL,NROW,NLAY,MCOMP,MIXELM,
     &                         MXPART,NCOUNT,NPINS,NRC,NPCHEK,XP,YP,ZP,
     &                         INDEXX,INDEXY,INDEXZ,CNPT,ICBUND,DELR,
     &                         DELC,DZ,XBC,YBC,ZBC,DH,PRSITY,QX,QY,QZ,
     &                         RETA,COLD,CWGT,CNEW,CADV,BUFF,
     &                         IMPSOL,NADVFD,RMASIO,
     &                         NPL,NPH,WD,
     &                         SATOLD,PRSITYSAV,FUZF                !edm
C
      IMPLICIT  NONE
      INTEGER   ICOMP,J,I,K
      REAL      SADV5Q,QCTMP,DTRANS,
     &          PRSYTMP                                             !edm
      DIMENSION PRSYTMP(NCOL,NROW,NLAY)                             !edm
C
C--IF FINITE DIFFERENCE OR ULTIMATE OPTION IS USED
      IF(MIXELM.EQ.0) THEN
        CALL SADV5F(NCOL,NROW,NLAY,ICBUND(:,:,:,ICOMP),DELR,DELC,DH,
     &   PRSITY,CNEW(:,:,:,ICOMP),COLD(:,:,:,ICOMP),QX,QY,QZ,
     &   RETA(:,:,:,ICOMP),DTRANS,RMASIO(:,:,ICOMP))
      ELSEIF(MIXELM.EQ.-1) THEN
        IF(.NOT.FUZF) THEN                                          !edm
        CALL SADV5U(NCOL,NROW,NLAY,ICBUND(:,:,:,ICOMP),DELR,DELC,DH,
     &   PRSITY,CNEW(:,:,:,ICOMP),COLD(:,:,:,ICOMP),CADV(:,:,:,ICOMP),
     &   BUFF,QX,QY,QZ,RETA(:,:,:,ICOMP),DTRANS,
     &   RMASIO(:,:,ICOMP))
        ELSE                                                        !edm
          DO K=1,NLAY                                               !edm
            DO I=1,NROW                                             !edm
              DO J=1,NCOL                                           !edm
                PRSYTMP(J,I,K)=SATOLD(J,I,K)*PRSITYSAV(J,I,K)       !edm
              ENDDO                                                 !edm
            ENDDO                                                   !edm
          ENDDO                                                     !edm
          CALL SADV5U(NCOL,NROW,NLAY,ICBUND(:,:,:,ICOMP),DELR,DELC,DH,
     &    PRSYTMP,CNEW(:,:,:,ICOMP),COLD(:,:,:,ICOMP),CADV(:,:,:,ICOMP),
     &    BUFF,QX,QY,QZ,RETA(:,:,:,ICOMP),DTRANS,
     &    RMASIO(:,:,ICOMP))
        ENDIF                                                       !edm
      ENDIF
C
C--IF [MOC] OR [HMOC] IS USED
      IF(MIXELM.EQ.1 .OR. MIXELM.EQ.3) THEN
C
C--CALCULATE RELATIVE CELL CONCENTRATION GRADIENTS IF NEEDED
C--AND STORE THEM IN BUFFER ARRAY [BUFF]
        IF(MIXELM.EQ.3 .OR. MIXELM.EQ.1.AND.NPL.NE.NPH) THEN
          CALL CNGRAD(NCOL,NROW,NLAY,ICBUND(:,:,:,ICOMP),
     &     COLD(:,:,:,ICOMP),BUFF)
        ENDIF
C
C--UPDATE PARTICLE CONCENTRATIONS WITH CONCENTRATION CHANGES CONTAINED
C--IN THE [DC] ARRAY, AND DELET/INSERT PARTICLES AS NECESSARY
        CALL PARMGR(IOUT,NCOL,NROW,NLAY,MIXELM,MXPART,NCOUNT(ICOMP),
     &   NPINS(ICOMP),NRC(ICOMP),
     &   NPCHEK(:,:,:,ICOMP),ICBUND(:,:,:,ICOMP),DELR,DELC,DZ,DH,PRSITY,
     &   XBC,YBC,ZBC,XP(:,ICOMP),YP(:,ICOMP),ZP(:,ICOMP),
     &   INDEXX(:,ICOMP),INDEXY(:,ICOMP),INDEXZ(:,ICOMP),
     &   CNPT(:,1,ICOMP),COLD(:,:,:,ICOMP),CADV(:,:,:,ICOMP),BUFF)
C
C--CALCULATE CNEW WITH FORWARD TRACKING PROCEDURE
        CALL SADV5M(NCOL,NROW,NLAY,MXPART,NCOUNT(ICOMP),
     &   NPCHEK(:,:,:,ICOMP),XP(:,ICOMP),YP(:,ICOMP),ZP(:,ICOMP),
     &   INDEXX(:,ICOMP),INDEXY(:,ICOMP),INDEXZ(:,ICOMP),
     &   CNPT(:,1,ICOMP),ICBUND(:,:,:,ICOMP),DELR,DELC,DZ,XBC,YBC,ZBC,
     &   DH,PRSITY,QX,QY,QZ,RETA(:,:,:,ICOMP),COLD(:,:,:,ICOMP),
     &   CNEW(:,:,:,ICOMP),CADV(:,:,:,ICOMP),DTRANS)
C
      ENDIF
C
C--IF [MMOC] OR [HMOC] IS USED
C--CALCULATE CNEW WITH BACKWARD TRACKING PROCEDURE
      IF(MIXELM.EQ.2 .OR. MIXELM.EQ.3) THEN
        CALL SADV5B(NCOL,NROW,NLAY,MIXELM,
     &   ICBUND(:,:,:,ICOMP),DELR,DELC,DZ,XBC,YBC,ZBC,DH,
     &   PRSITY,QX,QY,QZ,RETA(:,:,:,ICOMP),COLD(:,:,:,ICOMP),
     &   CNEW(:,:,:,ICOMP),BUFF,DTRANS)
      ENDIF
C
C--IF CONSTANT CONCENTRATION CELL, ASSIGN [COLD] TO [CNEW]
C--AND COMPUTE ADVECTIVE MASS IN OR OUT
      IF(MIXELM.LE.0) GOTO 100
C
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(ICBUND(J,I,K,ICOMP).GE.0) CYCLE
            CNEW(J,I,K,ICOMP)=COLD(J,I,K,ICOMP)
            QCTMP=SADV5Q(NCOL,NROW,NLAY,J,I,K,ICBUND(:,:,:,ICOMP),
     &       DELR,DELC,DH,COLD(:,:,:,ICOMP),QX,QY,QZ,DTRANS,NADVFD)
            IF(QCTMP.GT.0) THEN
              RMASIO(6,1,ICOMP)=RMASIO(6,1,ICOMP)+QCTMP
            ELSE
              RMASIO(6,2,ICOMP)=RMASIO(6,2,ICOMP)+QCTMP
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
  100 CONTINUE
C
C--CALCULATE WEIGHTED CONCENTRATION [CWGT] FOR USE IN EVALUATING
C--CONCENTRAION CHANGES DUE TO DISPERSION, SINK/SOURCE, AND/OR
C--CHEMICAL REACTIONS; SAVE NEW CONC. DUE TO ADVECTION IN [CADV]
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(ICBUND(J,I,K,ICOMP).EQ.0) CYCLE
            CWGT(J,I,K,ICOMP)=(1.-WD)*COLD(J,I,K,ICOMP)
     &       +WD*CNEW(J,I,K,ICOMP)
            CADV(J,I,K,ICOMP)=CNEW(J,I,K,ICOMP)
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE SADV5M(NCOL,NROW,NLAY,MXPART,NCOUNT,NPCHEK,XP,YP,ZP,
     & INDEXX,INDEXY,INDEXZ,CNPT,ICBUND,DELR,DELC,DZ,XBC,YBC,ZBC,DH,
     & PRSITY,QX,QY,QZ,RETA,COLD,CNEW,CADV,DTRANS)
C **********************************************************************
C THIS SUBROUTINE CALCULATES CONCENTRATIONS AT THE INTERMEDIATE TIME
C LEVEL DUE TO ADVECTION USING THE FORWARD TRACKING MOC PROCEDURE.
C **********************************************************************
C last modified: 02-15-2005
C
      IMPLICIT  NONE
      INTEGER   NCOL,NROW,NLAY,NCOUNT,NPCHEK,NP,ICBUND,
     &          MXPART,JJ,II,KK,J,I,K,JP,IP,KP,
     &          NN,ITRACK,NPL,NPH,NPMIN,NPMAX,INTERP,NLSINK,
     &          NPSINK,NPLANE,ISEED,INDEXX,INDEXY,INDEXZ
      REAL      XP,YP,ZP,CNPT,DELR,DELC,DZ,XBC,YBC,ZBC,DH,
     &          PRSITY,QX,QY,QZ,RETA,COLD,CNEW,CADV,WD,
     &          P,V,DT,DTRANS,UPFACE,ALPHA,CF,ZMIN,
     &          DCEPS,SRMULT,DCHMOC,HORIGN,XMAX,YMAX,ZMAX,PERCEL
      LOGICAL   UNIDX,UNIDY,UNIDZ
      DIMENSION XP(MXPART),YP(MXPART),ZP(MXPART),CNPT(MXPART,2),
     &          NPCHEK(NCOL,NROW,NLAY),ICBUND(NCOL,NROW,NLAY),
     &          DELR(NCOL),DELC(NROW),DZ(NCOL,NROW,NLAY),XBC(NCOL),
     &          YBC(NROW),ZBC(NCOL,NROW,NLAY),DH(NCOL,NROW,NLAY),
     &          PRSITY(NCOL,NROW,NLAY),QX(NCOL,NROW,NLAY),
     &          QY(NCOL,NROW,NLAY),QZ(NCOL,NROW,NLAY),
     &          RETA(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          CNEW(NCOL,NROW,NLAY),CADV(NCOL,NROW,NLAY),P(3),V(3),
     &          INDEXX(MXPART),INDEXY(MXPART),INDEXZ(MXPART)
      COMMON   /PD/HORIGN,XMAX,YMAX,ZMAX,UNIDX,UNIDY,UNIDZ
      COMMON   /AD/PERCEL,ITRACK,WD,ISEED,DCEPS,NPLANE,NPL,NPH,
     &           NPMIN,NPMAX,SRMULT,INTERP,NLSINK,NPSINK,DCHMOC
C
C--CLEAR [CNEW] ARRAY TO ACCUMULATE CONC.*VOL. OF PARTICLES
C--AND CLEAR [CADV] ARRAY TO ACCUMULATE VOL. OF PARTICLES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(ICBUND(J,I,K).NE.0) THEN
              CNEW(J,I,K)=0.
              CADV(J,I,K)=0.
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--MOVE EACH PARTICLE OVER TIME INCREMENT DT......
      DT=DTRANS
      P(1)=XBC(1)
      P(2)=YBC(1)
      P(3)=ZBC(1,1,1)
      V(1)=0.
      V(2)=0.
      V(3)=0.
      JJ=1
      II=1
      KK=1
      DO NP=1,NCOUNT
        NN=NP
        IF(NCOL.GT.1) THEN
          P(1)=XP(NN)
          JJ=INDEXX(NN)
        ENDIF
        IF(NROW.GT.1) THEN
          P(2)=YP(NN)
          II=INDEXY(NN)
        ENDIF
        IF(NLAY.GT.1) THEN
          P(3)=ZP(NN)
          KK=INDEXZ(NN)
        ENDIF
        NPCHEK(JJ,II,KK)=NPCHEK(JJ,II,KK)-1
        IF(NPCHEK(JJ,II,KK).LT.0) CNPT(NN,1)=COLD(JJ,II,KK)
        IF(ICBUND(JJ,II,KK).EQ.0) GOTO 100
C
C--GET VELOCITY COMPONENTS AT POINT P
        IF(NCOL.GT.1) THEN
          ALPHA=(P(1)-XBC(JJ)+0.5*DELR(JJ))/DELR(JJ)
          IF(JJ-1.LT.1) THEN
            V(1)=ALPHA*QX(JJ,II,KK)/(PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
          ELSE
            V(1)=(ALPHA*QX(JJ,II,KK)+(1.-ALPHA)*QX(JJ-1,II,KK))
     &       /(PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
          ENDIF
        ENDIF
        IF(NROW.GT.1) THEN
          ALPHA=(P(2)-YBC(II)+0.5*DELC(II))/DELC(II)
          IF(II-1.LT.1) THEN
            V(2)=ALPHA*QY(JJ,II,KK)/(PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
          ELSE
            V(2)=(ALPHA*QY(JJ,II,KK)+(1.-ALPHA)*QY(JJ,II-1,KK))
     &       /(PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
          ENDIF
        ENDIF
        IF(NLAY.GT.1) THEN
          UPFACE=ZBC(JJ,II,KK)+0.5*DZ(JJ,II,KK)-DH(JJ,II,KK)
          ALPHA=(P(3)-UPFACE)/DH(JJ,II,KK)
          IF(ALPHA.LT.0) ALPHA=0
          IF(KK-1.LT.1) THEN
            V(3)=ALPHA*QZ(JJ,II,KK)/(PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
          ELSE
            V(3)=(ALPHA*QZ(JJ,II,KK)+(1.-ALPHA)*QZ(JJ,II,KK-1))
     &       /(PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
          ENDIF
        ENDIF
        IF(ITRACK.EQ.2.OR.ITRACK.EQ.3.AND.(ICBUND(JJ,II,KK).GE.1000.
     &   AND.ICBUND(JJ,II,KK).LE.1030.OR.ICBUND(JJ,II,KK).LT.0)) THEN
          CALL VRK4(P,V,DT,JJ,II,KK,NCOL,NROW,NLAY,ICBUND,
     &              DELR,DELC,DZ,XBC,YBC,ZBC,DH,PRSITY,QX,QY,QZ,RETA)
        ENDIF
C
C--MOVE PARTICLE FORWARD
        JP=JJ
        IP=II
        KP=KK
C
C--ALONG THE X DIRECTION...
        IF(NCOL.LT.2) GOTO 10
        P(1)=P(1)+V(1)*DT
C
C--REFLECTION OF PARTICLE AT MODEL EDGE OR BOUNDARY IF NEEDED
        IF(P(1)-XBC(JP).LT.0.5*DELR(JP).AND.
     &   P(1)-XBC(JP).GE.-0.5*DELR(JP)) GOTO 10
        IF(P(1).GT.XMAX) THEN
          P(1)=2.0*XMAX-P(1)
        ELSEIF(P(1)-XBC(JP).GT.0.5*DELR(JP)) THEN
          IF(JP.LT.NCOL.AND.ICBUND(JP+1,IP,KP).EQ.0) THEN
            P(1)=2.0*(XBC(JP)+0.5*DELR(JP))-P(1)
          ENDIF
        ELSEIF(P(1).LT.0) THEN
          P(1)=-P(1)
        ELSEIF(P(1)-XBC(JP).LT.-0.5*DELR(JP)) THEN
          IF(JP.GT.1.AND.ICBUND(JP-1,IP,KP).EQ.0) THEN
            P(1)=2.0*(XBC(JP)-0.5*DELR(JP))-P(1)
          ENDIF
        ENDIF
        IF(P(1).GT.XMAX) P(1)=XMAX
        IF(P(1).LT.0) P(1)=0
C
C--UPDATE THE J INDEX FOR THE NEW X COORDINATE
        IF(UNIDX) THEN
          JP=INT(P(1)/DELR(1))+1
          IF(JP.GT.NCOL) JP=NCOL
        ELSEIF(V(1)*DT.LT.0) THEN
          DO J=JJ,1,-1
            IF(P(1).GE.XBC(J)-0.5*DELR(J) .AND.
     &         P(1).LT.XBC(J)+0.5*DELR(J)) THEN
              JP=J
              GOTO 1
            ENDIF
          ENDDO
    1     CONTINUE
        ELSEIF(V(1)*DT.GT.0) THEN
          DO J=JJ,NCOL
            IF(P(1).GE.XBC(J)-0.5*DELR(J) .AND.
     &         P(1).LT.XBC(J)+0.5*DELR(J)) THEN
              JP=J
              GOTO 2
            ENDIF
          ENDDO
    2     CONTINUE
        ENDIF
C
C--ALONG THE Y DIRECTION...
   10   IF(NROW.LT.2) GOTO 20
        P(2)=P(2)+V(2)*DT
C
C--REFLECTION OF PARTICLE AT MODEL EDGE OR BOUNDARY IF NEEDED
        IF(P(2)-YBC(IP).LT.0.5*DELC(IP).AND.
     &   P(2)-YBC(IP).GE.-0.5*DELC(IP)) GOTO 20
        IF(P(2).GT.YMAX) THEN
          P(2)=2.0*YMAX-P(2)
        ELSEIF(P(2)-YBC(IP).GT.0.5*DELC(IP)) THEN
          IF(IP.LT.NROW.AND.ICBUND(JP,IP+1,KP).EQ.0) THEN
            P(2)=2.0*(YBC(IP)+0.5*DELC(IP))-P(2)
          ENDIF
        ELSEIF(P(2).LT.0) THEN
          P(2)=-P(2)
        ELSEIF(P(2)-YBC(IP).LT.-0.5*DELC(IP)) THEN
          IF(IP.GT.1.AND.ICBUND(JP,IP-1,KP).EQ.0) THEN
            P(2)=2.0*(YBC(IP)-0.5*DELC(IP))-P(2)
          ENDIF
        ENDIF
        IF(P(2).GT.YMAX) P(2)=YMAX
        IF(P(2).LT.0) P(2)=0
C
C--UPDATE THE I INDEX FOR THE NEW Y COORDINATE
        IF(UNIDY) THEN
          IP=INT(P(2)/DELC(1))+1
          IF(IP.GT.NROW) IP=NROW
        ELSEIF(V(2)*DT.LT.0) THEN
          DO I=II,1,-1
            IF(P(2).GE.YBC(I)-0.5*DELC(I) .AND.
     &         P(2).LT.YBC(I)+0.5*DELC(I)) THEN
              IP=I
              GOTO 3
            ENDIF
          ENDDO
    3     CONTINUE
        ELSEIF(V(2)*DT.GT.0) THEN
          DO I=II,NROW
            IF(P(2).GE.YBC(I)-0.5*DELC(I) .AND.
     &         P(2).LT.YBC(I)+0.5*DELC(I)) THEN
              IP=I
              GOTO 4
            ENDIF
          ENDDO
    4     CONTINUE
        ENDIF
C
C--ALONG THE Z DIRECTION...
   20   IF(NLAY.LT.2) GOTO 30
        P(3)=P(3)+V(3)*DT
C
C-ADJUSTED FOR DISTORTED GRID IF NECESSARY
        IF(ABS(ZBC(JP,IP,KK)-ZBC(JJ,II,KK)).GT.1.E-5
     &   .OR.ABS(DZ(JP,IP,KK)-DZ(JJ,II,KK)).GT.1.E-5) THEN
          IF(DZ(JJ,II,KK).GT.0) THEN
            CF=DZ(JP,IP,KK)/DZ(JJ,II,KK)*
     &                   (P(3)-V(3)*DT-ZBC(JJ,II,KK))
            P(3)=V(3)*DT+CF+ZBC(JP,IP,KK)
          ENDIF
        ENDIF
C
C--REFLECTION OF PARTICLE AT MODEL EDGE OR BOUNDARY IF NEEDED
        IF(P(3)-ZBC(JP,IP,KK).LT.0.5*DZ(JP,IP,KK).AND.
     &   P(3)-ZBC(JP,IP,KK).GE.-0.5*DZ(JP,IP,KK)) GOTO 30
        ZMIN=ZBC(JP,IP,1)-0.5*DZ(JP,IP,1)
        ZMAX=ZBC(JP,IP,NLAY)+0.5*DZ(JP,IP,NLAY)
        IF(P(3).GT.ZMAX) THEN
          P(3)=2.0*ZMAX-P(3)
        ELSEIF(P(3)-ZBC(JP,IP,KK).GT.0.5*DZ(JP,IP,KK)) THEN
          IF(KK.LT.NLAY.AND.ICBUND(JP,IP,KK+1).EQ.0) THEN
            P(3)=2.0*(ZBC(JP,IP,KK)+0.5*DZ(JP,IP,KK))-P(3)
          ENDIF
        ELSEIF(P(3).LT.ZMIN) THEN
          P(3)=2.0*ZMIN-P(3)
        ELSEIF(P(3)-ZBC(JP,IP,KK).LT.-0.5*DZ(JP,IP,KK)) THEN
          IF(KK.GT.1.AND.ICBUND(JP,IP,KK-1).EQ.0) THEN
            P(3)=2.0*(ZBC(JP,IP,KK)-0.5*DZ(JP,IP,KK))-P(3)
          ENDIF
        ENDIF
        IF(P(3).GT.ZMAX) P(3)=ZMAX
        IF(P(3).LT.0) P(3)=0
C
C--UPDATE THE K INDEX FOR THE NEW Z COORDINATE
        IF(UNIDZ) THEN
          KP=INT(P(3)/DZ(JP,IP,1))+1
          IF(KP.GT.NLAY) KP=NLAY
        ELSEIF(V(3)*DT.LT.0) THEN
          DO K=KK,1,-1
            IF(P(3).GE.ZBC(JP,IP,K)-0.5*DZ(JP,IP,K) .AND.
     &         P(3).LT.ZBC(JP,IP,K)+0.5*DZ(JP,IP,K)) THEN
              KP=K
              GOTO 5
            ENDIF
          ENDDO
    5     CONTINUE
        ELSEIF(V(3)*DT.GT.0) THEN
          DO K=KK,NLAY
            IF(P(3).GE.ZBC(JP,IP,K)-0.5*DZ(JP,IP,K) .AND.
     &         P(3).LT.ZBC(JP,IP,K)+0.5*DZ(JP,IP,K)) THEN
              KP=K
              GOTO 6
            ENDIF
          ENDDO
    6     CONTINUE
        ENDIF
C
C--UPDATE PARTICLE ARRAYS AND ACCUMULATE CONCENTRATION IN [CNEW]
   30   IF(NCOL.GT.1) THEN
          XP(NN)=P(1)
          INDEXX(NN)=JP
        ENDIF
        IF(NROW.GT.1) THEN
          YP(NN)=P(2)
          INDEXY(NN)=IP
        ENDIF
        IF(NLAY.GT.1) THEN
          ZP(NN)=P(3)
          INDEXZ(NN)=KP
        ENDIF
        NPCHEK(JP,IP,KP)=NPCHEK(JP,IP,KP)+1
        CNEW(JP,IP,KP)=CNEW(JP,IP,KP)+CNPT(NN,1)*CNPT(NN,2)
        CADV(JP,IP,KP)=CADV(JP,IP,KP)+CNPT(NN,2)
C
  100 ENDDO
C
C--CALCULATE INTERMEDIATE CELL CONCENTRATIONS
C--BY DIVIDING ACCUMULATED CONC.*VOL. BY ACCUMULATED VOL.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
             IF(ICBUND(J,I,K).GT.0) THEN
              IF(NPCHEK(J,I,K).LT.0) NPCHEK(J,I,K)=NPCHEK(J,I,K)+1000
              IF(CADV(J,I,K).GT.0) THEN
                CNEW(J,I,K)=CNEW(J,I,K)/CADV(J,I,K)
              ELSE
                CNEW(J,I,K)=COLD(J,I,K)
              ENDIF
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE SADV5B(NCOL,NROW,NLAY,MIXELM,ICBUND,DELR,DELC,DZ,
     & XBC,YBC,ZBC,DH,PRSITY,QX,QY,QZ,RETA,COLD,CNEW,BUFF,DTRANS)
C **********************************************************************
C THIS SUBROUTINE CALCULATES CONCENTRATIONS AT THE INTERMEDIATE TIME
C LEVEL DUE TO ADVECTION WITH THE BACKWARD TRACKING MMOC PROCEDURE.
C **********************************************************************
C last modified: 02-15-2005
C
      IMPLICIT  NONE
      INTEGER   NMAX,NCOL,NROW,NLAY,NP,ICBUND,MIXELM,
     &          JJ,II,KK,J,I,K,ITRACK,NPL,NPH,NPMIN,
     &          NPMAX,INTERP,NLSINK,NPSINK,NPLANE,NPOINT,
     &          ISEED,KM1,IM1,JM1,JLO,ILO,KLO,JHI,IHI,KHI,JP,IP,KP
      PARAMETER (NMAX=128)
      REAL      DELR,DELC,DZ,XBC,YBC,ZBC,DH,PRSITY,QX,QY,QZ,RETA,
     &          COLD,CNEW,WD,DT,DTRANS,D2,D2SUM,BUFF,
     &          DCEPS,SRMULT,DCHMOC,HORIGN,XMAX,YMAX,ZMAX,PERCEL,
     &          XTMP,YTMP,ZTMP,UPFACE,ALPHA,CF,ZMIN,RAN0,
     &          CPOINT,WX,WY,WZ,CTMP,P,V
      LOGICAL   UNIDX,UNIDY,UNIDZ
      DIMENSION ICBUND(NCOL,NROW,NLAY),
     &          DELR(NCOL),DELC(NROW),DZ(NCOL,NROW,NLAY),XBC(NCOL),
     &          YBC(NROW),ZBC(NCOL,NROW,NLAY),DH(NCOL,NROW,NLAY),
     &          PRSITY(NCOL,NROW,NLAY),QX(NCOL,NROW,NLAY),
     &          QY(NCOL,NROW,NLAY),QZ(NCOL,NROW,NLAY),
     &          RETA(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          CNEW(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY),
     &          XTMP(NMAX),YTMP(NMAX),ZTMP(NMAX),P(3),V(3)
      COMMON /PD/HORIGN,XMAX,YMAX,ZMAX,UNIDX,UNIDY,UNIDZ
      COMMON /AD/PERCEL,ITRACK,WD,ISEED,DCEPS,NPLANE,NPL,NPH,
     &           NPMIN,NPMAX,SRMULT,INTERP,NLSINK,NPSINK,DCHMOC
C
C--SET DT TO NEGATIVE FOR BACKWARD TRACKING
      DT=-DTRANS
C
C--LOOP OVER ALL ACTIVE CELLS
      DO KK=1,NLAY
      DO II=1,NROW
      DO JJ=1,NCOL
C
        IF(ICBUND(JJ,II,KK).LE.0) GOTO 999
        IF(MIXELM.EQ.3.AND.BUFF(JJ,II,KK).GT.DCHMOC) GOTO 999
        CNEW(JJ,II,KK)=0.
        D2SUM=0.
C
C--PLACE ONE PARTICLE AT NODAL POINT
        NPOINT=1
        XTMP(NPOINT)=XBC(JJ)
        YTMP(NPOINT)=YBC(II)
        ZTMP(NPOINT)=ZBC(JJ,II,KK)
C
C--IF CELL CONTAINS SINK, MULTIPLE PARTICLES ARE NEEDED.
C--RANDOMLY GENERATE THEIR LOCATIONS
        IF(ICBUND(JJ,II,KK).GT.1000 .AND.
     &                      ICBUND(JJ,II,KK).LT.1010) THEN
C
          IF(NPLANE.LE.0) THEN
            NPOINT=NPSINK
          ELSE
            NPOINT=NPSINK*NPLANE
            IF(NPOINT.GT.NMAX) NPOINT=NMAX
          ENDIF
          DO NP=1,NPOINT
            XTMP(NP)=XBC(JJ)
            YTMP(NP)=YBC(II)
            ZTMP(NP)=ZBC(JJ,II,KK)
            IF(NCOL.GT.1)
     &       XTMP(NP)=XBC(JJ)+(RAN0(ISEED)-0.5)*DELR(JJ)
            IF(NROW.GT.1)
     &       YTMP(NP)=YBC(II)+(RAN0(ISEED)-0.5)*DELC(II)
            IF(NLAY.GT.1)
     &       ZTMP(NP)=ZBC(JJ,II,KK)+0.5*DZ(JJ,II,KK)
     &       -RAN0(ISEED)*DH(JJ,II,KK)
          ENDDO
C
        ENDIF
C
C--MOVE EACH PARTICLE BACKWARD OVER TIME INCREMENT DT
        NP=1
C
  100   CONTINUE
        JP=JJ
        IP=II
        KP=KK
        P(1)=XTMP(NP)
        P(2)=YTMP(NP)
        P(3)=ZTMP(NP)
        IF(NPOINT.GT.1) THEN
          D2=(P(1)-XBC(JJ))*(P(1)-XBC(JJ))+
     &       (P(2)-YBC(II))*(P(2)-YBC(II))+
     &       (P(3)-ZBC(JJ,II,KK))*(P(3)-ZBC(JJ,II,KK))
          IF(D2.NE.0) D2SUM=D2SUM+1./D2
        ENDIF
C
C--GET VELOCITY COMPONENTS AT POINT P
        IF(NCOL.GT.1) THEN
          ALPHA=(P(1)-XBC(JJ)+0.5*DELR(JJ))/DELR(JJ)
          JM1=JJ-1
          IF(JM1.LT.1) JM1=1
          V(1)=(ALPHA*QX(JJ,II,KK)+(1.-ALPHA)*QX(JM1,II,KK))
     &     /(PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
        ENDIF
        IF(NROW.GT.1) THEN
          ALPHA=(P(2)-YBC(II)+0.5*DELC(II))/DELC(II)
          IM1=II-1
          IF(IM1.LT.1) IM1=1
          V(2)=(ALPHA*QY(JJ,II,KK)+(1.-ALPHA)*QY(JJ,IM1,KK))
     &     /(PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
        ENDIF
        IF(NLAY.GT.1) THEN
          UPFACE=ZBC(JJ,II,KK)+0.5*DZ(JJ,II,KK)-DH(JJ,II,KK)
          ALPHA=(P(3)-UPFACE)/DH(JJ,II,KK)
          KM1=KK-1
          IF(KM1.LT.1) KM1=1
          IF(ALPHA.LT.0) ALPHA=0
          V(3)=(ALPHA*QZ(JJ,II,KK)+(1.-ALPHA)*QZ(JJ,II,KM1))
     &     /(PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
        ENDIF
        IF(ITRACK.EQ.2.OR.ITRACK.EQ.3.AND.(ICBUND(JJ,II,KK).GE.1000.
     &   AND.ICBUND(JJ,II,KK).LE.1030.OR.ICBUND(JJ,II,KK).LT.0)) THEN
          CALL VRK4(P,V,DT,JJ,II,KK,NCOL,NROW,NLAY,ICBUND,
     &          DELR,DELC,DZ,XBC,YBC,ZBC,DH,PRSITY,QX,QY,QZ,RETA)
        ENDIF
C
C--MOVE PARTICLE FORWARD
C
C--ALONG THE X DIRECTION...
        IF(NCOL.LT.2) GOTO 10
        P(1)=P(1)+V(1)*DT
C
C--REFLECTION OF PARTICLE AT MODEL EDGE OR BOUNDARY IF NEEDED
        IF(P(1)-XBC(JP).LT.0.5*DELR(JP).AND.
     &   P(1)-XBC(JP).GE.-0.5*DELR(JP)) GOTO 10
        IF(P(1).GT.XMAX) THEN
          P(1)=2.0*XMAX-P(1)
        ELSEIF(P(1)-XBC(JP).GT.0.5*DELR(JP)) THEN
          IF(JP.LT.NCOL.AND.ICBUND(JP+1,IP,KP).EQ.0) THEN
            P(1)=2.0*(XBC(JP)+0.5*DELR(JP))-P(1)
          ENDIF
        ELSEIF(P(1).LT.0) THEN
          P(1)=-P(1)
        ELSEIF(P(1)-XBC(JP).LT.-0.5*DELR(JP)) THEN
          IF(JP.GT.1.AND.ICBUND(JP-1,IP,KP).EQ.0) THEN
            P(1)=2.0*(XBC(JP)-0.5*DELR(JP))-P(1)
          ENDIF
        ENDIF
C
C--UPDATE THE J INDEX FOR THE NEW X COORDINATE
        IF(UNIDX) THEN
          JP=INT(P(1)/DELR(1))+1
          IF(JP.GT.NCOL) JP=NCOL
        ELSEIF(V(1)*DT.LT.0) THEN
          DO J=JJ,1,-1
            IF(P(1).GE.XBC(J)-0.5*DELR(J) .AND.
     &         P(1).LT.XBC(J)+0.5*DELR(J)) THEN
              JP=J
              GOTO 1
            ENDIF
          ENDDO
    1     CONTINUE
        ELSEIF(V(1)*DT.GT.0) THEN
          DO J=JJ,NCOL
            IF(P(1).GE.XBC(J)-0.5*DELR(J) .AND.
     &         P(1).LT.XBC(J)+0.5*DELR(J)) THEN
              JP=J
              GOTO 2
            ENDIF
          ENDDO
    2     CONTINUE
        ENDIF
C
C--ALONG THE Y DIRECTION...
   10   IF(NROW.LT.2) GOTO 20
        P(2)=P(2)+V(2)*DT
C
C--REFLECTION OF PARTICLE AT MODEL EDGE OR BOUNDARY IF NEEDED
        IF(P(2)-YBC(IP).LT.0.5*DELC(IP).AND.
     &   P(2)-YBC(IP).GE.-0.5*DELC(IP)) GOTO 20
        IF(P(2).GT.YMAX) THEN
          P(2)=2.0*YMAX-P(2)
        ELSEIF(P(2)-YBC(IP).GT.0.5*DELC(IP)) THEN
          IF(IP.LT.NROW.AND.ICBUND(JP,IP+1,KP).EQ.0) THEN
            P(2)=2.0*(YBC(IP)+0.5*DELC(IP))-P(2)
          ENDIF
        ELSEIF(P(2).LT.0) THEN
          P(2)=-P(2)
        ELSEIF(P(2)-YBC(IP).LT.-0.5*DELC(IP)) THEN
          IF(IP.GT.1.AND.ICBUND(JP,IP-1,KP).EQ.0) THEN
            P(2)=2.0*(YBC(IP)-0.5*DELC(IP))-P(2)
          ENDIF
        ENDIF
C
C--UPDATE THE I INDEX FOR THE NEW Y COORDINATE
        IF(UNIDY) THEN
          IP=INT(P(2)/DELC(1))+1
          IF(IP.GT.NROW) IP=NROW
        ELSEIF(V(2)*DT.LT.0) THEN
          DO I=II,1,-1
            IF(P(2).GE.YBC(I)-0.5*DELC(I) .AND.
     &         P(2).LT.YBC(I)+0.5*DELC(I)) THEN
              IP=I
              GOTO 3
            ENDIF
          ENDDO
    3     CONTINUE
        ELSEIF(V(2)*DT.GT.0) THEN
          DO I=II,NROW
            IF(P(2).GE.YBC(I)-0.5*DELC(I) .AND.
     &         P(2).LT.YBC(I)+0.5*DELC(I)) THEN
              IP=I
              GOTO 4
            ENDIF
          ENDDO
    4     CONTINUE
        ENDIF
C
C--ALONG THE Z DIRECTION...
   20   IF(NLAY.LT.2) GOTO 30
        P(3)=P(3)+V(3)*DT
C
C-ADJUSTED FOR DISTORTED GRID IF NECESSARY
        IF(ABS(ZBC(JP,IP,KK)-ZBC(JJ,II,KK)).GT.1.E-5
     &   .OR.ABS(DZ(JP,IP,KK)-DZ(JJ,II,KK)).GT.1.E-5) THEN
          IF(DZ(JJ,II,KK).GT.0) THEN
            CF=DZ(JP,IP,KK)/DZ(JJ,II,KK)*
     &                   (P(3)-V(3)*DT-ZBC(JJ,II,KK))
            P(3)=V(3)*DT+CF+ZBC(JP,IP,KK)
          ENDIF
        ENDIF
C
C--REFLECTION OF PARTICLE AT MODEL EDGE OR BOUNDARY IF NEEDED
        IF(P(3)-ZBC(JP,IP,KK).LT.0.5*DZ(JP,IP,KK).AND.
     &   P(3)-ZBC(JP,IP,KK).GE.-0.5*DZ(JP,IP,KK)) GOTO 30
        ZMIN=ZBC(JP,IP,1)-0.5*DZ(JP,IP,1)
        ZMAX=ZBC(JP,IP,NLAY)+0.5*DZ(JP,IP,NLAY)
        IF(P(3).GT.ZMAX) THEN
          P(3)=2.0*ZMAX-P(3)
        ELSEIF(P(3)-ZBC(JP,IP,KK).GT.0.5*DZ(JP,IP,KK)) THEN
          IF(KK.LT.NLAY.AND.ICBUND(JP,IP,KK+1).EQ.0) THEN
            P(3)=2.0*(ZBC(JP,IP,KK)+0.5*DZ(JP,IP,KK))-P(3)
          ENDIF
        ELSEIF(P(3).LT.ZMIN) THEN
          P(3)=2.0*ZMIN-P(3)
        ELSEIF(P(3)-ZBC(JP,IP,KK).LT.-0.5*DZ(JP,IP,KK)) THEN
          IF(KK.GT.1.AND.ICBUND(JP,IP,KK-1).EQ.0) THEN
            P(3)=2.0*(ZBC(JP,IP,KK)-0.5*DZ(JP,IP,KK))-P(3)
          ENDIF
        ENDIF
C
C--UPDATE THE K INDEX FOR THE NEW Z COORDINATE
        IF(UNIDZ) THEN
          KP=INT(P(3)/DZ(JP,IP,1))+1
          IF(KP.GT.NLAY) KP=NLAY
        ELSEIF(V(3)*DT.LT.0) THEN
          DO K=KK,1,-1
            IF(P(3).GE.ZBC(JP,IP,K)-0.5*DZ(JP,IP,K) .AND.
     &         P(3).LT.ZBC(JP,IP,K)+0.5*DZ(JP,IP,K)) THEN
              KP=K
              GOTO 5
            ENDIF
          ENDDO
    5     CONTINUE
        ELSEIF(V(3)*DT.GT.0) THEN
          DO K=KK,NLAY
            IF(P(3).GE.ZBC(JP,IP,K)-0.5*DZ(JP,IP,K) .AND.
     &         P(3).LT.ZBC(JP,IP,K)+0.5*DZ(JP,IP,K)) THEN
              KP=K
              GOTO 6
            ENDIF
          ENDDO
    6     CONTINUE
        ENDIF
C
   30   CONTINUE
C
C--DEFINE LOWER AND UPPER BOUNDS FOR MULTI-LINEAR INTERPOLATION
        IF(P(1).GT.XBC(JP)) THEN
          JLO=JP
        ELSE
          JLO=JP-1
        ENDIF
        IF(P(2).GT.YBC(IP)) THEN
          ILO=IP
        ELSE
          ILO=IP-1
        ENDIF
        IF(P(3).GT.ZBC(JP,IP,KP)) THEN
          KLO=KP
        ELSE
          KLO=KP-1
        ENDIF
        JHI=JLO+1
        IHI=ILO+1
        KHI=KLO+1
        IF(JLO.LT.1) JLO=1
        IF(JHI.GT.NCOL) JHI=NCOL
        IF(ILO.LT.1) ILO=1
        IF(IHI.GT.NROW) IHI=NROW
        IF(KLO.LT.1) KLO=1
        IF(KHI.GT.NLAY) KHI=NLAY
C
C--CALCULATING LINEAR INTERPOLATION FACTORS
        IF(JLO.NE.JHI) THEN
          WX=(P(1)-XBC(JLO))/(0.5*DELR(JHI)+0.5*DELR(JLO))
        ELSE
          WX=0
        ENDIF
        IF(ILO.NE.IHI) THEN
          WY=(P(2)-YBC(ILO))/(0.5*DELC(IHI)+0.5*DELC(ILO))
        ELSE
          WY=0
        ENDIF
        IF(KLO.NE.KHI) THEN
          WZ=(P(3)-ZBC(JP,IP,KLO))/(0.5*DZ(JP,IP,KHI)+
     &     0.5*DZ(JP,IP,KLO))
        ELSE
          WZ=0
        ENDIF
C
C--PERFORM INTERPOLATION
        CPOINT=0
C
        CTMP=COLD(JLO,ILO,KLO)
        IF(ICBUND(JLO,ILO,KLO).EQ.0) CTMP=COLD(JP,IP,KP)
        CPOINT=CPOINT+(1.-WX)*(1.-WY)*(1.-WZ)*CTMP
        CTMP=COLD(JLO,IHI,KLO)
        IF(ICBUND(JLO,IHI,KLO).EQ.0) CTMP=COLD(JP,IP,KP)
        CPOINT=CPOINT+(1.-WX)*WY*(1.-WZ)*CTMP
        CTMP=COLD(JHI,ILO,KLO)
        IF(ICBUND(JHI,ILO,KLO).EQ.0) CTMP=COLD(JP,IP,KP)
        CPOINT=CPOINT+WX*(1.-WY)*(1.-WZ)*CTMP
        CTMP=COLD(JHI,IHI,KLO)
        IF(ICBUND(JHI,IHI,KLO).EQ.0) CTMP=COLD(JP,IP,KP)
        CPOINT=CPOINT+WX*WY*(1.-WZ)*CTMP
C
        IF(NLAY.GT.1) THEN
          CTMP=COLD(JLO,ILO,KHI)
          IF(ICBUND(JLO,ILO,KHI).EQ.0) CTMP=COLD(JP,IP,KP)
          CPOINT=CPOINT+(1.-WX)*(1.-WY)*WZ*CTMP
          CTMP=COLD(JLO,IHI,KHI)
          IF(ICBUND(JLO,IHI,KHI).EQ.0) CTMP=COLD(JP,IP,KP)
          CPOINT=CPOINT+(1.-WX)*WY*WZ*CTMP
          CTMP=COLD(JHI,ILO,KHI)
          IF(ICBUND(JHI,ILO,KHI).EQ.0) CTMP=COLD(JP,IP,KP)
          CPOINT=CPOINT+WX*(1.-WY)*WZ*CTMP
          CTMP=COLD(JHI,IHI,KHI)
          IF(ICBUND(JHI,IHI,KHI).EQ.0) CTMP=COLD(JP,IP,KP)
          CPOINT=CPOINT+WX*WY*WZ*CTMP
        ENDIF
C
C--ASSIGN INTERPOLATED CONCENTRATION TO [CNEW]
        IF(NPOINT.EQ.1 .OR. D2.EQ.0) THEN
          CNEW(JJ,II,KK)=CPOINT
        ELSE
          CNEW(JJ,II,KK)=CNEW(JJ,II,KK)+CPOINT/D2
        ENDIF
C
C--IF MULTIPLE PARTICLES USED AT A SINGLE CELL,
C--REPEAT THE ABOVE STEPS FOR ALL PARTICLES
        IF(NP.LT.NPOINT) THEN
          NP=NP+1
          GOTO 100
        ENDIF
C
C--CALCULATE AVERAGE CONCENTARTION IF MORE THAN ONE PARTICLE IS USED
        IF(NPOINT.GT.1 .AND. D2SUM.GT.0) THEN
          CNEW(JJ,II,KK)=CNEW(JJ,II,KK)/D2SUM
        ENDIF
C
  999 ENDDO
      ENDDO
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE CNGRAD(NCOL,NROW,NLAY,ICBUND,COLD,BUFF)
C ********************************************************************
C THIS SUBROUTINE CALCULATES THE RELATIVE CELL CONCENTRATION GRADIENT
C FOR EACH ACTIVE CELL IN THE GRID.
C ********************************************************************
C last modified: 02-15-2005
C
      IMPLICIT  NONE
      INTEGER   NCOL,NROW,NLAY,ICBUND,J,I,K,JM1,JP1,IM1,IP1,KM1,KP1,
     &          JJJ,III,KKK
      REAL      COLD,BUFF,DCMIN,DCMAX,CMIN,CMAX
      DIMENSION ICBUND(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          BUFF(NCOL,NROW,NLAY)
C
C--FIND MAXIMUM AND MINIMUM CONCENTRATIONS IN THE ENTIR GRID
C--AND CLEAR THE BUFFER ARRAY
      CMAX=-1.E30
      CMIN=1.E30
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(ICBUND(J,I,K).NE.0) THEN
              IF(COLD(J,I,K).LT.CMIN) CMIN=COLD(J,I,K)
              IF(COLD(J,I,K).GT.CMAX) CMAX=COLD(J,I,K)
              BUFF(J,I,K)=0.
            ENDIF
          ENDDO
        ENDDO
      ENDDO
      IF(CMAX.LE.0.OR.CMAX-CMIN.LE.0) RETURN
C
C--CALCULATE RELATIVE CELL CONCENTRATION GRADIENT AND
C--STORE IN BUFFER ARRAY [BUFF]
      DO K=1,NLAY
        KM1=MAX(K-1,1)
        KP1=MIN(K+1,NLAY)
        DO I=1,NROW
          IM1=MAX(I-1,1)
          IP1=MIN(I+1,NROW)
          DO J=1,NCOL
            JM1=MAX(J-1,1)
            JP1=MIN(J+1,NCOL)
C
            IF(ICBUND(J,I,K).NE.0) THEN
              DCMIN=COLD(J,I,K)
              DCMAX=COLD(J,I,K)
              DO KKK=KM1,KP1
                DO III=IM1,IP1
                  DO JJJ=JM1,JP1
                    IF(ICBUND(JJJ,III,KKK).NE.0) THEN
                      IF(COLD(JJJ,III,KKK).LT.DCMIN)
     &                          DCMIN=COLD(JJJ,III,KKK)
                      IF(COLD(JJJ,III,KKK).GT.DCMAX)
     &                          DCMAX=COLD(JJJ,III,KKK)
                    ENDIF
                  ENDDO
                ENDDO
              ENDDO
              BUFF(J,I,K)=(DCMAX-DCMIN)/CMAX
            ENDIF
C
          ENDDO
        ENDDO
      ENDDO
C
C--NORMAL RETURN
      RETURN
      END
C
C
      SUBROUTINE PARMGR(IOUT,NCOL,NROW,NLAY,MIXELM,MXPART,NCOUNT,NPINS,
     & NRC,NPCHEK,ICBUND,DELR,DELC,DZ,DH,PRSITY,XBC,YBC,ZBC,XP,YP,ZP,
     & INDEXX,INDEXY,INDEXZ,CNPT,COLD,CADV,BUFF)
C **********************************************************************
C THIS SUBROUTINE MANAGES THE DISTRIBUTION OF MOVING PARTICLES,
C DELETING OR INSERTING PARTICLES AS NECESSARY.
C **********************************************************************
C last modified: 02-15-2005
C
      IMPLICIT  NONE
      INTEGER   IOUT,NCOL,NROW,NLAY,NCOUNT,MXPART,ICBUND,NPCHEK,
     &          NPL,NPH,NPMIN,NPMAX,NPCELL,J,I,K,ITRACK,NPLANE,INTERP,
     &          NPSINK,NLSINK,NPALL,NPINS,NRC,ISEED,NADD,
     &          JJ,II,KK,NP,MIXELM,NLAST,NN,INDEXX,INDEXY,INDEXZ,NCOLD
      REAL      DELR,DELC,DZ,DH,PRSITY,XBC,YBC,ZBC,XP,YP,ZP,CNPT,COLD,
     &          DCEPS,SRMULT,DCHMOC,WD,PERCEL,CADV,BUFF,
     &          HORIGN,XMAX,YMAX,ZMAX,DCTMP
      LOGICAL   UNIDX,UNIDY,UNIDZ
      DIMENSION XP(MXPART),YP(MXPART),ZP(MXPART),CNPT(MXPART,2),
     &          XBC(NCOL),YBC(NROW),ZBC(NCOL,NROW,NLAY),
     &          DELR(NCOL),DELC(NROW),DZ(NCOL,NROW,NLAY),
     &          DH(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          CADV(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY),
     &          PRSITY(NCOL,NROW,NLAY),
     &          NPCHEK(NCOL,NROW,NLAY),ICBUND(NCOL,NROW,NLAY),
     &          INDEXX(MXPART),INDEXY(MXPART),INDEXZ(MXPART)
      COMMON   /PD/HORIGN,XMAX,YMAX,ZMAX,UNIDX,UNIDY,UNIDZ
      COMMON   /AD/PERCEL,ITRACK,WD,ISEED,DCEPS,NPLANE,NPL,NPH,
     & NPMIN,NPMAX,SRMULT,INTERP,NLSINK,NPSINK,DCHMOC
C
C--REMOVE PARTICLES THAT ARE NO LONGER NEEDED
C--AND UPDATE CONCENTRATIONS OF ACTIVE MOVING PARTICLES
      JJ=1
      II=1
      KK=1
      NRC=0
      DO NP=NCOUNT,1,-1
        NN=NP
        IF(NCOL.GT.1) JJ=INDEXX(NN)
        IF(NROW.GT.1) II=INDEXY(NN)
        IF(NLAY.GT.1) KK=INDEXZ(NN)
C
C--DETERMINE WHETHER PARTICLE SHOULD BE REMOVED
        IF(NPCHEK(JJ,II,KK).LT.0) GOTO 100
        IF(NPCHEK(JJ,II,KK).EQ.0) GOTO 106
        IF(ICBUND(JJ,II,KK).EQ.0) GOTO 105
        IF(MIXELM.EQ.3.AND.BUFF(JJ,II,KK).LE.DCHMOC) GOTO 105
        IF(NPCHEK(JJ,II,KK).GT.NPMAX) GOTO 105

C
C--UPDATE PARTICLE CONCENTRATION
        IF(ICBUND(JJ,II,KK).LT.0) THEN
          CNPT(NN,1)=COLD(JJ,II,KK)
        ELSE
          DCTMP=COLD(JJ,II,KK)-CADV(JJ,II,KK)
          CNPT(NN,1)=CNPT(NN,1)+DCTMP
          IF(CNPT(NN,1).LT.0) THEN
            NPCHEK(JJ,II,KK)=NPCHEK(JJ,II,KK)-1000
            GOTO 100
          ENDIF
        ENDIF
        GOTO 100
C
C--REMOVE PARTICLE AND REARRANGE PARTICLE ARRAYS TO SAVE STORAGE
  105   NPCHEK(JJ,II,KK)=0
  106   NLAST=NCOUNT-NRC
        IF(NN.LT.NLAST) THEN
          IF(NCOL.GT.1) THEN
            XP(NN)=XP(NLAST)
            INDEXX(NN)=INDEXX(NLAST)
          ENDIF
          IF(NROW.GT.1) THEN
            YP(NN)=YP(NLAST)
            INDEXY(NN)=INDEXY(NLAST)
          ENDIF
          IF(NLAY.GT.1) THEN
            ZP(NN)=ZP(NLAST)
            INDEXZ(NN)=INDEXZ(NLAST)
          ENDIF
          CNPT(NN,1)=CNPT(NLAST,1)
          CNPT(NN,2)=CNPT(NLAST,2)
        ENDIF
        NRC=NRC+1
C
  100 ENDDO
C
C--UPDATE NUMBER OF PARTICLES AFTER DELETION
      NCOUNT=NCOUNT-NRC
C
C--SAVE TOTAL NUMBER OF PARTICLES BEFORE INSERTION
      NPALL=NCOUNT
C
C--INSERT NEW PARTICLES IF NECESSARY.
      DO K=1,NLAY
      DO I=1,NROW
      DO J=1,NCOL
C
C--SKIP IF AT INACTIVE CELL
C--OR CONCENTRATION GRADIENT IS LESS THAN SPECIFIED VALUE
C--OR NUMBER OF PARTICLES IS GREATER THAN SPECIFIED MINIMUM
        IF(ICBUND(J,I,K).EQ.0) GOTO 220
        IF(MIXELM.EQ.3.AND.BUFF(J,I,K).LE.DCHMOC) GOTO 220
        IF(NPCHEK(J,I,K).GT.NPMIN) GOTO 220
        IF(NPCHEK(J,I,K).LT.0.AND.NPCHEK(J,I,K)+1000.GT.NPMIN) GOTO 220
C
C--CALCULATE NUMBER OF PARTICLES TO BE INSERTED
C--BASED UPON THE CONCENTRATION GRADIENT WITH ADJACENT CELLS
        IF(BUFF(J,I,K).LE.DCEPS) THEN
          NPCELL=NPL
        ELSE
          NPCELL=NPH
        ENDIF
        IF(ICBUND(J,I,K).GT.1020.AND.ICBUND(J,I,K).LT.1030) THEN
          NPCELL=NPCELL*SRMULT
        ENDIF
C
C--INSERT [NADD] NEW PARTICLES WITH CERTAIN PATTERN OR RANDOMLY
        NADD=NPCELL
        IF(NADD.LE.0) GOTO 220
        NCOLD=NCOUNT
        IF(NPLANE.GT.0) THEN
          CALL GENPTN(NCOL,NROW,NLAY,MXPART,NCOUNT,NPCHEK,J,I,K,
     &     XP,YP,ZP,CNPT,DELR,DELC,DZ,DH,PRSITY,
     &     XBC,YBC,ZBC,COLD,NADD,NPLANE)
        ELSE
          CALL GENPTR(NCOL,NROW,NLAY,MXPART,NCOUNT,NPCHEK,J,I,K,
     &     XP,YP,ZP,CNPT,DELR,DELC,DZ,DH,PRSITY,
     &     XBC,YBC,ZBC,COLD,NADD,ISEED)
        ENDIF
        IF(NCOUNT.GT.MXPART) GOTO 999
        DO NP=NCOLD+1,NCOUNT
          IF(NCOL.GT.1) INDEXX(NP)=J
          IF(NROW.GT.1) INDEXY(NP)=I
          IF(NLAY.GT.1) INDEXZ(NP)=K
        ENDDO
C
  220 ENDDO
      ENDDO
      ENDDO
C
C--UPDATE NUMBER OF TOTAL PARTICLES AFTER INSERTION
      NPINS=NCOUNT-NPALL
      NPALL=NCOUNT
C
C--CHECK WHETHER TOTAL NUMBER OF PARTICLES
C--HAS EXCEEDED THE SPECIFIED MAXIMUM.  IF SO STOP
 999  IF(NCOUNT.GT.MXPART) THEN
        WRITE(*,1000) MXPART,NCOUNT
        CALL USTOP(' ')
      ENDIF
1000  FORMAT(/1X,'ERROR: MAXIMUM NUMBER OF PARTICLES ALLOWED',
     & ' [MXPART] IS',I10/
     & 1X,'       ACTUAL NUMBER OF PARTICLES NEEDED AT THIS POINT',
     & I10/1X,'INCREASE VALUE OF [MXPART] IN ADVECTION INPUT FILE')
C
C--NORMAL RETURN
      RETURN
      END
C
C
      SUBROUTINE GENPTR(NCOL,NROW,NLAY,MXPART,NCOUNT,NPCHEK,JJ,II,KK,
     & XP,YP,ZP,CNPT,DELR,DELC,DZ,DH,PRSITY,
     & XBC,YBC,ZBC,COLD,NADD,ISEED)
C ********************************************************************
C THIS SUBROUTINE INSERTS [NADD] NEW PARTICLES AT CELL (JJ,II,KK)
C RANDOMLY INSIDE THE CELL BLOCK.
C ********************************************************************
C last modified: 02-15-2005
C
      IMPLICIT  NONE
      INTEGER   NCOL,NROW,NLAY,JJ,II,KK,N,NP,NCOUNT,MXPART,NPCHEK,
     &          NADD,ISEED
      REAL      XP,YP,ZP,XBC,YBC,ZBC,DELC,DELR,DZ,DH,CNPT,COLD,RAN0,
     &          PRSITY
      DIMENSION XP(MXPART),YP(MXPART),ZP(MXPART),CNPT(MXPART,2),
     &          DELR(NCOL),XBC(NCOL),DELC(NROW),YBC(NROW),
     &          ZBC(NCOL,NROW,NLAY),DZ(NCOL,NROW,NLAY),
     &          DH(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          PRSITY(NCOL,NROW,NLAY),NPCHEK(NCOL,NROW,NLAY)
C
C--SAVE NUMBER OF PARTICLES BEFORE INSERTION
      NP=NCOUNT
C
C--RETURN IF NUMBER OF PARTICLES AFTER INSERTION WILL CAUSE
C--TOTAL NUMBER OF PARTICLES TO EXCEED PREDEFINED MAXIMUM.
      NCOUNT=NP+NADD
      NPCHEK(JJ,II,KK)=NPCHEK(JJ,II,KK)+NADD
      IF(NCOUNT.GT.MXPART) RETURN
C
C--RANDOMLY INSERT NEW PARTICLES
      DO N=NP+1,NCOUNT
        IF(NCOL.GT.1) XP(N)=XBC(JJ)+(RAN0(ISEED)-0.5)*DELR(JJ)
        IF(NROW.GT.1) YP(N)=YBC(II)+(RAN0(ISEED)-0.5)*DELC(II)
        IF(NLAY.GT.1) ZP(N)=ZBC(JJ,II,KK)+0.5*DZ(JJ,II,KK)
     &   -RAN0(ISEED)*DH(JJ,II,KK)
        CNPT(N,1)=COLD(JJ,II,KK)
        CNPT(N,2)=DELR(JJ)*DELC(II)*DH(JJ,II,KK)*PRSITY(JJ,II,KK)
      ENDDO
C
      RETURN
      END
C
C
      FUNCTION RAN0(IDUM)
C ******************************************************************
C THIS FUNCTION RETURNS A RANDOM NUMBER BETWEEN 0.0 AND 1.0.
C SET IDUM TO ANY NONZERO INTEGER TO INITIALIZE THE SEQUENCE.
C [MODIFIED FROM PRESS ET AL. (1992)].
C ******************************************************************
C last modified: 02-15-2005
C
      IMPLICIT  NONE
      INTEGER   IDUM,IA,IM,IQ,IR,MASK,K
      REAL      RAN0,AM
      PARAMETER (IA=16807,IM=2147483647,AM=1./IM,IQ=127773,IR=2836,
     &          MASK=123459876)
C
      IDUM=IEOR(IDUM,MASK)
      K=IDUM/IQ
      IDUM=IA*(IDUM-K*IQ)-IR*K
      IF(IDUM.LT.0) IDUM=IDUM+IM
      RAN0=AM*IDUM
      IDUM=IEOR(IDUM,MASK)
C
      RETURN
      END
C
C
      SUBROUTINE GENPTN(NCOL,NROW,NLAY,MXPART,NCOUNT,NPCHEK,JJ,II,KK,
     & XP,YP,ZP,CNPT,DELR,DELC,DZ,DH,PRSITY,
     & XBC,YBC,ZBC,COLD,NADD,NPLANE)
C ********************************************************************
C THIS SUBROUTINE INSERTS NEW PARTICLES AT CELL (JJ,II,KK) WITH
C A FIXED PATTERN BASED ON THE VALUES OF [NADD] AND [NPLANE].
C ********************************************************************
C last modified: 02-15-2005
C
      IMPLICIT  NONE
      INTEGER   NCOL,NROW,NLAY,JJ,II,KK,N,NP,NCOUNT,MXPART,NPCHEK,
     &          NADD,NPLANE
      REAL      XP,YP,ZP,XBC,YBC,ZBC,DELR,DELC,DZ,DH,
     &          PRSITY,CNPT,COLD,UPFACE
      DIMENSION XP(MXPART),YP(MXPART),ZP(MXPART),CNPT(MXPART,2),
     &          DELR(NCOL),XBC(NCOL),DELC(NROW),YBC(NROW),
     &          COLD(NCOL,NROW,NLAY),DZ(NCOL,NROW,NLAY),
     &          DH(NCOL,NROW,NLAY),ZBC(NCOL,NROW,NLAY),
     &          PRSITY(NCOL,NROW,NLAY),NPCHEK(NCOL,NROW,NLAY)
C
C--CALCULATE NUMBER OF PARTICLES TO BE PLACED PER "PLANE"
      NADD=NADD/NPLANE
C
C--[NADD] MUST BE ONE OF THESE VALUES: 1, 4, 5, 8, 9 OR 16.
C--IF NOT, SET IT TO ONE OF THEM
      IF(NADD.GT.1.AND.NADD.LT.4) NADD=4
      IF(NADD.GT.5.AND.NADD.LT.8) NADD=8
      IF(NADD.GT.9.AND.NADD.LT.16) NADD=9
      IF(NADD.GT.16) NADD=16
C
C--SAVE NUMBER OF PARTICLES BEFORE INSERTION
      NP=NCOUNT
C
C--RETURN IF NUMBER OF PARTICLES AFTER INSERTION WILL CAUSE
C--TOTAL NUMBER OF PARTICLES TO EXCEED PREDEFINED MAXIMUM.
      NCOUNT=NP+NADD*NPLANE
      NPCHEK(JJ,II,KK)=NPCHEK(JJ,II,KK)+NADD*NPLANE
      IF(NCOUNT.GT.MXPART) RETURN
C
C-ASSIGN PARTICLE CONCENTRATION AND COORDINATES
      DO N=NP+1,NCOUNT
        CNPT(N,1)=COLD(JJ,II,KK)
        CNPT(N,2)=DELR(JJ)*DELC(II)*DH(JJ,II,KK)*PRSITY(JJ,II,KK)
      ENDDO
      UPFACE=ZBC(JJ,II,KK)+0.5*DZ(JJ,II,KK)-DH(JJ,II,KK)
C
      DO N=1,NPLANE
C
C--PLACE 1 PARTICLE AT NODAL CENTER IF [NADD]=1, 5, OR 9
      IF(NADD.EQ.1.OR.NADD.EQ.5.OR.NADD.EQ.9) THEN
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)
        IF(NROW.GT.1) YP(NP)=YBC(II)
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
      ENDIF
C
C--PLACE 4 PARTICLES IN THE CELL IF [NADD]=4, 5, 8, OR 9
      IF(NADD.GT.1.AND.NADD.LT.16) THEN
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)/4.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)/4.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)/4.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)/4.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)/4.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)/4.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)/4.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)/4.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
      ENDIF
C
C--ADD 4 MORE PARTICLES IN THE CELL IF [NADD]=8, OR 9
      IF(NADD.EQ.8.OR.NADD.EQ.9) THEN
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)/4.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)/4.
        IF(NROW.GT.1) YP(NP)=YBC(II)
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)/4.
        IF(NROW.GT.1) YP(NP)=YBC(II)
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)/4.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
      ENDIF
C
C--PLACE 16 PARTICLES IN THE CELL IF [NADD]=16
      IF(NADD.EQ.16) THEN
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)*3./8.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)*3./8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)/8.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)*3/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)/8.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)*3./8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)*3./8.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)*3./8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)*3./8.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)/8.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)/8.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)*3./8.
        IF(NROW.GT.1) YP(NP)=YBC(II)-DELC(II)/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)*3./8.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)/8.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)/8.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)*3./8.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)*3./8.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)*3./8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)-DELR(JJ)/8.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)*3/8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)/8.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)*3./8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
        NP=NP+1
        IF(NCOL.GT.1) XP(NP)=XBC(JJ)+DELR(JJ)*3./8.
        IF(NROW.GT.1) YP(NP)=YBC(II)+DELC(II)*3./8.
        IF(NLAY.GT.1) ZP(NP)=UPFACE+N*DH(JJ,II,KK)/(NPLANE+1)
      ENDIF
C
      ENDDO
C
C--NORMAL RETURN
      RETURN
      END
C
C
      FUNCTION SADV5Q(NCOL,NROW,NLAY,JJ,II,KK,ICBUND,DELR,DELC,DH,
     & COLD,QX,QY,QZ,DTRANS,NADVFD)
C *******************************************************************
C THIS FUNCTION COMPUTES ADVECTIVE MASS FLUX BETWEEN CELL (JJ,II,KK)
C AND THE SURROUNDING CELLS DURING TIME INCREMENT DTRANS.  MASS IS
C MOVING OUT OF THE CELL IF SADV5Q > 0, INTO THE CELL IF SADV5Q < 0.
C NADVFD=1 IS FOR THE UPSTREAM SCHEME; NADVFD=2 IS FOR THE CENTRAL
C WEIGHTING SCHEME.
C *******************************************************************
C last modified: 02-15-2005
C
      USE       MIN_SAT                                        !# LINE 1589 ADV
      IMPLICIT  NONE
      INTEGER   ICBUND,NCOL,NROW,NLAY,JJ,II,KK,NADVFD
      REAL      SADV5Q,COLD,QX,QY,QZ,DELR,DELC,DH,AREA,DTRANS,QCTMP,
     &          WW,THKSAT,ALPHA,CTMP
      DIMENSION ICBUND(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          QX(NCOL,NROW,NLAY),QY(NCOL,NROW,NLAY),
     &          QZ(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),
     &          DH(NCOL,NROW,NLAY)
C
C--SET QCTMP = 0 FOR ACCUMULATING Q*C*DTRANS IN ALL FACES
      QCTMP=0.
C
C--CALCULATE IN THE Z DIRECTION
      IF(NLAY.LT.2) GOTO 410
      AREA=DELR(JJ)*DELC(II)
C--TOP FACE
      IF(KK.GT.1) THEN
        IF(ICBUND(JJ,II,KK-1).NE.0) THEN
          WW=DH(JJ,II,KK)/(DH(JJ,II,KK-1)+DH(JJ,II,KK))
          ALPHA=0.
          IF(QZ(JJ,II,KK-1).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK-1)*ALPHA + COLD(JJ,II,KK)*(1.-ALPHA)
          QCTMP=QCTMP-QZ(JJ,II,KK-1)*CTMP*AREA*DTRANS
        ENDIF
      ENDIF
C--BOTTOM FACE
      IF(KK.LT.NLAY) THEN
        IF(ICBUND(JJ,II,KK+1).NE.0) THEN
          WW=DH(JJ,II,KK+1)/(DH(JJ,II,KK)+DH(JJ,II,KK+1))
          ALPHA=0.
          IF(QZ(JJ,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK)*ALPHA + COLD(JJ,II,KK+1)*(1.-ALPHA)
          QCTMP=QCTMP+QZ(JJ,II,KK)*CTMP*AREA*DTRANS
        ENDIF
      ENDIF
C
C--CALCULATE IN THE Y DIRECTION
  410 IF(NROW.LT.2) GOTO 420
C--BACK FACE
      IF(II.GT.1) THEN
        IF(ICBUND(JJ,II-1,KK).NE.0) THEN
          WW=DELC(II)/(DELC(II)+DELC(II-1))
          THKSAT=DH(JJ,II-1,KK)*WW+DH(JJ,II,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN                               !# LINE 1635 ADV
            THKSAT=ABS(DH(JJ,II-1,KK))*WW+ABS(DH(JJ,II,KK))*(1.-WW) !# LINE 1636 ADV
          ENDIF                                                     !# LINE 1637 ADV
          AREA=DELR(JJ)*THKSAT
          ALPHA=0.
          IF(QY(JJ,II-1,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II-1,KK)*ALPHA + COLD(JJ,II,KK)*(1.-ALPHA)
          QCTMP=QCTMP-QY(JJ,II-1,KK)*CTMP*AREA*DTRANS
        ENDIF
      ENDIF
C--FRONT FACE
      IF(II.LT.NROW) THEN
        IF(ICBUND(JJ,II+1,KK).NE.0) THEN
          WW=DELC(II+1)/(DELC(II+1)+DELC(II))
          THKSAT=DH(JJ,II,KK)*WW+DH(JJ,II+1,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN                               !# LINE 1651 ADV
            THKSAT=ABS(DH(JJ,II,KK))*WW+ABS(DH(JJ,II+1,KK))*(1.-WW) !# LINE 1652 ADV
          ENDIF                                                     !# LINE 1653 ADV
          AREA=DELR(JJ)*THKSAT
          ALPHA=0.
          IF(QY(JJ,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK)*ALPHA + COLD(JJ,II+1,KK)*(1.-ALPHA)
          QCTMP=QCTMP+QY(JJ,II,KK)*CTMP*AREA*DTRANS
        ENDIF
      ENDIF
C
C--CALCULATE IN THE X DIRECTION
  420 IF(NCOL.LT.2) GOTO 430
C--LEFT FACE
      IF(JJ.GT.1) THEN
        IF(ICBUND(JJ-1,II,KK).NE.0) THEN
          WW=DELR(JJ)/(DELR(JJ)+DELR(JJ-1))
          THKSAT=DH(JJ-1,II,KK)*WW+DH(JJ,II,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN                               !# LINE 1670 ADV
            THKSAT=ABS(DH(JJ-1,II,KK))*WW+ABS(DH(JJ,II,KK))*(1.-WW) !# LINE 1671 ADV
          ENDIF                                                     !# LINE 1672 ADV
          AREA=DELC(II)*THKSAT
          ALPHA=0.
          IF(QX(JJ-1,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ-1,II,KK)*ALPHA + COLD(JJ,II,KK)*(1.-ALPHA)
          QCTMP=QCTMP-QX(JJ-1,II,KK)*CTMP*AREA*DTRANS
        ENDIF
      ENDIF
C--RIGHT FACE
      IF(JJ.LT.NCOL) THEN
        IF(ICBUND(JJ+1,II,KK).NE.0) THEN
          WW=DELR(JJ+1)/(DELR(JJ+1)+DELR(JJ))
          THKSAT=DH(JJ,II,KK)*WW+DH(JJ+1,II,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN                               !# LINE 1686
            THKSAT=ABS(DH(JJ,II,KK))*WW+ABS(DH(JJ+1,II,KK))*(1.-WW) !# LINE 1687
          ENDIF                                                     !# LINE 1688
          AREA=DELC(II)*THKSAT
          ALPHA=0.
          IF(QX(JJ,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK)*ALPHA + COLD(JJ+1,II,KK)*(1.-ALPHA)
          QCTMP=QCTMP+QX(JJ,II,KK)*CTMP*AREA*DTRANS
        ENDIF
      ENDIF
C
C--ASSIGN QCTMP TO THE FUNCTION AND RETURN
  430 SADV5Q=QCTMP
C
      RETURN
      END
C
C
      SUBROUTINE SADV5F(NCOL,NROW,NLAY,ICBUND,DELR,DELC,DH,PRSITY,
     & CNEW,COLD,QX,QY,QZ,RETA,DTRANS,RMASIO)
C *********************************************************************
C THIS SUBROUTINE SOLVES THE ADVECTION TERM WITH THE UPSTREAM WEIGHTING
C FINITE DIFFERENCE SCHEME.
C *********************************************************************
C last modified: 02-15-2005
C
      USE       MIN_SAT                                        !# LINE 1713 ADV
      IMPLICIT  NONE
      INTEGER   ICBUND,NCOL,NROW,NLAY,JJ,II,KK
      REAL      COLD,QX,QY,QZ,DELR,DELC,DH,CNEW,PRSITY,
     &          RETA,RMASIO,QCTMP,DTRANS,AREA,THKSAT,WW
      DIMENSION ICBUND(NCOL,NROW,NLAY),QX(NCOL,NROW,NLAY),
     &          QY(NCOL,NROW,NLAY),QZ(NCOL,NROW,NLAY),DELR(NCOL),
     &          DELC(NROW),DH(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          CNEW(NCOL,NROW,NLAY),RETA(NCOL,NROW,NLAY),
     &          PRSITY(NCOL,NROW,NLAY),RMASIO(122,2)
C
C--LOOP THROUGH ALL CELLS
      DO KK=1,NLAY
      DO II=1,NROW
      DO JJ=1,NCOL
C
        IF(ICBUND(JJ,II,KK).EQ.0) CYCLE
C
C--SET QCTMP = 0 FOR ACCUMULATING Q*C*DTRANS IN ALL FACES
        QCTMP=0.
C
C--CALCULATE IN THE Z DIRECTION
        IF(NLAY.LT.2) GOTO 410
        AREA=DELR(JJ)*DELC(II)
C--TOP FACE
        IF(KK.GT.1) THEN
          IF(ICBUND(JJ,II,KK-1).NE.0) THEN
            IF(QZ(JJ,II,KK-1).GT.0) THEN
              QCTMP=QCTMP-QZ(JJ,II,KK-1)*COLD(JJ,II,KK-1)*AREA*DTRANS
            ELSE
              QCTMP=QCTMP-QZ(JJ,II,KK-1)*COLD(JJ,II,KK)*AREA*DTRANS
            ENDIF
          ENDIF
        ENDIF
C--BOTTOM FACE
        IF(KK.LT.NLAY) THEN
          IF(ICBUND(JJ,II,KK+1).NE.0) THEN
            IF(QZ(JJ,II,KK).GT.0) THEN
              QCTMP=QCTMP+QZ(JJ,II,KK)*COLD(JJ,II,KK)*AREA*DTRANS
            ELSE
              QCTMP=QCTMP+QZ(JJ,II,KK)*COLD(JJ,II,KK+1)*AREA*DTRANS
            ENDIF
          ENDIF
        ENDIF
C
C--CALCULATE IN THE Y DIRECTION
  410   IF(NROW.LT.2) GOTO 420
C--BACK FACE
        IF(II.GT.1) THEN
          IF(ICBUND(JJ,II-1,KK).NE.0) THEN
            WW=DELC(II)/(DELC(II)+DELC(II-1))
            THKSAT=DH(JJ,II-1,KK)*WW+DH(JJ,II,KK)*(1.-WW)
            IF(DOMINSAT.EQ..TRUE.) THEN                               !# LINE 1760 ADV
              THKSAT=ABS(DH(JJ,II-1,KK))*WW+ABS(DH(JJ,II,KK))*(1.-WW) !# LINE 1761 ADV
            ENDIF                                                     !# LINE 1762 ADV
            AREA=DELR(JJ)*THKSAT
            IF(QY(JJ,II-1,KK).GT.0) THEN
              QCTMP=QCTMP-QY(JJ,II-1,KK)*COLD(JJ,II-1,KK)*AREA*DTRANS
            ELSE
              QCTMP=QCTMP-QY(JJ,II-1,KK)*COLD(JJ,II,KK)*AREA*DTRANS
            ENDIF
          ENDIF
        ENDIF
C--FRONT FACE
        IF(II.LT.NROW) THEN
          IF(ICBUND(JJ,II+1,KK).NE.0) THEN
            WW=DELC(II+1)/(DELC(II+1)+DELC(II))
            THKSAT=DH(JJ,II,KK)*WW+DH(JJ,II+1,KK)*(1.-WW)
            IF(DOMINSAT.EQ..TRUE.) THEN                               !# LINE 1774 ADV
              THKSAT=ABS(DH(JJ,II,KK))*WW+ABS(DH(JJ,II+1,KK))*(1.-WW) !# LINE 1775 ADV
            ENDIF                                                     !# LINE 1776 ADV
            AREA=DELR(JJ)*THKSAT
            IF(QY(JJ,II,KK).GT.0) THEN
              QCTMP=QCTMP+QY(JJ,II,KK)*COLD(JJ,II,KK)*AREA*DTRANS
            ELSE
              QCTMP=QCTMP+QY(JJ,II,KK)*COLD(JJ,II+1,KK)*AREA*DTRANS
            ENDIF
          ENDIF
        ENDIF
C
C--CALCULATE IN THE X DIRECTION
  420 IF(NCOL.LT.2) GOTO 430
C--LEFT FACE
        IF(JJ.GT.1) THEN 
          IF(ICBUND(JJ-1,II,KK).NE.0) THEN
            WW=DELR(JJ)/(DELR(JJ)+DELR(JJ-1))
            THKSAT=DH(JJ-1,II,KK)*WW+DH(JJ,II,KK)*(1.-WW)
            IF(DOMINSAT.EQ..TRUE.) THEN                               !# LINE 1791 ADV
              THKSAT=ABS(DH(JJ-1,II,KK))*WW+ABS(DH(JJ,II,KK))*(1.-WW) !# LINE 1792 ADV
            ENDIF                                                     !# LINE 1793 ADV
            AREA=DELC(II)*THKSAT
            IF(QX(JJ-1,II,KK).GT.0) THEN
              QCTMP=QCTMP-QX(JJ-1,II,KK)*COLD(JJ-1,II,KK)*AREA*DTRANS
            ELSE
              QCTMP=QCTMP-QX(JJ-1,II,KK)*COLD(JJ,II,KK)*AREA*DTRANS
            ENDIF
          ENDIF
        ENDIF
C--RIGHT FACE
        IF(JJ.LT.NCOL) THEN
          IF(ICBUND(JJ+1,II,KK).NE.0) THEN
            WW=DELR(JJ+1)/(DELR(JJ+1)+DELR(JJ))
            THKSAT=DH(JJ,II,KK)*WW+DH(JJ+1,II,KK)*(1.-WW)
            IF(DOMINSAT.EQ..TRUE.) THEN                               !# LINE 1805 ADV
              THKSAT=ABS(DH(JJ,II,KK))*WW+ABS(DH(JJ+1,II,KK))*(1.-WW) !# LINE 1806 ADV
            ENDIF                                                     !# LINE 1807 ADV
            AREA=DELC(II)*THKSAT
            IF(QX(JJ,II,KK).GT.0) THEN
              QCTMP=QCTMP+QX(JJ,II,KK)*COLD(JJ,II,KK)*AREA*DTRANS
            ELSE
              QCTMP=QCTMP+QX(JJ,II,KK)*COLD(JJ+1,II,KK)*AREA*DTRANS
            ENDIF
          ENDIF
        ENDIF
  430 CONTINUE
C
C--UPDATE CONCENTRATION AT ACTIVE CELL AND
C--SAVE MASS INTO OR OUT OF CONSTANT-CONCENTRATION CELL
      IF(ICBUND(JJ,II,KK).LT.0) THEN
        IF(QCTMP.GT.0) THEN
          RMASIO(6,1)=RMASIO(6,1)+QCTMP
        ELSE
          RMASIO(6,2)=RMASIO(6,2)+QCTMP
        ENDIF
      ELSEIF(ICBUND(JJ,II,KK).GT.0) THEN
        CNEW(JJ,II,KK)=COLD(JJ,II,KK)-QCTMP/(DELR(JJ)*DELC(II)*
     &   DH(JJ,II,KK)*PRSITY(JJ,II,KK)*RETA(JJ,II,KK))
      ENDIF
C
      ENDDO
      ENDDO
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE VRK4(P,V,DT,J0,I0,K0,NCOL,NROW,NLAY,ICBUND,
     & DELR,DELC,DZ,XBC,YBC,ZBC,DH,PRSITY,QX,QY,QZ,RETA)
C *******************************************************************
C THIS SUBROUTINE CALCULATES WEIGHTED VELOCITY NEEDED FOR MOVING
C PARTICLE P OVER DT USING THE 4TH-ORDER RUNGE-KUTTA SOLUTION.
C *******************************************************************
C last modified: 02-15-2005
C
      IMPLICIT  NONE
      INTEGER   NCOL,NROW,NLAY,ICBUND,JP,IP,KP,J0,I0,K0,J,I,K,N
      REAL      P,PT,V,VM,VT,DELR,DELC,DZ,XBC,YBC,ZBC,DH,PRSITY,
     &          QX,QY,QZ,DTHALF,DT,RETA,HORIGN,XMAX,YMAX,ZMAX,
     &          ALPHA,UPFACE
      LOGICAL   UNIDX,UNIDY,UNIDZ
      DIMENSION ICBUND(NCOL,NROW,NLAY),
     &          DELR(NCOL),DELC(NROW),DZ(NCOL,NROW,NLAY),
     &          XBC(NCOL),YBC(NROW),ZBC(NCOL,NROW,NLAY),
     &          DH(NCOL,NROW,NLAY),PRSITY(NCOL,NROW,NLAY),
     &          QX(NCOL,NROW,NLAY),QY(NCOL,NROW,NLAY),
     &          QZ(NCOL,NROW,NLAY),RETA(NCOL,NROW,NLAY),
     &          P(3),V(3),PT(3),VM(3),VT(3)
      COMMON /PD/HORIGN,XMAX,YMAX,ZMAX,UNIDX,UNIDY,UNIDZ
C
C--INITIALIZE
      DTHALF=DT*0.5
      JP=J0
      IP=I0
      KP=K0
      DO N=1,3
        VT(N)=0.
        VM(N)=0.
      ENDDO
C
C--GET POSITION OF FIRST TRIAL MIDPOINT
      DO N=1,3
        PT(N)=P(N)+DTHALF*V(N)
      ENDDO
C
C--LOCATE INDICES OF FIRST TRIAL MIDPOINT
      IF(UNIDX) THEN
        JP=INT(PT(1)/DELR(1))+1
        IF(JP.LT.1) JP=1
        IF(JP.GT.NCOL) JP=NCOL
      ELSE
        JP=NCOL
        DO J=1,NCOL
          IF(PT(1).LT.XBC(J)+0.5*DELR(J)) THEN
            JP=J
            GOTO 11
          ENDIF
        ENDDO
      ENDIF
   11 IF(UNIDY) THEN
        IP=INT(PT(2)/DELC(1))+1
        IF(IP.LT.1) IP=1
        IF(IP.GT.NROW) IP=NROW
      ELSE
        IP=NROW
        DO I=1,NROW
          IF(PT(2).LT.YBC(I)+0.5*DELC(I)) THEN
            IP=I
            GOTO 12
          ENDIF
        ENDDO
      ENDIF
   12 IF(UNIDZ) THEN
        KP=INT(PT(3)/DZ(JP,IP,1))+1
        IF(KP.LT.1) KP=1
        IF(KP.GT.NLAY) KP=NLAY
      ELSE
        KP=NLAY
        DO K=1,NLAY
          IF(PT(3).LT.ZBC(JP,IP,K)+0.5*DZ(JP,IP,K)) THEN
            KP=K
            GOTO 13
          ENDIF
        ENDDO
      ENDIF
   13 IF(ICBUND(JP,IP,KP).EQ.0) GOTO 14
C
C--GET VELOCITY AT FIRST TRIAL MIDPOINT
      IF(NCOL.GT.1) THEN
        ALPHA=(PT(1)-XBC(JP)+0.5*DELR(JP))/DELR(JP)
        IF(JP-1.LT.1) THEN
          VT(1)=ALPHA*QX(JP,IP,KP)/(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ELSE
          VT(1)=(ALPHA*QX(JP,IP,KP)+(1.-ALPHA)*QX(JP-1,IP,KP))
     &     /(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ENDIF
      ENDIF
      IF(NROW.GT.1) THEN
        ALPHA=(PT(2)-YBC(IP)+0.5*DELC(IP))/DELC(IP)
        IF(IP-1.LT.1) THEN
          VT(2)=ALPHA*QY(JP,IP,KP)/(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ELSE
          VT(2)=(ALPHA*QY(JP,IP,KP)+(1.-ALPHA)*QY(JP,IP-1,KP))
     &     /(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ENDIF
      ENDIF
      IF(NLAY.GT.1) THEN
        UPFACE=ZBC(JP,IP,KP)+0.5*DZ(JP,IP,KP)-DH(JP,IP,KP)
        ALPHA=(PT(3)-UPFACE)/DH(JP,IP,KP)
        IF(ALPHA.LT.0) ALPHA=0
        IF(KP-1.LT.1) THEN
          VT(3)=ALPHA*QZ(JP,IP,KP)/(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ELSE
          VT(3)=(ALPHA*QZ(JP,IP,KP)+(1.-ALPHA)*QZ(JP,IP,KP-1))
     &     /(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ENDIF
      ENDIF
C
C--GET POSITION OF SECOND TRIAL MIDPOINT
   14 DO N=1,3
        PT(N)=P(N)+DTHALF*VT(N)
      ENDDO
C
C--LOCATE INDICES OF SECOND TRIAL MIDPOINT
      IF(UNIDX) THEN
        JP=INT(PT(1)/DELR(1))+1
        IF(JP.LT.1) JP=1
        IF(JP.GT.NCOL) JP=NCOL
      ELSE
        JP=NCOL
        DO J=1,NCOL
          IF(PT(1).LT.XBC(J)+0.5*DELR(J)) THEN
            JP=J
            GOTO 21
          ENDIF
        ENDDO
      ENDIF
   21 IF(UNIDY) THEN
        IP=INT(PT(2)/DELC(1))+1
        IF(IP.LT.1) IP=1
        IF(IP.GT.NROW) IP=NROW
      ELSE
        IP=NROW
        DO I=1,NROW
          IF(PT(2).LT.YBC(I)+0.5*DELC(I)) THEN
            IP=I
            GOTO 22
          ENDIF
        ENDDO
      ENDIF
   22 IF(UNIDZ) THEN
        KP=INT(PT(3)/DZ(JP,IP,1))+1
        IF(KP.LT.1) KP=1
        IF(KP.GT.NLAY) KP=NLAY
      ELSE
        KP=NLAY
        DO K=1,NLAY
          IF(PT(3).LT.ZBC(JP,IP,K)+0.5*DZ(JP,IP,K)) THEN
            KP=K
            GOTO 23
          ENDIF
        ENDDO
      ENDIF
   23 IF(ICBUND(JP,IP,KP).EQ.0) GOTO 24
C
C-GET VELOCITY AT SECOND TRIAL MIDPOINT
      IF(NCOL.GT.1) THEN
        ALPHA=(PT(1)-XBC(JP)+0.5*DELR(JP))/DELR(JP)
        IF(JP-1.LT.1) THEN
          VM(1)=ALPHA*QX(JP,IP,KP)/(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ELSE
          VM(1)=(ALPHA*QX(JP,IP,KP)+(1.-ALPHA)*QX(JP-1,IP,KP))
     &     /(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ENDIF
      ENDIF
      IF(NROW.GT.1) THEN
        ALPHA=(PT(2)-YBC(IP)+0.5*DELC(IP))/DELC(IP)
        IF(IP-1.LT.1) THEN
          VM(2)=ALPHA*QY(JP,IP,KP)/(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ELSE
          VM(2)=(ALPHA*QY(JP,IP,KP)+(1.-ALPHA)*QY(JP,IP-1,KP))
     &     /(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ENDIF
      ENDIF
      IF(NLAY.GT.1) THEN
        UPFACE=ZBC(JP,IP,KP)+0.5*DZ(JP,IP,KP)-DH(JP,IP,KP)
        ALPHA=(PT(3)-UPFACE)/DH(JP,IP,KP)
        IF(ALPHA.LT.0) ALPHA=0
        IF(KP-1.LT.1) THEN
          VM(3)=ALPHA*QZ(JP,IP,KP)/(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ELSE
          VM(3)=(ALPHA*QZ(JP,IP,KP)+(1.-ALPHA)*QZ(JP,IP,KP-1))
     &     /(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ENDIF
      ENDIF
C
C--GET POSITION OF TRIAL END POINT AND
C--ACCUMULATE VELOCITIES AT TWO TRIAL MIDPOINTS
   24 DO N=1,3
        PT(N)=P(N)+DT*VM(N)
        VM(N)=VT(N)+VM(N)
      ENDDO
C
C--LOCATE INDICES OF TRIAL END POINT
      IF(UNIDX) THEN
        JP=INT(PT(1)/DELR(1))+1
        IF(JP.LT.1) JP=1
        IF(JP.GT.NCOL) JP=NCOL
      ELSE
        JP=NCOL
        DO J=1,NCOL
          IF(PT(1).LT.XBC(J)+0.5*DELR(J)) THEN
            JP=J
            GOTO 31
          ENDIF
        ENDDO
      ENDIF
   31 IF(UNIDY) THEN
        IP=INT(PT(2)/DELC(1))+1
        IF(IP.LT.1) IP=1
        IF(IP.GT.NROW) IP=NROW
      ELSE
        IP=NROW
        DO I=1,NROW
          IF(PT(2).LT.YBC(I)+0.5*DELC(I)) THEN
            IP=I
            GOTO 32
          ENDIF
        ENDDO
      ENDIF
   32 IF(UNIDZ) THEN
        KP=INT(PT(3)/DZ(JP,IP,1))+1
        IF(KP.LT.1) KP=1
        IF(KP.GT.NLAY) KP=NLAY
      ELSE
        KP=NLAY
        DO K=1,NLAY
          IF(PT(3).LT.ZBC(JP,IP,K)+0.5*DZ(JP,IP,K)) THEN
            KP=K
            GOTO 33
          ENDIF
        ENDDO
      ENDIF
   33 IF(ICBUND(JP,IP,KP).EQ.0) GOTO 34
C
C--GET VELOCITY AT TRIAL END POINT
      IF(NCOL.GT.1) THEN
        ALPHA=(PT(1)-XBC(JP)+0.5*DELR(JP))/DELR(JP)
        IF(JP-1.LT.1) THEN
          VT(1)=ALPHA*QX(JP,IP,KP)/(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ELSE
          VT(1)=(ALPHA*QX(JP,IP,KP)+(1.-ALPHA)*QX(JP-1,IP,KP))
     &     /(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ENDIF
      ENDIF
      IF(NROW.GT.1) THEN
        ALPHA=(PT(2)-YBC(IP)+0.5*DELC(IP))/DELC(IP)
        IF(IP-1.LT.1) THEN
          VT(2)=ALPHA*QY(JP,IP,KP)/(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ELSE
          VT(2)=(ALPHA*QY(JP,IP,KP)+(1.-ALPHA)*QY(JP,IP-1,KP))
     &     /(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ENDIF
      ENDIF
      IF(NLAY.GT.1) THEN
        UPFACE=ZBC(JP,IP,KP)+0.5*DZ(JP,IP,KP)-DH(JP,IP,KP)
        ALPHA=(PT(3)-UPFACE)/DH(JP,IP,KP)
        IF(ALPHA.LT.0) ALPHA=0
        IF(KP-1.LT.1) THEN
          VT(3)=ALPHA*QZ(JP,IP,KP)/(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ELSE
          VT(3)=(ALPHA*QZ(JP,IP,KP)+(1.-ALPHA)*QZ(JP,IP,KP-1))
     &     /(PRSITY(JP,IP,KP)*RETA(JP,IP,KP))
        ENDIF
      ENDIF
C
C--GET FINAL WEIGHTED VELOCITY
   34 DO N=1,3
        V(N)=(V(N)+VT(N)+2.*VM(N))/6.
      ENDDO
C
C--NORMAL EXIT
      RETURN
      END
C
C
      SUBROUTINE ADV5FM(ICOMP,ICBUND,DH,QX,QY,QZ,A)
C *********************************************************************
C THIS SUBROUTINE FORMULATES COEFFICIENT MATRICES FOR THE ADVECTION
C TERM WITH THE OPTIONS OF UPSTREAM (NADVFD=1) AND CENTRAL (NADVFD=2)
C WEIGHTING.
C *********************************************************************
C last modified: 02-15-2005
C
      USE MT3DMS_MODULE, ONLY: NCOL,NROW,NLAY,MCOMP,DELR,DELC,NODES,
     &                         UPDLHS,NADVFD,
     &                         IUZFBND                              !edm
      USE MIN_SAT                                                   !# LINE 2127 ADV
C
      IMPLICIT  NONE
      INTEGER   ICBUND,ICOMP,J,I,K,N,NCR,IUPS,ICTRL
      REAL      QX,QY,QZ,DH,A,WW,THKSAT,AREA,ALPHA
      DIMENSION ICBUND(NODES,MCOMP),QX(NODES),QY(NODES),QZ(NODES),
     &          DH(NODES),A(NODES,*)
      PARAMETER (IUPS=1,ICTRL=2)
C
C--RETURN IF COEFF MATRICES ARE NOT TO BE UPDATED
      IF(.NOT.UPDLHS) GOTO 999
C
C--LOOP THROUGH ALL ACTIVE CELLS
      NCR=NROW*NCOL
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            N=(K-1)*NCR + (I-1)*NCOL + J
C
C--SKIP IF INACTIVE OR CONSTANT CELL
            IF(ICBUND(N,ICOMP).LE.0) CYCLE
C
C--------CALCULATE IN THE Z DIRECTION
            IF(NLAY.LT.2) GOTO 410
            AREA=DELR(J)*DELC(I)
C-----------TOP FACE
            IF(K.GT.1) THEN
                ALPHA = 0.
                IF(DH(N-NCR).EQ.0.AND.DH(N).EQ.0) GOTO 405          !edm
                IF(NADVFD.EQ.ICTRL) ALPHA=DH(N-NCR)/(DH(N-NCR)+DH(N))
                IF(NADVFD.EQ.IUPS.AND.QZ(N-NCR).LT.0.) ALPHA=1.0
                A(N,1)=A(N,1)+ALPHA*QZ(N-NCR)*AREA
                A(N,2)=A(N,2)+(1.-ALPHA)*QZ(N-NCR)*AREA
            ENDIF
C-----------BOTTOM FACE
  405       IF(K.LT.NLAY) THEN
                ALPHA = 0.
                IF(DH(N).EQ.0.AND.DH(N+NCR).EQ.0) GOTO 410          !edm
                IF(NADVFD.EQ.ICTRL) ALPHA=DH(N)/(DH(N)+DH(N+NCR))
                IF(NADVFD.EQ.IUPS.AND.QZ(N).LT.0.) ALPHA=1.0
                A(N,1)=A(N,1)-(1.-ALPHA)*QZ(N)*AREA
                A(N,3)=A(N,3)-ALPHA*QZ(N)*AREA
            ENDIF
C
C--------CALCULATE IN THE Y DIRECTION
  410       IF(NROW.LT.2) GOTO 420    
C-----------BACK FACE
            IF(I.GT.1) THEN
                WW=DELC(I)/(DELC(I)+DELC(I-1))
                THKSAT=DH(N-NCOL)*WW+DH(N)*(1.-WW)
                IF(DOMINSAT.EQ..TRUE.) THEN                    !# LINE 2179 ADV
                  THKSAT=ABS(DH(N-NCOL))*WW+ABS(DH(N))*(1.-WW) !# LINE 2180 ADV
                ENDIF                                          !# LINE 2181 ADV
                AREA=DELR(J)*THKSAT
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DELC(I-1)/(DELC(I-1)+DELC(I))
                IF(NADVFD.EQ.IUPS.AND.QY(N-NCOL).LT.0.) ALPHA=1.0
                A(N,1)=A(N,1)+ALPHA*QY(N-NCOL)*AREA
                A(N,4)=A(N,4)+(1.-ALPHA)*QY(N-NCOL)*AREA   
            ENDIF
C-----------FRONT FACE
            IF(I.LT.NROW) THEN
                WW=DELC(I+1)/(DELC(I+1)+DELC(I))
                THKSAT=DH(N)*WW+DH(N+NCOL)*(1.-WW)
                IF(DOMINSAT.EQ..TRUE.) THEN                    !# LINE 2193 ADV
                  THKSAT=ABS(DH(N))*WW+ABS(DH(N+NCOL))*(1.-WW) !# LINE 2194 ADV
                ENDIF                                          !# LINE 2195 ADV
                AREA=DELR(J)*THKSAT
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DELC(I)/(DELC(I)+DELC(I+1))
                IF(NADVFD.EQ.IUPS.AND.QY(N).LT.0.) ALPHA=1.0
                A(N,1)=A(N,1)-(1.-ALPHA)*QY(N)*AREA
                A(N,5)=A(N,5)-ALPHA*QY(N)*AREA
            ENDIF
C
C----------CALCULATE IN THE X DIRECTION
  420       IF(NCOL.LT.2) GOTO 430
C-----------LEFT FACE
            IF(J.GT.1) THEN
                WW=DELR(J)/(DELR(J)+DELR(J-1))
                THKSAT=DH(N-1)*WW+DH(N)*(1.-WW)
                IF(DOMINSAT.EQ..TRUE.) THEN                    !# LINE 2210 ADV
                  THKSAT=ABS(DH(N-1))*WW+ABS(DH(N))*(1.-WW)    !# LINE 2211 ADV
                ENDIF                                          !# LINE 2212 ADV
                AREA=DELC(I)*THKSAT
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DELR(J-1)/(DELR(J-1)+DELR(J))
                IF(NADVFD.EQ.IUPS.AND.QX(N-1).LT.0.) ALPHA=1.0
                A(N,1)=A(N,1)+ALPHA*QX(N-1)*AREA
                A(N,6)=A(N,6)+(1.-ALPHA)*QX(N-1)*AREA
            ENDIF
C-----------RIGHT FACE      
            IF(J.LT.NCOL) THEN
                WW=DELR(J+1)/(DELR(J+1)+DELR(J))
                THKSAT=DH(N)*WW+DH(N+1)*(1.-WW)
                IF(DOMINSAT.EQ..TRUE.) THEN                    !# LINE 2224 ADV
                  THKSAT=ABS(DH(N))*WW+ABS(DH(N+1))*(1.-WW)    !# LINE 2225 ADV
                ENDIF                                          !# LINE 2226 ADV 
                AREA=DELC(I)*THKSAT
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DELR(J)/(DELR(J)+DELR(J+1))
                IF(NADVFD.EQ.IUPS.AND.QX(N).LT.0.) ALPHA=1.0
                A(N,1)=A(N,1)-(1-ALPHA)*QX(N)*AREA
                A(N,7)=A(N,7)-ALPHA*QX(N)*AREA   
            ENDIF
C
  430       CONTINUE
          ENDDO
        ENDDO
      ENDDO
C
C--RETURN
  999 RETURN
      END
C
C
      SUBROUTINE ADV5BD(ICOMP,DTRANS,NTRANS,KPER,KSTP)              !# Amended (LINE 2247 ADV)
C **********************************************************************
C THIS SUBROUTINE CALCULATES MASS BUDGET OF CONSTANT-CONCENTRATION NODES
C DUE TO ADVECTION.
C **********************************************************************
C last modified: 02-15-2005
C
      USE MT3DMS_MODULE, ONLY:IOUT,NCOL,NROW,NLAY,MCOMP,NADVFD,ICBUND,
     &                        DELR,DELC,DH,QX,QY,QZ,CNEW,RMASIO,
     &                        PRTOUT,TIME2                          !# LINE 2247 ADV
      USE MIN_SAT                                                   !# LINE 2254 ADV
C
      IMPLICIT  NONE
      INTEGER   ICOMP,J,I,K
      REAL      DTRANS,SADV5Q,QCTMP
      REAL      SADV5Q2,SADV5Q3,QCTMP2,QCTMP3                       !# LINE 2259 ADV
      INTEGER   IDIR3                                               !# LINE 2260 ADV
C
      REAL, ALLOCATABLE :: C2DRY(:,:,:,:)                           !# LINE 2265 ADV
      REAL CTMPMAX                                                  !# LINE 2266 ADV
      INTEGER JMAX,IMAX,KMAX,ICNT0                                  !# LINE 2267 ADV
      CHARACTER*16 TEXT                                             !# LINE 2268 ADV
      CHARACTER FINDEX*30,FLNAME*50                                 !# LINE 2269 ADV
      INTEGER NTRANS,KSTP,KPER,IU                                   !# LINE 2270 ADV
C      REAL TIME2                                                    !# LINE 2271 ADV
      LOGICAL LOP                                                   !# LINE 2272 ADV
C
C--LOOP OVER ALL MODEL CELLS
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
C
C--SKIP IF NOT CONSTANT-CONCENTRATION CELLS
            IF(ICBUND(J,I,K,ICOMP).LT.0) THEN
              QCTMP=SADV5Q(NCOL,NROW,NLAY,J,I,K,
     &         ICBUND(1:NCOL,1:NROW,1:NLAY,ICOMP),
     &         DELR,DELC,DH,CNEW(1:NCOL,1:NROW,1:NLAY,ICOMP),
     &         QX,QY,QZ,DTRANS,NADVFD)
              IF(QCTMP.GT.0) THEN
                RMASIO(6,1,ICOMP)=RMASIO(6,1,ICOMP)+QCTMP
              ELSE
                RMASIO(6,2,ICOMP)=RMASIO(6,2,ICOMP)+QCTMP
              ENDIF
C                                                                      !# LINE 2288 ADV
C-----CALCULATE CELL-TO-CELL MASS FOR ALL ACTIVE CELLS                 !# LINE 2289 ADV
            ELSEIF(ICBUND(J,I,K,ICOMP).GT.0) THEN                      !# LINE 2290 ADV
              QCTMP3=0.                                                !# LINE 2291 ADV
              QCTMP2=0.                                                !# LINE 2292 ADV
C.............CALCULATE FLOW QCTMP2 OR FLOW INTO CELL; SET IDIR3=1     !# LINE 2293 ADV
              IDIR3=1                                                  !# LINE 2294 ADV
              QCTMP2=SADV5Q3(NCOL,NROW,NLAY,J,I,K,ICBUND(:,:,:,ICOMP), !# LINE 2295 ADV
     &         DELR,DELC,DH,CNEW(:,:,:,ICOMP),QX,QY,QZ,DTRANS,NADVFD,  !# LINE 2296 ADV
     &         IDIR3)                                                  !# LINE 2297 ADV
C.............CALCULATE FLOW QCTMP3 OR FLOW OUT OF CELL; SET IDIR3=2   !# LINE 2298 ADV
              IDIR3=2                                                  !# LINE 2299 ADV
              QCTMP3=SADV5Q3(NCOL,NROW,NLAY,J,I,K,ICBUND(:,:,:,ICOMP), !# LINE 2300 ADV
     &         DELR,DELC,DH,CNEW(:,:,:,ICOMP),QX,QY,QZ,DTRANS,NADVFD,  !# LINE 2301 ADV
     &         IDIR3)                                                  !# LINE 2302 ADV
              RMASIO(14,1,ICOMP)=RMASIO(14,1,ICOMP)+QCTMP3             !# LINE 2303 ADV
              RMASIO(14,2,ICOMP)=RMASIO(14,2,ICOMP)+QCTMP2             !# LINE 2304 ADV
            ENDIF
C
          ENDDO
        ENDDO
      ENDDO
C
C--CALCULATE MASS LOST TO ICBND=0 CELLS                                !# LINE 2311 ADV
      IF(DOMINSAT.EQ..TRUE.) THEN                                      !# LINE 2312 ADV
      CTMPMAX=0.                                                       !# LINE 2313 ADV
      ICNT0=0                                                          !# LINE 2314 ADV
      IF(IC2DRY.EQ.1) THEN                                             !# LINE 2315 ADV
        IF(.NOT.ALLOCATED(C2DRY)) ALLOCATE(C2DRY(NCOL,NROW,NLAY,MCOMP)) !# LINE 2316 ADV
        C2DRY=0.                                                       !# LINE 2317 ADV
        TEXT='MASS TO DRY'                                             !# LINE 2318 ADV
        IU=198                                                         !# LINE 2319 ADV
        FLNAME='c2dry.ucn'                                             !# LINE 2320 ADV
        INQUIRE(UNIT=IU,OPENED=LOP)                                    !# LINE 2321 ADV
        IF(.not.LOP) CALL OPENFL(-(198),0,FLNAME,1,FINDEX)             !# LINE 2322 ADV
      ENDIF                                                            !# LINE 2323 ADV
c                                                                      !# LINE 2324 ADV
      DO K=1,NLAY                                                      !# LINE 2325 ADV
        DO I=1,NROW                                                    !# LINE 2326 ADV
          DO J=1,NCOL                                                  !# LINE 2327 ADV
            IF(ICBUND(J,I,K,ICOMP).EQ.0) THEN                          !# LINE 2328 ADV
              QCTMP=SADV5Q2(NCOL,NROW,NLAY,J,I,K,ICBUND(:,:,:,ICOMP),  !# LINE 2329 ADV
     &         DELR,DELC,DH,CNEW(:,:,:,ICOMP),QX,QY,QZ,DTRANS,NADVFD)  !# LINE 2330 ADV
C                                                                      !# LINE 2331 ADV
              IF(DRYON.EQ..FALSE.) THEN                                !# LINE 2332 ADV
                IF(QCTMP.GT.0) THEN                                    !# LINE 2333 ADV
                  RMASIO(12,1,ICOMP)=RMASIO(12,1,ICOMP)+QCTMP          !# LINE 2334 ADV
                ELSE                                                   !# LINE 2335 ADV
                  RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTMP          !# LINE 2336 ADV
                ENDIF                                                  !# LINE 2337 ADV
              ENDIF                                                    !# LINE 2338 ADV
C                                                                      !# LINE 2339 ADV
              IF(IC2DRY.EQ.1) C2DRY(J,I,K,ICOMP)=QCTMP                 !# LINE 2340 ADV
C                                                                      !# LINE 2341 ADV
              IF(ABS(QCTMP).GT.1.) THEN                                !# LINE 2342 ADV
                ICNT0=ICNT0+1                                          !# LINE 2343 ADV
                !write(199,*) k,i,j,QCTMP                              !# LINE 2344 ADV
              ENDIF                                                    !# LINE 2345 ADV
              IF(CTMPMAX.LT.ABS(QCTMP)) THEN                           !# LINE 2346 ADV
                KMAX=K                                                 !# LINE 2347 ADV
                IMAX=I                                                 !# LINE 2348 ADV
                JMAX=J                                                 !# LINE 2349 ADV
                CTMPMAX=ABS(QCTMP)                                     !# LINE 2350 ADV
              ENDIF                                                    !# LINE 2351 ADV
            ENDIF                                                      !# LINE 2352 ADV
          ENDDO                                                        !# LINE 2353 ADV
        ENDDO                                                          !# LINE 2354 ADV
      ENDDO                                                            !# LINE 2355 ADV
c                                                                      !# LINE 2356 ADV
      IF(IC2DRY.EQ.1) THEN                                             !# LINE 2357 ADV
        if(PRTOUT) then                                                !# LINE 2358 ADV
          DO K=1,NLAY                                                  !# LINE 2359 ADV
            WRITE(iu) NTRANS,KSTP,KPER,TIME2,TEXT,NCOL,NROW,K          !# LINE 2360 ADV
            WRITE(iu) ((c2dry(J,I,K,ICOMP),J=1,NCOL),I=1,NROW)         !# LINE 2361 ADV
          ENDDO                                                        !# LINE 2362 ADV
        ENDIF                                                          !# LINE 2363 ADV
      ENDIF                                                            !# LINE 2364 ADV
C                                                                      !# LINE 2365 ADV
      ENDIF                                                            !# LINE 2366 ADV
C                                                                      !# LINE 2367 ADV
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE SADV5U(NCOL,NROW,NLAY,ICBUND,DELR,DELC,DH,PRSITY,
     & CNEW,COLD,CTOP,CBCK,QX,QY,QZ,RETA,DTRANS,RMASIO)
C *********************************************************************
C THIS SUBROUTINE SOLVES THE ADVECTION TERM WITH THE 3RD ORDER TVD
C SCHEME (ULTIMATE).
C *********************************************************************
C last modified: 02-15-2005
C
      USE       MIN_SAT                                        !# LINE 2383 ADV
      IMPLICIT  NONE
      INTEGER   ICBUND,NCOL,NROW,NLAY,J,I,K,IX,IY,IZ
      INTEGER   K2,N,NRC                                       !# LINE 2385 ADV
      REAL      COLD,QX,QY,QZ,DELR,DELC,DH,CNEW,PRSITY,RETA,DTRANS,
     &          CBCK,CTMP,WW,CTOP,CRGT,CTOTAL,CFACE,RMASIO
      REAL      CTOTAL2,CMAS2                                  !# LINE 2387 ADV
      DIMENSION ICBUND(NCOL,NROW,NLAY),QX(NCOL,NROW,NLAY),
     &          QY(NCOL,NROW,NLAY),QZ(NCOL,NROW,NLAY),DELR(NCOL),
     &          DELC(NROW),DH(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          CNEW(NCOL,NROW,NLAY),RETA(NCOL,NROW,NLAY),
     &          CTOP(NCOL,NROW,NLAY),PRSITY(NCOL,NROW,NLAY),
     &          CBCK(NCOL,NROW,NLAY),RMASIO(122,2)
      PARAMETER (IX=1,IY=2,IZ=3)
C
C--CLEAR TEMPORARY ARRAYS
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(ICBUND(J,I,K).EQ.0) CYCLE
            CTOP(J,I,K)=0.
            CBCK(J,I,K)=0.
          ENDDO
        ENDDO
      ENDDO
C
      IF(DRYON) C7=0.                                          !# LINE 2407 ADV
      NRC=NROW*NCOL                                            !# LINE 2408 ADV
C                                                              !# LINE 2409 ADV
C--LOOP THROUGH ALL CELLS
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            CTOTAL=0.
            CTOTAL2=0.                                         !# LINE 2421 ADV
C
C--SKIP IF CELL IS INACTIVE
            IF(ICBUND(J,I,K).EQ.0) CYCLE
C
C--CALCULATE FACE VALUES IN Z DIRECTION
C  ====================================
            IF(NLAY.LT.2) GOTO 410
C
C--TOP FACE...
C--THE TOP FACE HAS BEEN COMPUTED AND SAVED AT PREVIOUS BOTTOM FACE
            IF(K.GT.1) THEN                                         !edm
              IF(DOMINSAT) THEN                                     !# LINE 2433 ADV
                IF(ICBUND(J,I,K-1).NE.0) THEN                       !edm
                  CTOTAL=CTOTAL-CTOP(J,I,K-1)*QZ(J,I,K-1)/DH(J,I,K)
                ELSE                                                !# LINE 2436 ADV
                  IF(QZ(J,I,K-1).LT.0.) THEN                        !# LINE 2437 ADV
                    CTOTAL2=CTOTAL2-COLD(J,I,K)*QZ(J,I,K-1)/DH(J,I,K) !# LINE 2438 ADV
                  ELSE                                              !# LINE 2439 ADV
                    CTOTAL2=CTOTAL2-0.*QZ(J,I,K-1)/DH(J,I,K)        !# LINE 2440 ADV
                  ENDIF                                             !# LINE 2441 ADV
                ENDIF                                               !# LINE 2442 ADV
              ELSE                                                  !# LINE 2443 ADV
                IF(ICBUND(J,I,K-1).NE.0)                            !# LINE 2444 ADV
     &            CTOTAL=CTOTAL-CTOP(J,I,K-1)*QZ(J,I,K-1)/DH(J,I,K) !# LINE 2445 ADV
              ENDIF                                                 !# LINE 2446 ADV
            ENDIF                                                   !edm
C
C--BOTTOM FACE...
            IF(K.LT.NLAY) THEN                                      !edm
              IF(DOMINSAT) THEN                                     !# LINE 2451 ADV
                IF(ICBUND(J,I,K+1).NE.0) THEN                       !edm
C                                                                   !# LINE 2453 ADV
C--CALCULATE THE FACE VALUE AT (J,I,K+1/2)                          !# LINE 2454 ADV
                  CTMP=CFACE(NCOL,NROW,NLAY,J,I,K+1,IZ,DELR,DELC,DH, !# LINE 2455 ADV
     &               COLD,PRSITY,DTRANS,QX,QY,QZ,ICBUND)            !# LINE 2456 ADV
                  CTOTAL=CTOTAL+CTMP*QZ(J,I,K)/DH(J,I,K)            !# LINE 2457 ADV
C                                                                   !# LINE 2458 ADV
C--SAVE THE FACE VALUE FOR NEXT CELL                                !# LINE 2459 ADV
                  CTOP(J,I,K)=CTMP                                  !# LINE 2460 ADV
                ELSE                                                !# LINE 2461 ADV
                  IF(QZ(J,I,K).GE.0.) THEN                          !# LINE 2462 ADV
                    CTOTAL2=CTOTAL2+COLD(J,I,K)*QZ(J,I,K)/DH(J,I,K) !# LINE 2463 ADV
                  ELSE                                              !# LINE 2464 ADV
                    CTOTAL2=CTOTAL2+0.*QZ(J,I,K)/DH(J,I,K)          !# LINE 2465 ADV
                  ENDIF                                             !# LINE 2466 ADV
                ENDIF                                               !# LINE 2467 ADV
              ELSE                                                  !# LINE 2468 ADV
                IF(ICBUND(J,I,K+1).NE.0) THEN                       !# LINE 2468 ADV
C
C--CALCULATE THE FACE VALUE AT (J,I,K+1/2)
                  CTMP=CFACE(NCOL,NROW,NLAY,J,I,K+1,IZ,DELR,DELC,DH,
     &                 COLD,PRSITY,DTRANS,QX,QY,QZ,ICBUND)
                  CTOTAL=CTOTAL+CTMP*QZ(J,I,K)/DH(J,I,K)
C
C--SAVE THE FACE VALUE FOR NEXT CELL
                  CTOP(J,I,K)=CTMP
                ENDIF                                               !# LINE 2478 ADV
              ENDIF                                                 !edm
            ENDIF                                                   !edm
C
C--CALCULATE FACE VALUES IN Y DIRECTION
C  ====================================
C
  410       IF(NROW.LT.2) GOTO 420
C
C--BACK FACE...
C--THE BACK FACE HAS BEEN COMPUTED AND SAVED AT PREVIOUS FRONT FACE
            IF(I.GT.1) THEN                                          !# edm
              IF(DOMINSAT) THEN                                      !# LINE 2490 ADV
                IF(ICBUND(J,I-1,K).NE.0) THEN                        !# edm
                  WW=DH(J,I-1,K)/DH(J,I,K)                           !# LINE 2492 ADV
              !!!WW=(DH(J,I-1,K)*PRSITY(J,I-1,K))/(DH(J,I,K)*PRSITY(J,I,K)) !# LINE 2493 ADV
                  IF(DOMINSAT.EQ..TRUE.) WW=ABS(WW)                  !# LINE 2494 ADV
CVSB                  IF(DOMINSAT.EQ..TRUE.) WW=1.                   !# LINE 2495 ADV
                  CTOTAL=CTOTAL-CBCK(J,I-1,K)*WW*QY(J,I-1,K)/DELC(I) !# LINE 2496 ADV
                ELSE                                                 !# LINE 2497 ADV
                  IF(QY(J,I-1,K).LT.0.) THEN                         !# LINE 2498 ADV
                    CTOTAL2=CTOTAL2-COLD(J,I,K)*QY(J,I-1,K)/DELC(I)  !# LINE 2499 ADV
                    IF(DRYON) THEN                                   !# LINE 2500 ADV
                      CMAS2=-COLD(J,I,K)*QY(J,I-1,K)/DELC(I)         !# LINE 2501 ADV
                      CMAS2=CMAS2*DTRANS/(RETA(J,I,K)*PRSITY(J,I,K)) !# LINE 2502 ADV
                      CMAS2=CMAS2*RETA(J,I,K)*                       !# LINE 2503 ADV
     &                DELR(J)*DELC(I)*DH(J,I,K)*PRSITY(J,I,K)        !# LINE 2504 ADV
                      K2=0                                           !# LINE 2505 ADV
                      IF(QZ(J,I-1,K).GT.0.) THEN                     !# LINE 2506 ADV
                        IF(K.LT.NLAY) K2=K+1                         !# LINE 2507 ADV
                      ELSEIF(QZ(J,I-1,K-1).LT.0.) THEN               !# LINE 2508 ADV
                        IF(K.GT.1) K2=K-1                            !# LINE 2509 ADV
                      ELSE                                           !# LINE 2510 ADV
                        K2=0                                         !# LINE 2511 ADV
                      ENDIF                                          !# LINE 2512 ADV
                      IF(K2.GT.0) THEN                               !# LINE 2513 ADV
                        IF(ICBUND(J,I-1,K2).GT.0) THEN               !# LINE 2514 ADV
                          RMASIO(12,1)=RMASIO(12,1)+CMAS2            !# LINE 2515 ADV
                          CMAS2=CMAS2/(RETA(J,I-1,K2)*               !# LINE 2516 ADV
     &                          DELR(J)*DELC(I-1)*DH(J,I-1,K2)*      !# LINE 2517 ADV
     &                          PRSITY(J,I-1,K2))                    !# LINE 2517 ADV
                          IF(K2.LT.K) THEN                           !# LINE 2518 ADV
                            CNEW(J,I-1,K2)=CNEW(J,I-1,K2)+CMAS2      !# LINE 2519 ADV
                          ELSE                                       !# LINE 2520 ADV
                            N=(K2-1)*NRC+(I-1-1)*NCOL+J              !# LINE 2521 ADV
                            C7(N)=C7(N)+CMAS2                        !# LINE 2522 ADV
                          ENDIF                                      !# LINE 2523 ADV
                        ELSEIF(ICBUND(J,I-1,K2).LT.0) THEN           !# LINE 2524 ADV
                          RMASIO(6,2)=RMASIO(6,2)-CMAS2              !# LINE 2525 ADV
                        ENDIF                                        !# LINE 2526 ADV
                      ENDIF                                          !# LINE 2527 ADV
                    ENDIF                                            !# LINE 2528 ADV
                  ELSE                                               !# LINE 2529 ADV
                    CTOTAL2=CTOTAL2-0.*QY(J,I-1,K)/DELC(I)           !# LINE 2530 ADV
                  ENDIF                                              !# LINE 2531 ADV
                ENDIF                                                !# LINE 2532 ADV
              ELSE                                                   !# LINE 2533 ADV
                IF(ICBUND(J,I-1,K).NE.0) THEN                        !# LINE 2534 ADV
                  WW=DH(J,I-1,K)/DH(J,I,K)                           !# LINE 2535 ADV
              !!!WW=(DH(J,I-1,K)*PRSITY(J,I-1,K))/(DH(J,I,K)*PRSITY(J,I,K)) !# LINE 2536 ADV
                  IF(DOMINSAT.EQ..TRUE.) WW=ABS(WW)                  !# LINE 2537 ADV
                  CTOTAL=CTOTAL-CBCK(J,I-1,K)*WW*QY(J,I-1,K)/DELC(I) !# LINE 2538 ADV
                ENDIF                                                !# LINE 2539 ADV
              ENDIF                                                  !# LINE 2540 ADV
            ENDIF                                                    !edm
C
C--FRONT FACE...
            IF(I.LT.NROW) THEN                                       !edm
              IF(DOMINSAT) THEN                                      !# LINE2545 ADV
                IF(ICBUND(J,I+1,K).NE.0) THEN                        !edm
C                                                                    !# LINE 2547 ADV
C--CALCULATE THE FACE VALUE AT (J,I+1/2,K)                           !# LINE 2548 ADV
                  CTMP=CFACE(NCOL,NROW,NLAY,J,I+1,K,IY,DELR,DELC,DH, !# LINE 2549 ADV
     &             COLD,PRSITY,DTRANS,QX,QY,QZ,ICBUND)               !# LINE 2550 ADV
                  CTOTAL=CTOTAL+CTMP*QY(J,I,K)/DELC(I)               !# LINE 2551 ADV
C                                                                    !# LINE 2552 ADV
C--SAVE THE FACE VALUE FOR NEXT CELL                                 !# LINE 2553 ADV
                  CBCK(J,I,K)=CTMP                                   !# LINE 2554 ADV
                ELSE                                                 !# LINE 2555 ADV
                  IF(QY(J,I,K).GT.0.) THEN                           !# LINE 2556 ADV
                    CTOTAL2=CTOTAL2+COLD(J,I,K)*QY(J,I,K)/DELC(I)    !# LINE 2557 ADV
                    IF(DRYON) THEN                                   !# LINE 2558 ADV
                      CMAS2=COLD(J,I,K)*QY(J,I,K)/DELC(I)            !# LINE 2559 ADV
                      CMAS2=CMAS2*DTRANS/(RETA(J,I,K)*PRSITY(J,I,K)) !# LINE 2560 ADV
                      CMAS2=CMAS2*RETA(J,I,K)*                       !# LINE 2561 ADV
     &                DELR(J)*DELC(I)*DH(J,I,K)*PRSITY(J,I,K)        !# LINE 2562 ADV
                      K2=0                                           !# LINE 2563 ADV
                      IF(QZ(J,I+1,K).GT.0.) THEN                     !# LINE 2564 ADV
                        IF(K.LT.NLAY) K2=K+1                         !# LINE 2565 ADV
                      ELSEIF(QZ(J,I+1,K-1).LT.0.) THEN               !# LINE 2566 ADV
                        IF(K.GT.1) K2=K-1                            !# LINE 2567 ADV
                      ELSE                                           !# LINE 2568 ADV
                        K2=0                                         !# LINE 2569 ADV
                      ENDIF                                          !# LINE 2570 ADV
                      IF(K2.GT.0) THEN                               !# LINE 2571 ADV
                        IF(ICBUND(J,I+1,K2).GT.0) THEN               !# LINE 2572 ADV
                          RMASIO(12,1)=RMASIO(12,1)+CMAS2            !# LINE 2573 ADV
                          CMAS2=CMAS2/(RETA(J,I+1,K2)*               !# LINE 2574 ADV
     &                  DELR(J)*DELC(I+1)*DH(J,I+1,K2)*PRSITY(J,I+1,K2)) !# LINE 2575 ADV
                          IF(K2.LT.K) THEN                           !# LINE 2576 ADV
                            CNEW(J,I+1,K2)=CNEW(J,I+1,K2)+CMAS2      !# LINE 2577 ADV
                          ELSE                                       !# LINE 2578 ADV
                            N=(K2-1)*NRC+(I+1-1)*NCOL+J              !# LINE 2579 ADV
                            C7(N)=C7(N)+CMAS2                        !# LINE 2580 ADV
                          ENDIF                                      !# LINE 2581 ADV
                        ELSEIF(ICBUND(J,I+1,K2).LT.0) THEN           !# LINE 2582 ADV
                          RMASIO(6,2)=RMASIO(6,2)-CMAS2              !# LINE 2583 ADV
                        ENDIF                                        !# LINE 2584 ADV
                      ENDIF                                          !# LINE 2585 ADV
                    ENDIF                                            !# LINE 2586 ADV
                  ELSE                                               !# LINE 2587 ADV
                    CTOTAL2=CTOTAL2+0.*QY(J,I,K)/DELC(I)             !# LINE 2588 ADV
                  ENDIF                                              !# LINE 2589 ADV
                ENDIF                                                !# LINE 2590 ADV
              ELSE                                                   !# LINE 2591 ADV
                IF(ICBUND(J,I+1,K).NE.0) THEN                        !# LINE 2592 ADV
C                                                           
C--CALCULATE THE FACE VALUE AT (J,I+1/2,K)
                  CTMP=CFACE(NCOL,NROW,NLAY,J,I+1,K,IY,DELR,DELC,DH,
     &                 COLD,PRSITY,DTRANS,QX,QY,QZ,ICBUND)
                  CTOTAL=CTOTAL+CTMP*QY(J,I,K)/DELC(I)
C
C--SAVE THE FACE VALUE FOR NEXT CELL
                  CBCK(J,I,K)=CTMP
                ENDIF                                                !# LINE 2601 ADV
              ENDIF                                                 !edm
            ENDIF                                                   !edm
C
C--CALCULATE IN THE X DIRECTION
C  ============================
C
  420       IF(NCOL.LT.2) GOTO 430
C
C--LEFT FACE...
C--THE LEFT FACE HAS BEEN COMPUTED AND SAVED AT PREVIOUS RIGHT FACE
            IF(J.GT.1) THEN                                          !edm
              IF(DOMINSAT) THEN                                      !# LINE 2613 ADV
                IF(ICBUND(J-1,I,K).NE.0) THEN                        !edm
                  WW=DH(J-1,I,K)/DH(J,I,K)                           !# LINE 2615 ADV
              !!!WW=(DH(J-1,I,K)*PRSITY(J-1,I,K))/(DH(J,I,K)*PRSITY(J,I,K)) !# LINE 2616 ADV
                  IF(DOMINSAT.EQ..TRUE.) WW=ABS(WW)                  !# LINE 2617 ADV
CVSB                  IF(DOMINSAT.EQ..TRUE.) WW=1.                   !# LINE 2618 ADV
                  CTOTAL=CTOTAL-CRGT*WW*QX(J-1,I,K)/DELR(J)          !# LINE 2619 ADV
                ELSE                                                 !# LINE 2620 ADV
                  IF(QX(J-1,I,K).LT.0.) THEN                         !# LINE 2621 ADV
                    CTOTAL2=CTOTAL2-COLD(J,I,K)*QX(J-1,I,K)/DELR(J)  !# LINE 2622 ADV
                    IF(DRYON) THEN                                   !# LINE 2623 ADV
                      CMAS2=-COLD(J,I,K)*QX(J-1,I,K)/DELC(I)         !# LINE 2624 ADV
                      CMAS2=CMAS2*DTRANS/(RETA(J,I,K)*PRSITY(J,I,K)) !# LINE 2625 ADV
                      CMAS2=CMAS2*RETA(J,I,K)*                       !# LINE 2626 ADV
     &                DELR(J)*DELC(I)*DH(J,I,K)*PRSITY(J,I,K)        !# LINE 2627 ADV
                      K2=0                                           !# LINE 2628 ADV
                      IF(QZ(J-1,I,K).GT.0.) THEN                     !# LINE 2629 ADV
                        IF(K.LT.NLAY) K2=K+1                         !# LINE 2630 ADV
                      ELSEIF(QZ(J-1,I,K-1).LT.0.) THEN               !# LINE 2631 ADV
                        IF(K.GT.1) K2=K-1                            !# LINE 2632 ADV
                      ELSE                                           !# LINE 2633 ADV
                        K2=0                                         !# LINE 2634 ADV
                      ENDIF                                          !# LINE 2635 ADV
                      IF(K2.GT.0) THEN                               !# LINE 2636 ADV
                        IF(ICBUND(J-1,I,K2).GT.0) THEN               !# LINE 2637 ADV
                          RMASIO(12,1)=RMASIO(12,1)+CMAS2            !# LINE 2638 ADV
                          CMAS2=CMAS2/(RETA(J-1,I,K2)*               !# LINE 2639 ADV
     &                  DELR(J-1)*DELC(I)*DH(J-1,I,K2)*PRSITY(J-1,I,K2)) !# LINE 2640 ADV
                          IF(K2.LT.K) THEN                           !# LINE 2641 ADV
                            CNEW(J-1,I,K2)=CNEW(J-1,I,K2)+CMAS2      !# LINE 2642 ADV
                          ELSE                                       !# LINE 2643 ADV
                            N=(K2-1)*NRC+(I-1)*NCOL+J-1              !# LINE 2644 ADV
                            C7(N)=C7(N)+CMAS2                        !# LINE 2645 ADV
                          ENDIF                                      !# LINE 2646 ADV
                        ELSEIF(ICBUND(J-1,I,K2).LT.0) THEN           !# LINE 2647 ADV
                          RMASIO(6,2)=RMASIO(6,2)-CMAS2              !# LINE 2648 ADV
                        ENDIF                                        !# LINE 2649 ADV
                      ENDIF                                          !# LINE 2650 ADV
                    ENDIF                                            !# LINE 2651 ADV
                  ELSE                                               !# LINE 2652 ADV
                    CTOTAL2=CTOTAL2-0.*QX(J-1,I,K)/DELR(J)           !# LINE 2653 ADV
                  ENDIF                                              !# LINE 2654 ADV
                ENDIF                                                !# LINE 2655 ADV
              ELSE                                                   !# LINE 2656 ADV
                IF(ICBUND(J-1,I,K).NE.0) THEN                        !# LINE 2657 ADV
                  WW=DH(J-1,I,K)/DH(J,I,K)                           !# LINE 2658 ADV
              !!!WW=(DH(J-1,I,K)*PRSITY(J-1,I,K))/(DH(J,I,K)*PRSITY(J,I,K)) !# LINE 2659
                  IF(DOMINSAT.EQ..TRUE.) WW=ABS(WW)                  !# LINE 2659 ADV
                  CTOTAL=CTOTAL-CRGT*WW*QX(J-1,I,K)/DELR(J)          !# LINE 2660 ADV
                ENDIF                                                !# LINE 2661 ADV
              ENDIF                                                  !# LINE 2662 ADV
            ENDIF                                                    !edm
C
C--RIGHT FACE...
            IF(J.LT.NCOL) THEN                                       !edm
              IF(DOMINSAT) THEN                                      !# LINE 2668 ADV
                IF(ICBUND(J+1,I,K).NE.0) THEN                        !edm
C                                                                    !# LINE 2670 ADV
C--CALCULATE FACE VALUE AT (J+1/2,I,K)                               !# LINE 2671 ADV
                  CRGT=CFACE(NCOL,NROW,NLAY,J+1,I,K,IX,DELR,DELC,DH, !# LINE 2672 ADV
     &              COLD,PRSITY,DTRANS,QX,QY,QZ,ICBUND)              !# LINE 2673 ADV
                  CTOTAL=CTOTAL+CRGT*QX(J,I,K)/DELR(J)               !# LINE 2674 ADV
                ELSE                                                 !# LINE 2675 ADV
                  IF(QX(J,I,K).GT.0)THEN                             !# LINE 2676 ADV
                    CTOTAL2=CTOTAL2+COLD(J,I,K)*QX(J,I,K)/DELR(J)    !# LINE 2677 ADV
                    IF(DRYON) THEN                                   !# LINE 2678 ADV
                      CMAS2=COLD(J,I,K)*QX(J,I,K)/DELC(I)            !# LINE 2679 ADV
                      CMAS2=CMAS2*DTRANS/(RETA(J,I,K)*PRSITY(J,I,K)) !# LINE 2680 ADV
                      CMAS2=CMAS2*RETA(J,I,K)*                       !# LINE 2681 ADV
     &                DELR(J)*DELC(I)*DH(J,I,K)*PRSITY(J,I,K)        !# LINE 2682 ADV
                      K2=0                                           !# LINE 2683 ADV
                      IF(QZ(J+1,I,K).GT.0.) THEN                     !# LINE 2684 ADV
                        IF(K.LT.NLAY) K2=K+1                         !# LINE 2685 ADV
                      ELSEIF(QZ(J+1,I,K-1).LT.0.) THEN               !# LINE 2686 ADV
                        IF(K.GT.1) K2=K-1                            !# LINE 2687 ADV
                      ELSE                                           !# LINE 2688 ADV
                        K2=0                                         !# LINE 2689 ADV
                      ENDIF                                          !# LINE 2690 ADV
                      IF(K2.GT.0) THEN                               !# LINE 2691 ADV
                        IF(ICBUND(J+1,I,K2).GT.0) THEN               !# LINE 2692 ADV
                          RMASIO(12,1)=RMASIO(12,1)+CMAS2            !# LINE 2693 ADV
                          CMAS2=CMAS2/(RETA(J+1,I,K2)*               !# LINE 2694 ADV
     &                  DELR(J+1)*DELC(I)*DH(J+1,I,K2)*PRSITY(J+1,I,K2)) !# LINE 2695 ADV
                          IF(K2.LT.K) THEN                           !# LINE 2696 ADV
                            CNEW(J+1,I,K2)=CNEW(J+1,I,K2)+CMAS2      !# LINE 2697 ADV
                          ELSE                                       !# LINE 2698 ADV
                            N=(K2-1)*NRC+(I-1)*NCOL+J+1              !# LINE 2699 ADV
                            C7(N)=C7(N)+CMAS2                        !# LINE 2700 ADV
                          ENDIF                                      !# LINE 2701 ADV
                        ELSEIF(ICBUND(J+1,I,K2).LT.0) THEN           !# LINE 2702 ADV
                          RMASIO(6,2)=RMASIO(6,2)-CMAS2              !# LINE 2703 ADV
                        ENDIF                                        !# LINE 2704 ADV
                      ENDIF                                          !# LINE 2705 ADV
                    ENDIF                                            !# LINE 2706 ADV
                  ELSE                                               !# LINE 2707 ADV
                    CTOTAL2=CTOTAL2+0.*QX(J,I,K)/DELR(J)             !# LINE 2708 ADV
                  ENDIF                                              !# LINE 2709 ADV
                ENDIF                                                !# LINE 2710 ADV
              ELSE                                                   !# LINE 2711 ADV
                IF(ICBUND(J+1,I,K).NE.0) THEN                        !# LINE 2712 ADV
C
C--CALCULATE FACE VALUE AT (J+1/2,I,K)
                  CRGT=CFACE(NCOL,NROW,NLAY,J+1,I,K,IX,DELR,DELC,DH,
     &                  COLD,PRSITY,DTRANS,QX,QY,QZ,ICBUND)
                  CTOTAL=CTOTAL+CRGT*QX(J,I,K)/DELR(J)
                ENDIF                                                !# LINE 2718 ADV
              ENDIF                                                  !edm
            ENDIF                                                    !edm
C
C--TOTAL CHANGES            
  430       CTOTAL=CTOTAL*DTRANS/(RETA(J,I,K)*PRSITY(J,I,K))
            CTOTAL2=CTOTAL2*DTRANS/(RETA(J,I,K)*PRSITY(J,I,K))       !# LINE 2728 ADV
C
C--UPDATE CONCENTRATION AT ACTIVE CELL AND
C--SAVE MASS INTO OR OUT OF CONSTANT-CONCENTRATION CELL
            IF(ICBUND(J,I,K).GT.0) THEN
              CNEW(J,I,K)=COLD(J,I,K)-CTOTAL-CTOTAL2                 !# Amended (LINE 2733 ADV)
              N=(K-1)*NRC+(I-1)*NCOL+J                               !# LINE 2734 ADV
              IF(DRYON) CNEW(J,I,K)=CNEW(J,I,K)+C7(N)                !# LINE 2735 ADV
              IF(DOMINSAT) THEN                                      !# LINE 2736 ADV
                IF(CTOTAL2.LT.0) THEN                                !# LINE 2737 ADV
                  RMASIO(12,1)=RMASIO(12,1)-CTOTAL2*RETA(J,I,K)*     !# LINE 2738 ADV
     &             DELR(J)*DELC(I)*DH(J,I,K)*PRSITY(J,I,K)           !# LINE 2739 ADV
                ELSE                                                 !# LINE 2740 ADV
                  RMASIO(12,2)=RMASIO(12,2)-CTOTAL2*RETA(J,I,K)*     !# LINE 2741 ADV
     &             DELR(J)*DELC(I)*DH(J,I,K)*PRSITY(J,I,K)           !# LINE 2742 ADV
                ENDIF                                                !# LINE 2743 ADV
              ENDIF                                                  !# LINE 2744 ADV
            ELSEIF(ICBUND(J,I,K).LT.0) THEN
              IF(CTOTAL.GT.0) THEN
                RMASIO(6,1)=RMASIO(6,1)+CTOTAL*RETA(J,I,K)*
     &           DELR(J)*DELC(I)*DH(J,I,K)*PRSITY(J,I,K)
              ELSE
                RMASIO(6,2)=RMASIO(6,2)+CTOTAL*RETA(J,I,K)*
     &           DELR(J)*DELC(I)*DH(J,I,K)*PRSITY(J,I,K)
              ENDIF
            ENDIF
C
          ENDDO
        ENDDO
      ENDDO
C
C--NORMAL RETURN
      RETURN
      END
C
C
      FUNCTION CFACE(NCOL,NROW,NLAY,J,I,K,LL,DELR,DELC,DH,C,PRSITY,
     & DTRANS,QX,QY,QZ,ICBUND)
C**********************************************************************
C THIS FUNCTION COMPUTES THE (LEFT,BACK,OR TOP) FACE VALUE DEPENDING
C ON THE VALUE OF LL USING THE ULTIMATE SCHEME.
C LL = 1: LEFT FACE
C      2: BACK FACE
C      3: TOP  FACE
C**********************************************************************
C last modified: 02-15-2005
C
      IMPLICIT  NONE
      INTEGER   ICBUND,NCOL,NROW,NLAY,J,I,K,IP1,IM1,IM2,JP1,JM1,JM2,
     &          KP1,KM1,KM2,LL,IX,IY,IZ
      REAL      C,QX,QY,QZ,DELR,DELC,DH,DTRANS,DX,DY,DZ,DXP1,DXM1,DYP1,
     &          DYM1,DZP1,DZM1,CP,CW,GRADX,GRADY,GRADZ,GRADXP,GRADXM,
     &          GRADXMM,GRADXPM,GRADYM,GRADYP,GRADYPM,GRADYMM,GRADZM,
     &          GRADX2,GRADY2,GRADZ2,CURV,TWIST,
     &          GRADZP,GRADZPM,GRADZMM,CURVX,CURVY,CURVZ,TWISTX,TWISTY,
     &          TWISTZ,VX,VY,VZ,S2,S3,S4,UL,SL,ULIMIT,WW,CRNT,SETA,
     &          PRSITY,EPSILON,TINY,CFACE,U
      DIMENSION C(NCOL,NROW,NLAY),ICBUND(NCOL,NROW,NLAY),
     &          QX(NCOL,NROW,NLAY),QY(NCOL,NROW,NLAY),
     &          QZ(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),
     &          DH(NCOL,NROW,NLAY),PRSITY(NCOL,NROW,NLAY)
      PARAMETER (IX=1,IY=2,IZ=3,EPSILON=0.5E-6,TINY=1.E-30)
C
C--INITIALIZE
      IP1=MIN(NROW,I+1)
      IM1=MAX(1,I-1)
      IM2=MAX(1,I-2)
      JP1=MIN(NCOL,J+1)
      JM1=MAX(1,J-1)
      JM2=MAX(1,J-2)
      KP1=MIN(NLAY,K+1)
      KM1=MAX(1,K-1)
      KM2=MAX(1,K-2)
      GRADX=0.
      GRADXP=0.
      GRADXM=0.
      GRADXPM=0.
      GRADXMM=0.
      GRADY=0.
      GRADYP=0.
      GRADYM=0.
      GRADYPM=0.
      GRADYMM=0.
      GRADZ=0.
      GRADZP=0.
      GRADZM=0.
      GRADZPM=0.
      GRADZMM=0.
      GRADX2=0.
      GRADY2=0.
      GRADZ2=0.
      CURVX=0.
      CURVY=0.
      CURVZ=0.
      TWISTX=0.
      TWISTY=0.
      TWISTZ=0.
      VX=0.
      VY=0.
      VZ=0.
C
C--COMPUTE THE DISTANCES BETWEEN CELLS
      DX = 0.5*(DELR(JM1)+DELR(J))
      DXM1=0.5*(DELR(JM2)+DELR(JM1))
      DXP1=0.5*(DELR(JP1)+DELR(J))
      DY = 0.5*(DELC(IM1)+DELC(I))
      DYM1=0.5*(DELC(IM2)+DELC(IM1))
      DYP1=0.5*(DELC(IP1)+DELC(I))
      DZ = 0.5*(DH(J,I,KM1)+DH(J,I,K))
      DZM1=0.5*(DH(J,I,KM2)+DH(J,I,KM1))
      DZP1=0.5*(DH(J,I,KP1)+DH(J,I,K))
C
C--SIX GRADIENTS AROUND CELL (J, I, K)
      CP=C(J,I,K)
      IF(ICBUND(JM1,I,K).NE.0) GRADX = (CP-C(JM1,I,K))/DX
      IF(ICBUND(JP1,I,K).NE.0) GRADXP= (C(JP1,I,K)-CP)/DXP1
      IF(ICBUND(J,IM1,K).NE.0) GRADY = (CP-C(J,IM1,K))/DY
      IF(ICBUND(J,IP1,K).NE.0) GRADYP= (C(J,IP1,K)-CP)/DYP1
      IF(ICBUND(J,I,KM1).NE.0) GRADZ = (CP-C(J,I,KM1))/DZ
      IF(ICBUND(J,I,KP1).NE.0) GRADZP= (C(J,I,KP1)-CP)/DZP1
C
C--COMPUTE FACE VALUE AT (J-1/2, I, K)
      IF (LL.EQ.IX) THEN
C
C--COMPUTE THE VELOCITIES AT FACE (J-1/2, I, K)
         WW=DELR(J)/(DELR(JM1)+DELR(J))
         VX=QX(JM1,I,K)
C
         IF(NROW.GT.1) 
     &       VY=0.5*(QY(JM1,IM1,K)+QY(JM1,I,K))*WW
     &         +0.5*(QY(J,IM1,K)+QY(J,I,K))*(1.-WW)
         IF(NLAY.GT.1) 
     &       VZ=0.5*(QZ(JM1,I,KM1)+QZ(JM1,I,K))*WW
     &         +0.5*(QZ(J,I,KM1)+QZ(J,I,K))*(1.-WW)
         SETA=WW*PRSITY(JM1,I,K)+(1.-WW)*PRSITY(J,I,K)
         VX=VX*DTRANS/SETA
         VY=VY*DTRANS/SETA 
         VZ=VZ*DTRANS/SETA 
         CW=C(JM1,I,K)
C
C--SET CONC. TO UPSTREAM NODE AND RETURN IF NEXT TO INACTIVE CELL
         IF(VX.GT.0.0.AND.ICBUND(JM2,I,K).EQ.0) THEN
            CFACE=CW
            GOTO 999
         ENDIF
         IF(VX.LT.0.0.AND.ICBUND(JP1,I,K).EQ.0) THEN
            CFACE=CP
            GOTO 999
         ENDIF
C
C--FIVE ADDITIONAL GRADIENTS AROUND CELL (JM1, I, K)
         IF(ICBUND(JM2,I,K).NE.0)   GRADXM  = (CW-C(JM2,I,K))  /DXM1
         IF(ICBUND(JM1,IP1,K).NE.0) GRADYPM = (C(JM1,IP1,K)-CW)/DYP1
         IF(ICBUND(JM1,IM1,K).NE.0) GRADYMM = (CW-C(JM1,IM1,K))/DY
         IF(ICBUND(JM1,I,KP1).NE.0) GRADZPM = (C(JM1,I,KP1)-CW)/DZP1
         IF(ICBUND(JM1,I,KM1).NE.0) GRADZMM = (CW-C(JM1,I,KM1))/DZ
C
C--CURVTURES
         IF (VX.GT.0) THEN
            CURVX=(GRADX   - GRADXM)  /DELR(JM1)
            CURVY=(GRADYPM - GRADYMM) /DELC(I)
            CURVZ=(GRADZPM - GRADZMM) /DH(J,I,K)
         ELSE
            CURVX=(GRADXP  - GRADX)/DELR(J)
            CURVY=(GRADYP - GRADY) /DELC(I)
            CURVZ=(GRADZP - GRADZ) /DH(J,I,K)
         ENDIF
C
C--TWIST NORMAL TO X DIRECTION
         IF(ICBUND(J,I,KM1).NE.0 .AND.ICBUND(JM1,I,KM1).NE.0) THEN
            GRADY2=(C(J,I,KM1)-C(JM1,I,KM1))/DY
            TWISTX = (GRADY-GRADY2)/DZ
         ENDIF
C
C--TWIST AND GRADIENT IN Y DIRECTION
         IF (VY.GT.0) THEN
            TWISTY=(GRADY-GRADYMM)/DX
            IF(VX.GT.0) GRADY = GRADYMM
         ELSE
            TWISTY=(GRADYP-GRADYPM)/DX
            IF(VX.GT.0) THEN
               GRADY = GRADYPM
            ELSE
               GRADY = GRADYP
            ENDIF
         ENDIF
C
C--TWIST AND GRADIENT IN Z DIRECTION
         IF (VZ.GT.0) THEN
            TWISTZ=(GRADZ-GRADZMM)/DX
            IF(VX.GT.0) GRADZ = GRADZMM
         ELSE
            TWISTZ=(GRADZP-GRADZPM)/DX
            IF(VX.GT.0) THEN
               GRADZ=GRADZPM
            ELSE
               GRADZ=GRADZP
            ENDIF
         ENDIF
C
C--FACE VALUE BEFORE APPLYING UNIVERSAL LIMITER
         CURV=    - (DX*DX-VX**2)*CURVX/6.
     &            + (VY*VY/6.-DY*VY/4.)*CURVY
     &            + (VZ*VZ/6.-DZ*VZ/4.)*CURVZ
         TWIST=   + (VX*VY/3.-DX*VY/4.)*TWISTY
     &            + (VX*VZ/3.-DX*VZ/4.)*TWISTZ
     &            + (VY*VZ/3.)*TWISTX
         CFACE=   WW*CW+(1.-WW)*CP
     &            - 0.5*(VX*GRADX+VY*GRADY+VZ*GRADZ)
     &            + CURV + TWIST
C
C--ASSIGN VALUES FOR COMPUTING UNIVERSAL LIMITER
         CRNT = VX/DX
         IF(VX.GT.0) THEN
            S4=CP
            S3=CW
            S2=C(JM2,I,K)
         ELSE
            S2=C(JP1,I,K)
            S3=CP
            S4=CW
         ENDIF
C
C--COMPUTE FACE VALUE AT (J, I-1/2, K)
      ELSE IF (LL.EQ.IY) THEN
C
C--CALCULATE VELOCITIES AT INTERFACE (J, I-1/2, K)
         WW=DELC(I)/(DELC(IM1)+DELC(I))
         VY=QY(J,IM1,K)
C
         IF(NCOL.GT.1) 
     &       VX=0.5*(QX(J,IM1,K)+QX(JM1,IM1,K))*WW
     &         +0.5*(QX(J,I,K)+QX(JM1,I,K))*(1.-WW)
         IF(NLAY.GT.1) 
     &        VZ=0.5*(QZ(J,IM1,K)+QZ(J,IM1,KM1))*WW
     &          +0.5*(QZ(J,I,K)+QZ(J,I,KM1))*(1.-WW)

         SETA=WW*PRSITY(J,IM1,K)+(1.-WW)*PRSITY(J,I,K)
         VX=VX*DTRANS/SETA
         VY=VY*DTRANS/SETA 
         VZ=VZ*DTRANS/SETA 
         CW=C(J,IM1,K)
C
C--SET CONC. TO UPSTREAM NODE AND RETURN IF NEXT TO INACTIVE CELL
         IF(VY.GT.0.0.AND.ICBUND(J,IM2,K).EQ.0) THEN
            CFACE=CW
            GOTO 999
         ENDIF
         IF(VY.LT.0.0.AND.ICBUND(J,IP1,K).EQ.0) THEN
            CFACE=CP
           GOTO 999
         ENDIF
C
C--FIVE ADDITIONAL GRADIENTS AROUND CELL (J, I-1, K)
         IF(ICBUND(J,IM2,K).NE.0)   GRADYM  = (CW-C(J,IM2,K))  /DYM1
         IF(ICBUND(JP1,IM1,K).NE.0) GRADXPM = (C(JP1,IM1,K)-CW)/DXP1
         IF(ICBUND(JM1,IM1,K).NE.0) GRADXMM = (CW-C(JM1,IM1,K))/DX
         IF(ICBUND(J,IM1,KP1).NE.0) GRADZPM = (C(J,IM1,KP1)-CW)/DZP1
         IF(ICBUND(J,IM1,KM1).NE.0) GRADZMM = (CW-C(J,IM1,KM1))/DZ
C
C--CURVTURES
         IF (VY.GT.0) THEN
            CURVY=(GRADY   - GRADYM)  /DELC(IM1)
            CURVX=(GRADXPM - GRADXMM) /DELR(J)
            CURVZ=(GRADZPM - GRADZMM) /DH(J,I,K)
         ELSE
            CURVY=(GRADYP - GRADY)/DELC(I)
            CURVX=(GRADXP - GRADX)/DELR(J)
            CURVZ=(GRADZP - GRADZ)/DH(J,I,K)
         ENDIF
C
C--TWIST AND GRADIENT IN X DIRECTION
         IF (VX.GT.0) THEN
            TWISTX=(GRADX-GRADXMM)/DY
            IF(VY.GT.0) GRADX = GRADXMM
         ELSE
            TWISTX=(GRADXP-GRADXPM)/DY
            IF(VY.GT.0) THEN
               GRADX = GRADXPM
            ELSE
               GRADX = GRADXP
            ENDIF
         ENDIF
C
C--TWIST NORMAL TO Y DIRECTION
         IF(ICBUND(JM1,I,K).NE.0 .AND.ICBUND(JM1,I,KM1).NE.0) THEN
            GRADZ2=(C(JM1,I,K)-C(JM1,I,KM1))/DZ
            TWISTY = (GRADZ-GRADZ2)/DX
         ENDIF
C
C--TWIST AND GRADIENT IN Z DIRECTION
         IF (VZ.GT.0) THEN
            TWISTZ=(GRADZ-GRADZMM)/DY
            IF(VY.GT.0) GRADZ = GRADZMM
         ELSE
            TWISTZ=(GRADZP-GRADZPM)/DY
            IF(VY.GT.0) THEN
               GRADZ = GRADZPM
            ELSE
               GRADZ = GRADZP
            ENDIF
         ENDIF
C
C--FACE VALUE BEFORE APPLYING UNIVERSAL LIMITER
         CURV=    - (DY*DY-VY**2)*CURVY/6.
     &            + (VX*VX/6.-DX*VX/4.)*CURVX
     &            + (VZ*VZ/6.-DZ*VZ/4.)*CURVZ
         TWIST=   + (VX*VY/3.-DY*VX/4.)*TWISTX
     &            + (VY*VZ/3.-DY*VZ/4.)*TWISTZ
     &            + (VX*VZ/3.)*TWISTY
         CFACE    = WW*CW+(1.-WW)*CP
     &            - 0.5*(VX*GRADX+VY*GRADY+VZ*GRADZ)
     &            + CURV + TWIST
C
C--ASSIGN VALUES FOR COMPUTING UNIVERSAL LIMITER
         CRNT = VY/DY
         IF(VY.GT.0) THEN
            S4=CP
            S3=CW
            S2=C(J,IM2,K)
         ELSE
            S2=C(J,IP1,K)
            S3=CP
            S4=CW
         ENDIF
C
C--COMPUTE FACE VALUE AT (J, I, K-1/2)
      ELSE 
C
C--CALCULATE VELOCITIES AT INTERFACE (J,I,K-1/2)
         WW=DH(J,I,K)/(DH(J,I,KM1)+DH(J,I,K))
         VZ=QZ(J,I,KM1)
C
         IF(NCOL.GT.1)
     &       VX=0.5*(QX(JM1,I,KM1)+QX(J,I,KM1))*WW
     &         +0.5*(QX(JM1,I,K)+QX(J,I,K))*(1.-WW)
         IF(NROW.GT.1)
     &       VY=0.5*(QY(J,IM1,KM1)+QY(J,I,KM1))*WW
     &         +0.5*(QY(J,IM1,K)+QY(J,I,K))*(1.-WW)
         SETA=WW*PRSITY(J,I,KM1)+(1.-WW)*PRSITY(J,I,K)
         VX=VX*DTRANS/SETA
         VY=VY*DTRANS/SETA 
         VZ=VZ*DTRANS/SETA 
         CW=C(J,I,KM1)
C
C--SET CONC. TO UPSTREAM NODE AND RETURN IF NEXT TO INACTIVE CELL
         IF(VZ.GT.0.0.AND.ICBUND(J,I,KM2).EQ.0) THEN
            CFACE=CW
            GOTO 999
         ENDIF
         IF(VZ.LT.0.0.AND.ICBUND(J,I,KP1).EQ.0) THEN
            CFACE=CP
            GOTO 999
         ENDIF
C
C--FIVE ADDITIONAL GRADIENTS AT CELL (J, I, KM1)
         IF(ICBUND(J,I,KM2).NE.0)   GRADZM =(CW-C(J,I,KM2))  /DZM1
         IF(ICBUND(J,IP1,KM1).NE.0) GRADYPM=(C(J,IP1,KM1)-CW)/DYP1
         IF(ICBUND(J,IM1,KM1).NE.0) GRADYMM=(CW-C(J,IM1,KM1))/DY
         IF(ICBUND(JP1,I,KM1).NE.0) GRADXPM=(C(JP1,I,KM1)-CW)/DXP1
         IF(ICBUND(JM1,I,KM1).NE.0) GRADXMM=(CW-C(JM1,I,KM1))/DX
C
C--CURVTURES
         IF (VZ.GT.0) THEN
            CURVZ=(GRADZ   - GRADZM)  /DH(J,I,KM1)
            CURVY=(GRADYPM - GRADYMM) /DELC(I)
            CURVX=(GRADXPM - GRADXMM) /DELR(J)
         ELSE
            CURVZ=(GRADZP  - GRADZ)/DH(J,I,K)
            CURVY=(GRADYP - GRADY) /DELC(I)
            CURVX=(GRADXP - GRADX) /DELR(J)
         ENDIF
C
C--TWIST AND GRADIENT IN Y DIRECTION
         IF (VY.GT.0) THEN
            TWISTY=(GRADY-GRADYMM)/DZ
            IF(VZ.GT.0) GRADY = GRADYMM
         ELSE
            TWISTY=(GRADYP-GRADYPM)/DZ
            IF(VZ.GT.0) THEN
               GRADY = GRADYPM
            ELSE
               GRADY = GRADYP
            ENDIF
         ENDIF
C
C--TWIST AND GRADIENT IN X DIRECTION
         IF (VX.GT.0) THEN
            TWISTX=(GRADX-GRADXMM)/DZ
            IF(VZ.GT.0) GRADX = GRADXMM
         ELSE
            TWISTX=(GRADXP-GRADXPM)/DZ
            IF(VZ.GT.0) THEN
               GRADX = GRADXPM
            ELSE
               GRADX = GRADXP
            ENDIF
         ENDIF
C
C--TWIST NORMAL TO Z DIRECTION
         IF(ICBUND(J,IM1,K).NE.0 .AND.ICBUND(JM1,IM1,K).NE.0) THEN
            GRADX2=(C(J,IM1,K)-C(JM1,IM1,K))/DX
            TWISTY = (GRADX-GRADX2)/DY
         ENDIF
C
C--FACE VALUE BEFORE APPLYING UNIVERSAL LIMITER
         CURV=    - (DZ*DZ-VZ**2)*CURVZ/6.
     &            + (VY*VY/6.-DY*VY/4.)*CURVY
     &            + (VX*VX/6.-DX*VX/4.)*CURVX
         TWIST=   + (VZ*VY/3.-DZ*VY/4.)*TWISTY
     &            + (VZ*VX/3.-DZ*VX/4.)*TWISTX
     &            + (VX*VY/3.)*TWISTZ
         CFACE    = WW*CW+(1.-WW)*CP
     &            - 0.5*(VX*GRADX+VY*GRADY+VZ*GRADZ)
     &            + CURV + TWIST
C
C--ASSIGN VALUES FOR COMPUTING UNIVERSAL LIMITER
         CRNT = VZ/DZ
         IF (VZ .GT. 0) THEN
             S4=CP
             S3=CW
             S2=C(J,I,KM2)
         ELSE
             S2=C(J,I,KP1)
             S3=CP
             S4=CW
         ENDIF
      ENDIF
C
C--APPLY UNIVERSAL LIMITER
      U=S4
      CRNT=ABS(CRNT)
      IF(S2.GE.S3.AND.S3.GE.S4) THEN
        IF(CRNT.GT.TINY) THEN
          U=MAX(S4, S2+(S3-S2)/CRNT)
        ENDIF
        IF(CFACE.GT.S3) CFACE=S3
        IF(CFACE.LT.U)  CFACE=U
      ELSEIF(S2.LE.S3.AND.S3.LE.S4) THEN
        IF(CRNT.GT.TINY) THEN
          U=MIN(S4, S2+(S3-S2)/CRNT)
        ENDIF
        IF(CFACE.LT.S3) CFACE=S3
        IF(CFACE.GT.U)  CFACE=U
      ELSE
        CFACE=S3
      ENDIF
C
C--NORMAL RETURN
  999 RETURN
      END
C--------------------------------------------------------------------
C--------------------------------------------------------------------
      FUNCTION SADV5Q2(NCOL,NROW,NLAY,JJ,II,KK,ICBUND,DELR,DELC,DH,
     & COLD,QX,QY,QZ,DTRANS,NADVFD)
C *******************************************************************
C THIS FUNCTION COMPUTES ADVECTIVE MASS FLUX TO ICBND=0 CELLS. MASS IS
C MOVING OUT OF THE CELL IF SADV5Q > 0, INTO THE CELL IF SADV5Q < 0.
C NADVFD=1 IS FOR THE UPSTREAM SCHEME; NADVFD=2 IS FOR THE CENTRAL
C WEIGHTING SCHEME.
C *******************************************************************
C last modified: 02-15-2005
C
      USE MIN_SAT
      IMPLICIT  NONE
      INTEGER   ICBUND,NCOL,NROW,NLAY,JJ,II,KK,NADVFD
      REAL      SADV5Q2,COLD,QX,QY,QZ,DELR,DELC,DH,AREA,DTRANS,QCTMP,
     &          WW,THKSAT,ALPHA,CTMP
      DIMENSION ICBUND(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          QX(NCOL,NROW,NLAY),QY(NCOL,NROW,NLAY),
     &          QZ(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),
     &          DH(NCOL,NROW,NLAY)
C
C--SET QCTMP = 0 FOR ACCUMULATING Q*C*DTRANS IN ALL FACES
      QCTMP=0.
C
C--CALCULATE IN THE Z DIRECTION
      IF(NLAY.LT.2) GOTO 410
      AREA=DELR(JJ)*DELC(II)
C--TOP FACE
      IF(KK.GT.1) THEN
        IF(ICBUND(JJ,II,KK-1).NE.0) THEN
          WW=DH(JJ,II,KK)/(DH(JJ,II,KK-1)+DH(JJ,II,KK))
          ALPHA=0.
          IF(QZ(JJ,II,KK-1).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK-1)*ALPHA !+ COLD(JJ,II,KK)*(1.-ALPHA)
          IF((-QZ(JJ,II,KK-1)*CTMP*AREA*DTRANS).LT.0) THEN
            QCTMP=QCTMP-QZ(JJ,II,KK-1)*CTMP*AREA*DTRANS
          ENDIF
        ENDIF
      ENDIF
C--BOTTOM FACE
      IF(KK.LT.NLAY) THEN
        IF(ICBUND(JJ,II,KK+1).NE.0) THEN
          WW=DH(JJ,II,KK+1)/(DH(JJ,II,KK)+DH(JJ,II,KK+1))
          ALPHA=0.
          IF(QZ(JJ,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK+1)*(1.-ALPHA) !+ COLD(JJ,II,KK)*ALPHA 
          IF((QZ(JJ,II,KK)*CTMP*AREA*DTRANS).LT.0) THEN
          QCTMP=QCTMP+QZ(JJ,II,KK)*CTMP*AREA*DTRANS
          ENDIF
        ENDIF
      ENDIF
C
C--CALCULATE IN THE Y DIRECTION
  410 IF(NROW.LT.2) GOTO 420
C--BACK FACE
      IF(II.GT.1) THEN
        IF(ICBUND(JJ,II-1,KK).NE.0) THEN
          WW=DELC(II)/(DELC(II)+DELC(II-1))
          THKSAT=DH(JJ,II-1,KK)*WW+DH(JJ,II,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN
            THKSAT=ABS(DH(JJ,II-1,KK))*WW+ABS(DH(JJ,II,KK))*(1.-WW)
          ENDIF
          AREA=DELR(JJ)*THKSAT
          ALPHA=0.
          IF(QY(JJ,II-1,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II-1,KK)*ALPHA !+ COLD(JJ,II,KK)*(1.-ALPHA)
          IF((-QY(JJ,II-1,KK)*CTMP*AREA*DTRANS).LT.0) THEN
          QCTMP=QCTMP-QY(JJ,II-1,KK)*CTMP*AREA*DTRANS
          ENDIF
        ENDIF
      ENDIF
C--FRONT FACE
      IF(II.LT.NROW) THEN
        IF(ICBUND(JJ,II+1,KK).NE.0) THEN
          WW=DELC(II+1)/(DELC(II+1)+DELC(II))
          THKSAT=DH(JJ,II,KK)*WW+DH(JJ,II+1,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN
            THKSAT=ABS(DH(JJ,II,KK))*WW+ABS(DH(JJ,II+1,KK))*(1.-WW)
          ENDIF
          AREA=DELR(JJ)*THKSAT
          ALPHA=0.
          IF(QY(JJ,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II+1,KK)*(1.-ALPHA) !+ COLD(JJ,II,KK)*ALPHA
          IF((QY(JJ,II,KK)*CTMP*AREA*DTRANS).LT.0) THEN
          QCTMP=QCTMP+QY(JJ,II,KK)*CTMP*AREA*DTRANS
          ENDIF
        ENDIF
      ENDIF
C
C--CALCULATE IN THE X DIRECTION
  420 IF(NCOL.LT.2) GOTO 430
C--LEFT FACE
      IF(JJ.GT.1) THEN
        IF(ICBUND(JJ-1,II,KK).NE.0) THEN
          WW=DELR(JJ)/(DELR(JJ)+DELR(JJ-1))
          THKSAT=DH(JJ-1,II,KK)*WW+DH(JJ,II,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN
            THKSAT=ABS(DH(JJ-1,II,KK))*WW+ABS(DH(JJ,II,KK))*(1.-WW)
          ENDIF
          AREA=DELC(II)*THKSAT
          ALPHA=0.
          IF(QX(JJ-1,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ-1,II,KK)*ALPHA !+ COLD(JJ,II,KK)*(1.-ALPHA)
          IF((-QX(JJ-1,II,KK)*CTMP*AREA*DTRANS).LT.0) THEN
            QCTMP=QCTMP-QX(JJ-1,II,KK)*CTMP*AREA*DTRANS
          ENDIF
        ENDIF
      ENDIF
C--RIGHT FACE
      IF(JJ.LT.NCOL) THEN
        IF(ICBUND(JJ+1,II,KK).NE.0) THEN
          WW=DELR(JJ+1)/(DELR(JJ+1)+DELR(JJ))
          THKSAT=DH(JJ,II,KK)*WW+DH(JJ+1,II,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN
            THKSAT=ABS(DH(JJ,II,KK))*WW+ABS(DH(JJ+1,II,KK))*(1.-WW)
          ENDIF
          AREA=DELC(II)*THKSAT
          ALPHA=0.
          IF(QX(JJ,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ+1,II,KK)*(1.-ALPHA) !+ COLD(JJ,II,KK)*ALPHA
          IF((QX(JJ,II,KK)*CTMP*AREA*DTRANS).LT.0) THEN
            QCTMP=QCTMP+QX(JJ,II,KK)*CTMP*AREA*DTRANS
          ENDIF
        ENDIF
      ENDIF
C
C--ASSIGN QCTMP TO THE FUNCTION AND RETURN
  430 SADV5Q2=QCTMP
C
      RETURN
      END
C
C
      SUBROUTINE ADVQC7FM(ICOMP)
C *********************************************************************
C THIS SUBROUTINE FORMULATES COEFFICIENT MATRICES FOR THE ADVECTION
C TERM WITH THE OPTIONS OF UPSTREAM (NADVFD=1) AND CENTRAL (NADVFD=2)
C WEIGHTING.
C *********************************************************************
C last modified: 02-15-2005
C
      USE MIN_SAT
      USE MT3DMS_MODULE, ONLY: NCOL,NROW,NLAY,MCOMP,ICBUND,DELR,
     &                         DELC,DH,QX,QY,QZ,NADVFD,NODES,A,UPDLHS,
     &                         RHS,CNEW
      IMPLICIT  NONE
      INTEGER   ICOMP,J,I,K,N,NCR,IUPS,ICTRL
      INTEGER   INDX
      REAL      WW,THKSAT,AREA,ALPHA
      REAL      QCTEMP,QTEMP,QCTEMP2
      PARAMETER (IUPS=1,ICTRL=2)
C
C--RETURN IF COEFF MATRICES ARE NOT TO BE UPDATED
CCC      IF(.NOT.UPDLHS) GOTO 999
C
C--LOOP THROUGH ALL ACTIVE CELLS
      NCR=NROW*NCOL
C
C-----FORMULATE FOR DRY CELLS - FLOW INTO DRY CELLS
      C7=0.
      DO INDX=1,NICBND2
        N=ID2D(INDX)
        CALL NODE2KIJ(N,NLAY,NROW,NCOL,K,I,J)
        QCTEMP=0.
        QCTEMP2=0.
        QTEMP=0.
C
C--SKIP IF INACTIVE OR CONSTANT CELL
        IF(ICBND2(J,I,K).EQ.0) CYCLE
C
C------CALCULATE IN THE Z DIRECTION
        IF(NLAY.LT.2) GOTO 1410
C---------TOP FACE
        IF(K.GT.1) THEN
          IF(QC7(J,I,K,ICOMP,1).LT.0.) THEN
            IF(ICBND2(J,I,K-1).EQ.0) THEN
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,1)*CNEW(J,I,K-1,ICOMP)
            ELSE
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,1)*C7(N-NCR)
            ENDIF
            QTEMP=QTEMP+QC7(J,I,K,ICOMP,1)
          ENDIF
        ENDIF
C-------BOTTOM FACE
        IF(K.LT.NLAY) THEN
          IF(QC7(J,I,K,ICOMP,6).LT.0.) THEN
            IF(ICBND2(J,I,K+1).EQ.0) THEN
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,6)*CNEW(J,I,K+1,ICOMP)
            ELSE
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,6)*C7(N+NCR)
            ENDIF
            QTEMP=QTEMP+QC7(J,I,K,ICOMP,6)
          ENDIF
        ENDIF
C
C------CALCULATE IN THE Y DIRECTION
 1410   IF(NROW.LT.2) GOTO 1420    
C---------BACK FACE
        IF(I.GT.1) THEN
          IF(QC7(J,I,K,ICOMP,2).LT.0.) THEN
            IF(ICBND2(J,I-1,K).EQ.0) THEN
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,2)*CNEW(J,I-1,K,ICOMP)
            ELSE
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,2)*C7(N-NCOL)
            ENDIF
            QTEMP=QTEMP+QC7(J,I,K,ICOMP,2)
          ENDIF
        ENDIF
C-------FRONT FACE
        IF(I.LT.NROW) THEN
          IF(QC7(J,I,K,ICOMP,5).LT.0.) THEN
            IF(ICBND2(J,I+1,K).EQ.0) THEN
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,5)*CNEW(J,I+1,K,ICOMP)
            ELSE
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,5)*C7(N+NCOL)
            ENDIF
            QTEMP=QTEMP+QC7(J,I,K,ICOMP,5)
          ENDIF
        ENDIF
C
C--------CALCULATE IN THE X DIRECTION
 1420   IF(NCOL.LT.2) GOTO 1430
C---------LEFT FACE
        IF(J.GT.1) THEN
          IF(QC7(J,I,K,ICOMP,3).LT.0.) THEN
            IF(ICBND2(J-1,I,K).EQ.0) THEN
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,3)*CNEW(J-1,I,K,ICOMP)
            ELSE
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,3)*C7(N-1)
            ENDIF
            QTEMP=QTEMP+QC7(J,I,K,ICOMP,3)
          ENDIF
        ENDIF
C-------RIGHT FACE      
        IF(J.LT.NCOL) THEN
          IF(QC7(J,I,K,ICOMP,4).LT.0.) THEN
            IF(ICBND2(J+1,I,K).EQ.0) THEN
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,4)*CNEW(J+1,I,K,ICOMP)
            ELSE
              QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,4)*C7(N+1)
            ENDIF
            QTEMP=QTEMP+QC7(J,I,K,ICOMP,4)
          ENDIF
        ENDIF
C
        IF(ABS(QTEMP).GT.1.E-6) C7(N)=QCTEMP/QTEMP
C
 1430   CONTINUE
      ENDDO
C
C-----FORMULATE FLOW OUT OF DRY CELLS
      DO INDX=1,NICBND2
        N=ID2D(INDX)
        CALL NODE2KIJ(N,NLAY,NROW,NCOL,K,I,J)
        QCTEMP=0.
        QCTEMP2=0.
        QTEMP=0.
        N=(K-1)*NCR + (I-1)*NCOL + J
C
C--SKIP IF INACTIVE OR CONSTANT CELL
        IF(ICBND2(J,I,K).EQ.0) CYCLE
C
C-------CALCULATE IN THE Z DIRECTION
        IF(NLAY.LT.2) GOTO 2410
C-------TOP FACE
        IF(K.GT.1) THEN
          IF(QC7(J,I,K,ICOMP,1).GT.0.) THEN
            IF(ICBND2(J,I,K-1).EQ.0) THEN
              RHS(N-NCR)=RHS(N-NCR)-QC7(J,I,K,ICOMP,1)*C7(N)
            ENDIF
          ENDIF
        ENDIF
C-------BOTTOM FACE
        IF(K.LT.NLAY) THEN
          IF(QC7(J,I,K,ICOMP,6).GT.0.) THEN
            IF(ICBND2(J,I,K+1).EQ.0) THEN
              RHS(N+NCR)=RHS(N+NCR)-QC7(J,I,K,ICOMP,6)*C7(N)
            ENDIF
          ENDIF
        ENDIF
C
C-------CALCULATE IN THE Y DIRECTION
 2410   IF(NROW.LT.2) GOTO 2420    
C-------BACK FACE
        IF(I.GT.1) THEN
          IF(QC7(J,I,K,ICOMP,2).GT.0.) THEN
            IF(ICBND2(J,I-1,K).EQ.0) THEN
              RHS(N-NCOL)=RHS(N-NCOL)-QC7(J,I,K,ICOMP,2)*C7(N)
            ENDIF
          ENDIF
        ENDIF
C-------FRONT FACE
        IF(I.LT.NROW) THEN
          IF(QC7(J,I,K,ICOMP,5).GT.0.) THEN
            IF(ICBND2(J,I+1,K).EQ.0) THEN
              RHS(N+NCOL)=RHS(N+NCOL)-QC7(J,I,K,ICOMP,5)*C7(N)
            ENDIF
          ENDIF
        ENDIF
C
C----------CALCULATE IN THE X DIRECTION
 2420   IF(NCOL.LT.2) GOTO 2430
C---------LEFT FACE
        IF(J.GT.1) THEN
          IF(QC7(J,I,K,ICOMP,3).GT.0.) THEN
            IF(ICBND2(J-1,I,K).EQ.0) THEN
            RHS(N-1)=RHS(N-1)-QC7(J,I,K,ICOMP,3)*C7(N)
            ENDIF
          ENDIF
        ENDIF
C---------RIGHT FACE      
        IF(J.LT.NCOL) THEN
          IF(QC7(J,I,K,ICOMP,4).GT.0.) THEN
            IF(ICBND2(J+1,I,K).EQ.0) THEN
            RHS(N+1)=RHS(N+1)-QC7(J,I,K,ICOMP,4)*C7(N)
            ENDIF
          ENDIF
        ENDIF
C
 2430   CONTINUE
      ENDDO
C
C--RETURN
  999 RETURN
      END
C
C
      SUBROUTINE ADVQC7BD(ICOMP,DTRANS)
C *********************************************************************
C THIS SUBROUTINE FORMULATES COEFFICIENT MATRICES FOR THE ADVECTION
C TERM WITH THE OPTIONS OF UPSTREAM (NADVFD=1) AND CENTRAL (NADVFD=2)
C WEIGHTING.
C *********************************************************************
C last modified: 02-15-2005
C
      USE MIN_SAT
      USE MT3DMS_MODULE, ONLY: NCOL,NROW,NLAY,MCOMP,ICBUND,DELR,
     &                         DELC,DH,QX,QY,QZ,NADVFD,NODES,A,UPDLHS,
     &                         RHS,CNEW,RMASIO
      IMPLICIT  NONE
      INTEGER   ICOMP,J,I,K,N,NCR,IUPS,ICTRL
      INTEGER   INDX
      REAL      WW,THKSAT,AREA,ALPHA
      REAL      QCTEMP,QTEMP,QCTEMP2,DTRANS
      PARAMETER (IUPS=1,ICTRL=2)
C
C--RETURN IF COEFF MATRICES ARE NOT TO BE UPDATED
CCC      IF(.NOT.UPDLHS) GOTO 999
C
C-----BUDGET FOR DRY CELLS - FLOW INTO DRY CELLS
      NCR=NROW*NCOL
      C7=0.
      DO INDX=1,NICBND2
        N=ID2D(INDX)
        CALL NODE2KIJ(N,NLAY,NROW,NCOL,K,I,J)
        QCTEMP=0.
        QCTEMP2=0.
        QTEMP=0.
        N=(K-1)*NCR + (I-1)*NCOL + J
C
C--SKIP IF INACTIVE OR CONSTANT CELL
        IF(ICBND2(J,I,K).EQ.0) CYCLE
C
C-------CALCULATE IN THE Z DIRECTION
        IF(NLAY.LT.2) GOTO 1410
C-----TOP FACE
          IF(K.GT.1) THEN
            IF(QC7(J,I,K,ICOMP,1).LT.0.) THEN
              IF(ICBND2(J,I,K-1).EQ.0) THEN
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,1)*CNEW(J,I,K-1,ICOMP)
                QCTEMP2=QC7(J,I,K,ICOMP,1)*CNEW(J,I,K-1,ICOMP)*DTRANS
                RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
              ELSE
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,1)*C7(N-NCR)
                QCTEMP2=QC7(J,I,K,ICOMP,1)*C7(N-NCR)*DTRANS
              ENDIF
              QTEMP=QTEMP+QC7(J,I,K,ICOMP,1)
cvsbabc              RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
            ENDIF
          ENDIF
C-----------BOTTOM FACE
          IF(K.LT.NLAY) THEN
            IF(QC7(J,I,K,ICOMP,6).LT.0.) THEN
              IF(ICBND2(J,I,K+1).EQ.0) THEN
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,6)*CNEW(J,I,K+1,ICOMP)
                QCTEMP2=QC7(J,I,K,ICOMP,6)*CNEW(J,I,K+1,ICOMP)*DTRANS
                RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
              ELSE
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,6)*C7(N+NCR)
                QCTEMP2=QC7(J,I,K,ICOMP,6)*C7(N+NCR)*DTRANS
              ENDIF
              QTEMP=QTEMP+QC7(J,I,K,ICOMP,6)
cvsbabc              RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
            ENDIF
          ENDIF
C
C--------CALCULATE IN THE Y DIRECTION
 1410     IF(NROW.LT.2) GOTO 1420    
C--------BACK FACE
          IF(I.GT.1) THEN
            IF(QC7(J,I,K,ICOMP,2).LT.0.) THEN
              IF(ICBND2(J,I-1,K).EQ.0) THEN
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,2)*CNEW(J,I-1,K,ICOMP)
                QCTEMP2=QC7(J,I,K,ICOMP,2)*CNEW(J,I-1,K,ICOMP)*DTRANS
                RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
              ELSE
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,2)*C7(N-NCOL)
                QCTEMP2=QC7(J,I,K,ICOMP,2)*C7(N-NCOL)*DTRANS
              ENDIF
              QTEMP=QTEMP+QC7(J,I,K,ICOMP,2)
cvsbabc              RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
            ENDIF
          ENDIF
C---------FRONT FACE
          IF(I.LT.NROW) THEN
            IF(QC7(J,I,K,ICOMP,5).LT.0.) THEN
              IF(ICBND2(J,I+1,K).EQ.0) THEN
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,5)*CNEW(J,I+1,K,ICOMP)
                QCTEMP2=QC7(J,I,K,ICOMP,5)*CNEW(J,I+1,K,ICOMP)*DTRANS
                RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
              ELSE
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,5)*C7(N+NCOL)
                QCTEMP2=QC7(J,I,K,ICOMP,5)*C7(N+NCOL)*DTRANS
              ENDIF
              QTEMP=QTEMP+QC7(J,I,K,ICOMP,5)
cvsbabc              RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
            ENDIF
          ENDIF
C
C--------CALCULATE IN THE X DIRECTION
 1420     IF(NCOL.LT.2) GOTO 1430
C---------LEFT FACE
          IF(J.GT.1) THEN
            IF(QC7(J,I,K,ICOMP,3).LT.0.) THEN
              IF(ICBND2(J-1,I,K).EQ.0) THEN
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,3)*CNEW(J-1,I,K,ICOMP)
                QCTEMP2=QC7(J,I,K,ICOMP,3)*CNEW(J-1,I,K,ICOMP)*DTRANS
                RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
              ELSE
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,3)*C7(N-1)
                QCTEMP2=QC7(J,I,K,ICOMP,3)*C7(N-1)*DTRANS
              ENDIF
              QTEMP=QTEMP+QC7(J,I,K,ICOMP,3)
cvsbabc              RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
            ENDIF
          ENDIF
C---------RIGHT FACE      
          IF(J.LT.NCOL) THEN
            IF(QC7(J,I,K,ICOMP,4).LT.0.) THEN
              IF(ICBND2(J+1,I,K).EQ.0) THEN
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,4)*CNEW(J+1,I,K,ICOMP)
                QCTEMP2=QC7(J,I,K,ICOMP,4)*CNEW(J+1,I,K,ICOMP)*DTRANS
                RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
              ELSE
                QCTEMP=QCTEMP+QC7(J,I,K,ICOMP,4)*C7(N+1)
                QCTEMP2=QC7(J,I,K,ICOMP,4)*C7(N+1)*DTRANS
              ENDIF
              QTEMP=QTEMP+QC7(J,I,K,ICOMP,4)
cvsbabc              RMASIO(12,2,ICOMP)=RMASIO(12,2,ICOMP)+QCTEMP2
            ENDIF
          ENDIF
C
          IF(ABS(QTEMP).GT.1.E-9) C7(N)=QCTEMP/QTEMP
C
 1430   CONTINUE
      ENDDO
C
C-----BUDGET FLOW OUT OF DRY CELLS
      DO INDX=1,NICBND2
        N=ID2D(INDX)
        CALL NODE2KIJ(N,NLAY,NROW,NCOL,K,I,J)
        QCTEMP=0.
        QCTEMP2=0.
        QTEMP=0.
        N=(K-1)*NCR + (I-1)*NCOL + J
C
C--SKIP IF INACTIVE OR CONSTANT CELL
        IF(ICBND2(J,I,K).EQ.0) CYCLE
C
C-------CALCULATE IN THE Z DIRECTION
        IF(NLAY.LT.2) GOTO 2410
C-------TOP FACE
        IF(K.GT.1) THEN
          IF(QC7(J,I,K,ICOMP,1).GT.0.) THEN
            IF(ICBND2(J,I,K-1).EQ.0) THEN
              QCTEMP=QC7(J,I,K,ICOMP,1)*C7(N)*DTRANS
              RMASIO(12,1,ICOMP)=RMASIO(12,1,ICOMP)+QCTEMP
            ENDIF
          ENDIF
        ENDIF
C-------BOTTOM FACE
        IF(K.LT.NLAY) THEN
          IF(QC7(J,I,K,ICOMP,6).GT.0.) THEN
            IF(ICBND2(J,I,K+1).EQ.0) THEN
              QCTEMP=QC7(J,I,K,ICOMP,6)*C7(N)*DTRANS
              RMASIO(12,1,ICOMP)=RMASIO(12,1,ICOMP)+QCTEMP
            ENDIF
          ENDIF
        ENDIF
C
C-------CALCULATE IN THE Y DIRECTION
 2410   IF(NROW.LT.2) GOTO 2420    
C---------BACK FACE
          IF(I.GT.1) THEN
            IF(QC7(J,I,K,ICOMP,2).GT.0.) THEN
              IF(ICBND2(J,I-1,K).EQ.0) THEN
                QCTEMP=QC7(J,I,K,ICOMP,2)*C7(N)*DTRANS
                RMASIO(12,1,ICOMP)=RMASIO(12,1,ICOMP)+QCTEMP
              ENDIF
            ENDIF
          ENDIF
C---------FRONT FACE
          IF(I.LT.NROW) THEN
            IF(QC7(J,I,K,ICOMP,5).GT.0.) THEN
              IF(ICBND2(J,I+1,K).EQ.0) THEN
                QCTEMP=QC7(J,I,K,ICOMP,5)*C7(N)*DTRANS
                RMASIO(12,1,ICOMP)=RMASIO(12,1,ICOMP)+QCTEMP
              ENDIF
            ENDIF
          ENDIF
C
C---------CALCULATE IN THE X DIRECTION
 2420     IF(NCOL.LT.2) GOTO 2430
C---------LEFT FACE
          IF(J.GT.1) THEN
            IF(QC7(J,I,K,ICOMP,3).GT.0.) THEN
              IF(ICBND2(J-1,I,K).EQ.0) THEN
                QCTEMP=QC7(J,I,K,ICOMP,3)*C7(N)*DTRANS
                RMASIO(12,1,ICOMP)=RMASIO(12,1,ICOMP)+QCTEMP
              ENDIF
            ENDIF
          ENDIF
C---------RIGHT FACE      
          IF(J.LT.NCOL) THEN
            IF(QC7(J,I,K,ICOMP,4).GT.0.) THEN
              IF(ICBND2(J+1,I,K).EQ.0) THEN
                QCTEMP=QC7(J,I,K,ICOMP,4)*C7(N)*DTRANS
                RMASIO(12,1,ICOMP)=RMASIO(12,1,ICOMP)+QCTEMP
              ENDIF
            ENDIF
          ENDIF
C
 2430   CONTINUE
      ENDDO
C
C--RETURN
  999 RETURN
      END
C
C
      SUBROUTINE ADVQC7RP(KPER,KSTP)
C *********************************************************************
C THIS SUBROUTINE STORES FLOW ACROSS DRY CELLS AND  
C SORTS DRY CELLS IN ORDER OF FORMULATION 
C *********************************************************************
C last modified: 12-15-2009
C
      USE MIN_SAT
      USE MT3DMS_MODULE, ONLY: NCOL,NROW,NLAY,MCOMP,ICBUND,DELR,
     &                         DELC,DH,QX,QY,QZ,NADVFD,NODES,A,UPDLHS,
     &                         RHS
      IMPLICIT  NONE
      INTEGER   J,I,K,N,NCR,IUPS,ICTRL
      INTEGER   INDX,IJK,ITEMP
      INTEGER   KPER,KSTP
      REAL      WW,THKSAT,AREA,ALPHA,CNEW
      REAL      QCTEMP,QTEMP,QCTEMP2
      PARAMETER (IUPS=1,ICTRL=2)
C
C--RETURN IF COEFF MATRICES ARE NOT TO BE UPDATED
C
C--LOOP THROUGH ALL ACTIVE CELLS
      NCR=NROW*NCOL
      QC7=0.
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(K.EQ.1 .AND. I.EQ.59 .AND. J.EQ.181)THEN
            CONTINUE
            ENDIF
            N=(K-1)*NCR + (I-1)*NCOL + J
C
C--SKIP IF INACTIVE OR CONSTANT CELL
            IF(ICBND2(J,I,K).EQ.0) CYCLE
C
C--------CALCULATE IN THE Z DIRECTION
            IF(NLAY.LT.2) GOTO 410
            AREA=DELR(J)*DELC(I)
C-----------TOP FACE
            IF(K.GT.1) THEN
              IF(ICBUND(J,I,K-1,1).NE.0) THEN
cvsbabc              IF(ICBUND(N-NCR,1).NE.0 .OR. ICBND2(J,I,K-1).NE.0) THEN
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DH(J,I,K)/(DH(J,I,K-1)+
     &                                      DH(J,I,K))
                IF(NADVFD.EQ.IUPS.AND.QZ(J,I,K-1).LT.0.) ALPHA=1.0
                QC7(J,I,K,:,1)=-QZ(J,I,K-1)*AREA
              ENDIF
            ENDIF
C-----------BOTTOM FACE
            IF(K.LT.NLAY) THEN
              IF(ICBUND(J,I,K+1,1).NE.0) THEN
cvsbabc              IF(ICBUND(N+NCR,1).NE.0 .OR. ICBND2(J,I,K+1).NE.0) THEN
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DH(J,I,K)/(DH(J,I,K)+
     &                                     DH(J,I,K+1))
                IF(NADVFD.EQ.IUPS.AND.QZ(J,I,K).LT.0.) ALPHA=1.0
                QC7(J,I,K,:,6)=QZ(J,I,K)*AREA
              ENDIF
            ENDIF
C
C--------CALCULATE IN THE Y DIRECTION
  410       IF(NROW.LT.2) GOTO 420    
C-----------BACK FACE
            IF(I.GT.1) THEN
              IF(ICBUND(J,I-1,K,1).NE.0) THEN
cvsbabc              IF(ICBUND(N-NCOL,1).NE.0 .OR. ICBND2(J,I-1,K).NE.0) THEN
                WW=DELC(I)/(DELC(I)+DELC(I-1))
                THKSAT=DH(J,I-1,K)*WW+DH(J,I,K)*(1.-WW)
                IF(DOMINSAT.EQ..TRUE.) THEN
                  THKSAT=ABS(DH(J,I-1,K))*WW+ABS(DH(J,I,K))*(1.-WW)
                ENDIF
                AREA=DELR(J)*THKSAT
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DELC(I-1)/(DELC(I-1)+DELC(I))
                IF(NADVFD.EQ.IUPS.AND.QY(J,I-1,K).LT.0.) ALPHA=1.0
                QC7(J,I,K,:,2)=-QY(J,I-1,K)*AREA
              ENDIF
            ENDIF
C-----------FRONT FACE
            IF(I.LT.NROW) THEN
              IF(ICBUND(J,I+1,K,1).NE.0) THEN
cvsbabc              IF(ICBUND(N+NCOL,1).NE.0 .OR. ICBND2(J,I+1,K).NE.0) THEN
                WW=DELC(I+1)/(DELC(I+1)+DELC(I))
                THKSAT=DH(J,I,K)*WW+DH(J,I+1,K)*(1.-WW)
                IF(DOMINSAT.EQ..TRUE.) THEN
                  THKSAT=ABS(DH(J,I,K))*WW+ABS(DH(J,I+1,K))*(1.-WW)
                ENDIF
                AREA=DELR(J)*THKSAT
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DELC(I)/(DELC(I)+DELC(I+1))
                IF(NADVFD.EQ.IUPS.AND.QY(J,I,K).LT.0.) ALPHA=1.0
                QC7(J,I,K,:,5)=QY(J,I,K)*AREA
              ENDIF
            ENDIF
C
C----------CALCULATE IN THE X DIRECTION
  420       IF(NCOL.LT.2) GOTO 430
C-----------LEFT FACE
            IF(J.GT.1) THEN
              IF(ICBUND(J-1,I,K,1).NE.0) THEN
cvsbabc              IF(ICBUND(N-1,1).NE.0 .OR. ICBND2(J-1,I,K).NE.0) THEN
                WW=DELR(J)/(DELR(J)+DELR(J-1))
                THKSAT=DH(J-1,I,K)*WW+DH(J,I,K)*(1.-WW)
                IF(DOMINSAT.EQ..TRUE.) THEN
                  THKSAT=ABS(DH(J-1,I,K))*WW+ABS(DH(J,I,K))*(1.-WW)
                ENDIF
                AREA=DELC(I)*THKSAT
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DELR(J-1)/(DELR(J-1)+DELR(J))
                IF(NADVFD.EQ.IUPS.AND.QX(J-1,I,K).LT.0.) ALPHA=1.0
                QC7(J,I,K,:,3)=-QX(J-1,I,K)*AREA
              ENDIF
            ENDIF
C-----------RIGHT FACE      
            IF(J.LT.NCOL) THEN
              IF(ICBUND(J+1,I,K,1).NE.0) THEN
cvsbabc              IF(ICBUND(N+1,1).NE.0 .OR. ICBND2(J+1,I,K).NE.0) THEN
                WW=DELR(J+1)/(DELR(J+1)+DELR(J))
                THKSAT=DH(J,I,K)*WW+DH(J+1,I,K)*(1.-WW)
                IF(DOMINSAT.EQ..TRUE.) THEN
                  THKSAT=ABS(DH(J,I,K))*WW+ABS(DH(J+1,I,K))*(1.-WW)
                ENDIF
                AREA=DELC(I)*THKSAT
                ALPHA = 0.
                IF(NADVFD.EQ.ICTRL) ALPHA=DELR(J)/(DELR(J)+DELR(J+1))
                IF(NADVFD.EQ.IUPS.AND.QX(J,I,K).LT.0.) ALPHA=1.0
                QC7(J,I,K,:,4)=QX(J,I,K)*AREA
              ENDIF
            ENDIF
C
  430       CONTINUE
          ENDDO
        ENDDO
      ENDDO
C
C-----IDENTIFY DRY TO DRY FLOW AND SORT CELLS
      INDX=0
      ID2D=0
      DO IJK=1,NICBND2 !NLAY*NROW*NCOL
        DO K=1,NLAY
          DO I=1,NROW
            DO J=1,NCOL
              ITEMP=0
              N=(K-1)*NCR + (I-1)*NCOL + J
              IF(ICBND2(J,I,K).EQ.0) CYCLE
C      
C----------CALCULATE IN THE Z DIRECTION
              IF(NLAY.LT.2) GOTO 1410
C-------------TOP FACE
              IF(K.GT.1) THEN
                IF(QC7(J,I,K,1,1).LT.0.) THEN
                  IF(ICBND2(J,I,K-1).EQ.1) THEN
                    ITEMP=ITEMP+1
                  ENDIF
                ENDIF
              ENDIF
C-------------BOTTOM FACE
              IF(K.LT.NLAY) THEN
                IF(QC7(J,I,K,1,6).LT.0.) THEN
                  IF(ICBND2(J,I,K+1).EQ.1) THEN
                    ITEMP=ITEMP+1
                  ENDIF
                ENDIF
              ENDIF
C      
C----------CALCULATE IN THE Y DIRECTION
 1410         IF(NROW.LT.2) GOTO 1420    
C-------------BACK FACE
              IF(I.GT.1) THEN
                IF(QC7(J,I,K,1,2).LT.0.) THEN
                  IF(ICBND2(J,I-1,K).EQ.1) THEN
                    ITEMP=ITEMP+1
                  ENDIF
                ENDIF
              ENDIF
C-------------FRONT FACE
              IF(I.LT.NROW) THEN
                IF(QC7(J,I,K,1,5).LT.0.) THEN
                  IF(ICBND2(J,I+1,K).EQ.1) THEN
                    ITEMP=ITEMP+1
                  ENDIF
                ENDIF
              ENDIF
C      
C------------CALCULATE IN THE X DIRECTION
 1420         IF(NCOL.LT.2) GOTO 1430
C-------------LEFT FACE
              IF(J.GT.1) THEN
                IF(QC7(J,I,K,1,3).LT.0.) THEN
                  IF(ICBND2(J-1,I,K).EQ.1) THEN
                    ITEMP=ITEMP+1
                  ENDIF
                ENDIF
              ENDIF
C-------------RIGHT FACE      
              IF(J.LT.NCOL) THEN
                IF(QC7(J,I,K,1,4).LT.0.) THEN
                  IF(ICBND2(J+1,I,K).EQ.1) THEN
                    ITEMP=ITEMP+1
                  ENDIF
                ENDIF
              ENDIF
C      
 1430         CONTINUE
C      
              IF(ITEMP.EQ.0) THEN
                INDX=INDX+1
                ID2D(INDX)=N
                ICBND2(J,I,K)=2
                IF(INDX.EQ.NICBND2) GO TO 10
              ENDIF
C      
            ENDDO
          ENDDO
        ENDDO
      ENDDO
10    CONTINUE
C
C--RETURN
  999 RETURN
      END
C
C
      SUBROUTINE NODE2KIJ(NODE,NLAY,NROW,NCOL,K,I,J)
C *********************************************************************
C THIS SUBROUTINE RETURNS LAYER, ROW, COLUMN INDEX FROM NODE
C *********************************************************************
      INTEGER NODE,NLAY,NROW,NCOL,K,I,J,NCR
C
      NCR=NROW*NCOL
      K=((NODE-1)/NCR)+1
      I=NODE-(K-1)*NCR
      I=((I-1)/NCOL)+1
      J=NODE-(K-1)*NCR-(I-1)*NCOL
C
      RETURN
      END
C
C
      FUNCTION SADV5Q3(NCOL,NROW,NLAY,JJ,II,KK,ICBUND,DELR,DELC,DH,
     & COLD,QX,QY,QZ,DTRANS,NADVFD,IDIR3)
C *******************************************************************
C THIS FUNCTION COMPUTES ADVECTIVE MASS FLUX BETWEEN CELL (JJ,II,KK)
C AND THE SURROUNDING CELLS DURING TIME INCREMENT DTRANS.  MASS IS
C MOVING OUT OF THE CELL IF SADV5Q > 0, INTO THE CELL IF SADV5Q < 0.
C NADVFD=1 IS FOR THE UPSTREAM SCHEME; NADVFD=2 IS FOR THE CENTRAL
C WEIGHTING SCHEME.
C
C IDIR3=1 RECORD MASS MOVING IN INTO QCTMP2
C IDIR3=2 RECORD MASS MOVING OUT INTO QCTMP3
C
C *******************************************************************
C last modified: 02-15-2005
C
      USE MIN_SAT
      IMPLICIT  NONE
      INTEGER   ICBUND,NCOL,NROW,NLAY,JJ,II,KK,NADVFD
      REAL      SADV5Q,COLD,QX,QY,QZ,DELR,DELC,DH,AREA,DTRANS,QCTMP,
     &          WW,THKSAT,ALPHA,CTMP,SADV5Q3
      DIMENSION ICBUND(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY),
     &          QX(NCOL,NROW,NLAY),QY(NCOL,NROW,NLAY),
     &          QZ(NCOL,NROW,NLAY),DELR(NCOL),DELC(NROW),
     &          DH(NCOL,NROW,NLAY)
      INTEGER IDIR3
      REAL QCTMP1,QCTMP2,QCTMP3
C
C--SET QCTMP = 0 FOR ACCUMULATING Q*C*DTRANS IN ALL FACES
      QCTMP=0.
      QCTMP2=0.
      QCTMP3=0.
C
C--CALCULATE IN THE Z DIRECTION
      IF(NLAY.LT.2) GOTO 410
      AREA=DELR(JJ)*DELC(II)
C--TOP FACE
      IF(KK.GT.1) THEN
        IF(ICBUND(JJ,II,KK-1).NE.0) THEN
          WW=DH(JJ,II,KK)/(DH(JJ,II,KK-1)+DH(JJ,II,KK))
          ALPHA=0.
          IF(QZ(JJ,II,KK-1).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK-1)*ALPHA + COLD(JJ,II,KK)*(1.-ALPHA)
          QCTMP=QCTMP-QZ(JJ,II,KK-1)*CTMP*AREA*DTRANS
          QCTMP1=-QZ(JJ,II,KK-1)*CTMP*AREA*DTRANS
          IF(QCTMP1.LT.0) THEN
            QCTMP2=QCTMP2+QCTMP1
          ELSE
            QCTMP3=QCTMP3+QCTMP1
          ENDIF
        ENDIF
      ENDIF
C--BOTTOM FACE
      IF(KK.LT.NLAY) THEN
        IF(ICBUND(JJ,II,KK+1).NE.0) THEN
          WW=DH(JJ,II,KK+1)/(DH(JJ,II,KK)+DH(JJ,II,KK+1))
          ALPHA=0.
          IF(QZ(JJ,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK)*ALPHA + COLD(JJ,II,KK+1)*(1.-ALPHA)
          QCTMP=QCTMP+QZ(JJ,II,KK)*CTMP*AREA*DTRANS
          QCTMP1=QZ(JJ,II,KK)*CTMP*AREA*DTRANS
          IF(QCTMP1.LT.0) THEN
            QCTMP2=QCTMP2+QCTMP1
          ELSE
            QCTMP3=QCTMP3+QCTMP1
          ENDIF
        ENDIF
      ENDIF
C
C--CALCULATE IN THE Y DIRECTION
  410 IF(NROW.LT.2) GOTO 420
C--BACK FACE
      IF(II.GT.1) THEN
        IF(ICBUND(JJ,II-1,KK).NE.0) THEN
          WW=DELC(II)/(DELC(II)+DELC(II-1))
          THKSAT=DH(JJ,II-1,KK)*WW+DH(JJ,II,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN
            THKSAT=ABS(DH(JJ,II-1,KK))*WW+ABS(DH(JJ,II,KK))*(1.-WW)
          ENDIF
          AREA=DELR(JJ)*THKSAT
          ALPHA=0.
          IF(QY(JJ,II-1,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II-1,KK)*ALPHA + COLD(JJ,II,KK)*(1.-ALPHA)
          QCTMP=QCTMP-QY(JJ,II-1,KK)*CTMP*AREA*DTRANS
          QCTMP1=-QY(JJ,II-1,KK)*CTMP*AREA*DTRANS
          IF(QCTMP1.LT.0) THEN
            QCTMP2=QCTMP2+QCTMP1
          ELSE
            QCTMP3=QCTMP3+QCTMP1
          ENDIF
        ENDIF
      ENDIF
C--FRONT FACE
      IF(II.LT.NROW) THEN
        IF(ICBUND(JJ,II+1,KK).NE.0) THEN
          WW=DELC(II+1)/(DELC(II+1)+DELC(II))
          THKSAT=DH(JJ,II,KK)*WW+DH(JJ,II+1,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN
            THKSAT=ABS(DH(JJ,II,KK))*WW+ABS(DH(JJ,II+1,KK))*(1.-WW)
          ENDIF
          AREA=DELR(JJ)*THKSAT
          ALPHA=0.
          IF(QY(JJ,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK)*ALPHA + COLD(JJ,II+1,KK)*(1.-ALPHA)
          QCTMP=QCTMP+QY(JJ,II,KK)*CTMP*AREA*DTRANS
          QCTMP1=QY(JJ,II,KK)*CTMP*AREA*DTRANS
          IF(QCTMP1.LT.0) THEN
            QCTMP2=QCTMP2+QCTMP1
          ELSE
            QCTMP3=QCTMP3+QCTMP1
          ENDIF
        ENDIF
      ENDIF
C
C--CALCULATE IN THE X DIRECTION
  420 IF(NCOL.LT.2) GOTO 430
C--LEFT FACE
      IF(JJ.GT.1) THEN
        IF(ICBUND(JJ-1,II,KK).NE.0) THEN
          WW=DELR(JJ)/(DELR(JJ)+DELR(JJ-1))
          THKSAT=DH(JJ-1,II,KK)*WW+DH(JJ,II,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN
            THKSAT=ABS(DH(JJ-1,II,KK))*WW+ABS(DH(JJ,II,KK))*(1.-WW)
          ENDIF
          AREA=DELC(II)*THKSAT
          ALPHA=0.
          IF(QX(JJ-1,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ-1,II,KK)*ALPHA + COLD(JJ,II,KK)*(1.-ALPHA)
          QCTMP=QCTMP-QX(JJ-1,II,KK)*CTMP*AREA*DTRANS
          QCTMP1=-QX(JJ-1,II,KK)*CTMP*AREA*DTRANS
          IF(QCTMP1.LT.0) THEN
            QCTMP2=QCTMP2+QCTMP1
          ELSE
            QCTMP3=QCTMP3+QCTMP1
          ENDIF
        ENDIF
      ENDIF
C--RIGHT FACE
      IF(JJ.LT.NCOL) THEN
        IF(ICBUND(JJ+1,II,KK).NE.0) THEN
          WW=DELR(JJ+1)/(DELR(JJ+1)+DELR(JJ))
          THKSAT=DH(JJ,II,KK)*WW+DH(JJ+1,II,KK)*(1.-WW)
          IF(DOMINSAT.EQ..TRUE.) THEN
            THKSAT=ABS(DH(JJ,II,KK))*WW+ABS(DH(JJ+1,II,KK))*(1.-WW)
          ENDIF
          AREA=DELC(II)*THKSAT
          ALPHA=0.
          IF(QX(JJ,II,KK).GT.0) ALPHA=1.
          IF(NADVFD.EQ.2) ALPHA=WW
          CTMP=COLD(JJ,II,KK)*ALPHA + COLD(JJ+1,II,KK)*(1.-ALPHA)
          QCTMP=QCTMP+QX(JJ,II,KK)*CTMP*AREA*DTRANS
          QCTMP1=QX(JJ,II,KK)*CTMP*AREA*DTRANS
          IF(QCTMP1.LT.0) THEN
            QCTMP2=QCTMP2+QCTMP1
          ELSE
            QCTMP3=QCTMP3+QCTMP1
          ENDIF
        ENDIF
      ENDIF
C
C--ASSIGN QCTMP TO THE FUNCTION AND RETURN
  430 CONTINUE
      IF(IDIR3.EQ.1) THEN
        SADV5Q3=QCTMP2
      ELSEIF(IDIR3.EQ.2)THEN
        SADV5Q3=QCTMP3
      ELSE
        STOP 'SET IDIR3 TO 1 OR 2'
      ENDIF
C
      RETURN
      END
