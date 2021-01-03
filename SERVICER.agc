### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SERVICER.agc
## Purpose:     The main source file for Luminary revision 069.
##              It is part of the source code for the original release
##              of the flight software for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 10. The actual flown
##              version was Luminary 69 revision 2, which included a
##              newer lunar gravity model and only affected module 2.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 858-896
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-13 MAS  Created from Luminary 99.
##              2016-12-18 MAS  Updated from comment-proofed Luminary 99 version.
##              2017-01-21 HG   Transcribed
##              2017-01-23 HG   Fix operation DAS -> DXCH
##                                            CS  -> CA
##		2017-01-28 RSB	Proofed comment text using octopus/prooferComments
##				and fixed errors found.
##		2017-03-14 RSB	Comment-text fixes noted in proofing Luminary 116.
##		2017-03-16 RSB	Comment-text fixes identified in 5-way
##				side-by-side diff of Luminary 69/99/116/131/210.

## Page 858
                BANK            37
                SETLOC          SERV1
                BANK

                EBANK=          DVCNTR
# *************************************   PREREAD   **************************************************************


                COUNT*          $$/SERV

PREREAD         CAF             SEVEN                   # 5.7 SPOT TO SKIP LASTBIAS AFTER
                TC              GNUFAZE5                # RESTART.
                CAF             PRIO21
                TC              NOVAC
                EBANK=          NBDX
                2CADR           LASTBIAS                # DO LAST GYRO COMPENSATION IN FREE FALL

BIBIBIAS        TC              PIPASR          +3      # CLEAR + READ PIPS LAST TIME IN FRE5+F133
                                                        # DO NOT DESTROY VALUE OF PIPTIME1

                CS              FLAGWRD7
                MASK            SUPER011                # SET V37FLAG AND AVEGFLAG (BITS 5 AND 6
                ADS             FLAGWRD7                #    OF FLAGWRD7)

                CS              DRFTBIT
                MASK            FLAGWRD2                # RESET DRIFTFLAG
                TS              FLAGWRD2

                CAF             FOUR                    # INITIALIZE DV MONITOR
                TS              PIPAGE

                CAF             ENDJBCAD                # POINT OUTROUTE TO END-OF-JOB.
                TS              OUTROUTE

                CAF             PRIO22
                TC              FINDVAC                 # TO FIRST ENTRY TO AVERAGE G.
                EBANK=          DVCNTR
                2CADR           NORMLIZE

                CA              TWO                     # 5.2SPOT FOR REREADAC AND NORMLIZE
GOREADAX        TC              GNUTFAZ5
                CA              2SECS                   # WAIT TWO SECONDS FOR READACCS
                TC              VARDELAY

## Page 859
# *************************************   READACCS   *************************************************************
READACCS        CS              OCT37771                # THIS PIECE OF CODING ATTEMPTS TO
                AD              TIME5                   # SYNCHRONIZE READACCS WITH THE DIGITAL
                CCS             A                       # AUTOPILOT SO THAT A PAXIS RUPT WILL
                CS              ONE                     # OCCUR APPROXIMATELY 70 MILLISECONDS
                TCF             +2                      # FOLLOWING THE READACCS RUPT.  THE 70 MS
                CA              ONE                     # OFFSET WAS CHOSEN SO THAT THE PAXIS
  +2            ADS             TIME5                   # RUPT WOULD NOT OCCUR SIMULTANEOUSLY
                                                        # WITH ANY OF THE 8 SUBSEQUENT R10,R11
                                                        # INTERRUPTS -- THUS MINIMIZING THE POSS-
                                                        # IBILITY OF LOSING DOWNRUPTS.

                TC              PIPASR                  # READ THE PIPAS.

PIPSDONE        CA              FIVE
                TC              GNUFAZE5
REDO5.5         CAF             ONE
                TS              PIPAGE

                CA              PRIO20
                TC              FINDVAC
                EBANK=          DVCNTR
                2CADR           SERVICER                # SET UP SERVICER JOB

                CA              BIT9
                EXTEND
                WOR             DSALMOUT                # TURN ON TEST CONNECTOR OUTBIT

                CA              FLAGWRD7
                MASK            AVEGFBIT
                EXTEND
                BZF             AVEGOUT                 # AVEGFLAG DOWN - SET UP FINAL EXIT

                CA              FLAGWRD6
                MASK            MUNFLBIT
                EXTEND
                BZF             MAKEACCS                # MUNFLAG CLEAR - BYPASS LR AND DISP.

                CCS             PHASE2
                TCF             MAKEACCS                # PHASE 2 ACTIVATED - AVOID MULTIPLE R10.

                CAF             SEVEN                   # SET PIPCTR FOR 4X/SEC RATE.
                TS              PIPCTR

                CS              TIME1                   # SET TBASE2 .05 SECONDS IN THE PAST.
                AD              FIVE
                AD              NEG1/2
                AD              NEG1/2
                XCH             TBASE2

## Page 860
                CAF             DEC17                   # 2.21SPOT FOR R10,R11
                TS              L
                COM
                DXCH            -PHASE2

                CAF             OCT24                   # FIRST R10,R11 IN .200 SECONDS.
                TC              WAITLIST
                EBANK=          UNIT/R/
                2CADR           R10,R11

MAKEACCS        CA              FOUR
                TCF             GOREADAX                # DO PHASE CHANGE AND RECALL READACCS


AVEGOUT         EXTEND
                DCA             AVOUTCAD                # SET UP FINAL SERVICER EXIT
                DXCH            AVGEXIT

                CA              FOUR                    # SET 5.4 SPOT FOR REREADAC AND SERVICER
                TC              GNUTFAZ5                # IF REREADAC IS CALLED, IT WILL EXIT
                TC              TASKOVER                # END TASK WITHOUT CALLING READACCS


GNUTFAZ5        TS              L                       # SAVE INPUT IN L
                CS              TIME1
                TS              TBASE5                  # SET TBASE5
                TCF             +2


GNUFAZE5        TS              L                       # SAVE INPUT IN L
                CS              L                       # -PHASE IN A, PHASE IN L
                DXCH            -PHASE5                 # SET -PHASE5,PHASE5
                TC              Q


                EBANK=          DVCNTR
AVOUTCAD        2CADR           AVGEND

ENDJBCAD        CADR            SERVEXIT        +2

OCT37771        OCT             37771

                BANK            33
                SETLOC          SERVICES
                BANK

                COUNT*          $$/SERV

## Page 861
# *************************************   SERVICER   *************************************************************

SERVICER        TC              PHASCHNG                # RESTART REREADAC + SERVICER
                OCT             16035
                OCT             20000
                EBANK=          DVCNTR
                2CADR           GETABVAL

                CAF             PRIO31                  # INITIALIZE 1/PIPADT IN CASE RESTART HAS
                TS              1/PIPADT                # CAUSED LASTBIAS TO BE SKIPPED.


                TC              BANKCALL                # PIPA COMPENSATION CALL
                CADR            1/PIPA

GETABVAL        TC              INTPRET
                VLOAD           ABVAL
                                DELV
                EXIT
                CA              MPAC
                TS              ABDELV                  # ABDELV = CM/SEC*2(-14).
                EXTEND
                MP              KPIP
                DXCH            ABDVCONV                # ABDVCONV = M/CS * 2(-5).
                EXTEND
                DCA             MASS
                DXCH            MASS1                   # INITIALIZE MASS1 IN CASE WE SKIP MASSMON
MASSMON         CS              FLAGWRD8                # ARE WE ON THE SURFACE?
                MASK            SURFFBIT
                EXTEND
                BZF             MOONSPOT                # YES:  BYPASS MASS MESS

                CA              FLGWRD10                # NO:   WHICH VEX SHOULD BE USED?
                MASK            APSFLBIT
                CCS             A
                EXTEND                                  # IF EXTEND IS EXECUTED, APSVEX --> A,
                DCA             APSVEX                  #   OTHERWISE DPSVEX --> A
                TS              Q

                EXTEND
                DCA             ABDVCONV
                EXTEND
OCT10002        DV              Q                       # WHERE APPROPRIATE VEX RESIDES
                EXTEND
                MP              MASS
                DXCH            MASS1
                EXTEND
                DCA             MASS
                DAS             MASS1

## Page 862
MOONSPOT        CA              KPIP1                   # TP MPAC = ABDELV AT 2(14) CM/SEC
                TC              SHORTMP                 # MULTIPLY BY KPIP1 TO GET
                DXCH            MPAC                    # ABDELV AT 2(7) M/CS
                DAS             DVTOTAL                 # UPDATE DVTOTAL FOR DISPLAY

                CA              PRIO24                  # PROTECT NBSM IN XNBNDX
                TC              PRIOCHNG

                TC              TMPTOSPT

                TC              BANKCALL
                CADR            QUICTRIG

                TC              INTPRET
                AXC,1           CALL
                                XNBPIP
                                XNBNDX
                EXIT

                CA              PRIO20                  # RESTORE PRIO 20
                TC              PRIOCHNG

                TC              INTPRET
AVERAGEG        BON             CALL
                                MUNFLAG
                                RVBOTH
                                CALCRVG
                EXIT
GOSERV          TC              QUIKFAZ5

COPYCYCL        TC              COPYCYC

#               CA              ZERO                     A IS ZERO ON RETURN FROM COPYCYC
                TS              PIPATMPX                # STILL UNDER INHINT
                TS              PIPATMPY
                TS              PIPATMPZ

                CS              STEERBIT                # CLEAR STEERSW PRIOR TO DVMON.
                MASK            FLAGWRD2
                TS              FLAGWRD2

                CAF             IDLEFBIT                # IS THE IDLE FLAG SET?
                MASK            FLAGWRD7
                CCS             A
                TCF             NODVMON1                # IDLEFLAG = 1, HENCE SET AUXFLAG TO 0.

                CS              FLAGWRD6
                MASK            AUXFLBIT
                CCS             A
                TCF             NODVMON2                # AUXFLAG = 0, HENCE SET AUXFLAG TO 1.

## Page 863

DVMON           CS              DVTHRUSH
                AD              ABDELV
                EXTEND
                BZMF            LOTHRUST

                CS              FLAGWRD2                # SET STEERSW.
                MASK            STEERBIT
                ADS             FLAGWRD2

DVCNTSET        CAF             ONE                     # ALLOW TWO PASSES MAXIMUM NOW THAT
                TS              DVCNTR                  # THRUXT HAS BEEN DETECTED.

                CA              FLGWRD10                # BRANCH IF APSFLAG IS SET.
                MASK            APSFLBIT
                CCS             A
                TCF             USEJETS

                CA              BIT9                    # CHECK GIMBAL FAIL BIT
                EXTEND
                RAND            CHAN32
                EXTEND
                BZF             USEJETS

USEGTS          CS              USEQRJTS
                MASK            DAPBOOLS
                TS              DAPBOOLS
                TCF             SERVOUT

NODVMON1        CS              AUXFLBIT                # SET AUXFLAG TO 0.
                MASK            FLAGWRD6
                TS              FLAGWRD6
                TCF             USEJETS
NODVMON2        CS              FLAGWRD6                # SET AUXFLAG TO 1.
                MASK            AUXFLBIT
                ADS             FLAGWRD6
                TCF             USEJETS

LOTHRUST        TC              QUIKFAZ5
                CCS             DVCNTR
                TCF             DECCNTR

                CCS             PHASE4                  # COMFAIL JOB ACTIVE?
                TCF             SERVOUT                 # YES   WON'T NEED ANOTHER.

                TC              PHASCHNG                # 4.37SPOT FOR COMFAIL.
                OCT             00374

                CAF             PRIO25
                TC              NOVAC
                EBANK=          WHICH

## Page 864
                2CADR           COMFAIL
                TCF             SERVOUT

DECCNTR         TS              DVCNTR1
                TC              QUIKFAZ5
                CA              DVCNTR1
                TS              DVCNTR
                INHINT
                TC              IBNKCALL                # IF THRUST IS LOW, NO STEERING IS DONE
                CADR            STOPRATE                # AND THE DESIRED RATES ARE SET TO ZERO.
USEJETS         CS              DAPBOOLS
                MASK            USEQRJTS
                ADS             DAPBOOLS
SERVOUT         RELINT
                TC              BANKCALL
                CADR            1/ACCS

                CAF             EBANK7                  # RESTORE EBANK AFTER 1/ACCS.
                TS              EBANK
                CA              PRIORITY
                MASK            LOW9
                TS              PUSHLOC
                ZL
                DXCH            FIXLOC                  # FIXLOC AND OVFIND

                TC              QUIKFAZ5
                EXTEND                                  # EXIT TO SELECTED ROUTINE WHETHER THERE
                DCA             AVGEXIT                 # IS THRUST OR NOT.  THE STATE OF STEERSW
                DXCH            Z                       # WILL CONVEY THIS INFORMATION.

                BANK            32
                SETLOC          SERV2
                BANK
                COUNT*          $$/SERV

AVGEND          CA              PIPTIME         +1      # FINAL AVERAGE G EXIT
                TS              1/PIPADT                # SET UP FREE FALL GYRO COMPENSATION.

                TC              UPFLAG                  # SET DRIFT FLAG.
                ADRES           DRIFTFLG

                TC              BANKCALL
                CADR            PIPFREE

                CS              BIT9
                EXTEND
                WAND            DSALMOUT

                TC              2PHSCHNG

## Page 865
                OCT             5                       # GROUP 5 OFF
                OCT             05022                   # GROUP 2 ON
                OCT             20000

                TC              INTPRET
                SET             CLEAR
                                NOR29FLG                # SHUT OFF R29 WHEN SERVICER ENDS.
                                SWANDISP                # SHUT OFF R10 WHEN SERVICER ENDS.
                CLEAR           CALL                    # RESET MUNFLAG.
                                MUNFLAG
                                AVETOMID
                CLEAR           EXIT
                                V37FLAG
AVERTRN         CA              OUTROUTE                # RETURN TO DESIRED POINT.
                TC              BANKJUMP

OUTGOAVE        =               AVERTRN

DVCNTR1         =               MASS1

## Page 866
SERVIDLE        EXTEND                                  # DISCONNECT SERVICER FROM ALL GUIDANCE
                DCA             SVEXTADR
                DXCH            AVGEXIT

                CS              FLAGWRD7                # DISCONNECT THE DELTA-V MONITOR
                MASK            IDLEFBIT
                ADS             FLAGWRD7

                CAF             LRBYBIT                 # TERMINATE R12 IF RUNNING.
                TS              FLGWRD11

                EXTEND
                DCA             NEG0
                DXCH            -PHASE1

                CA              FLAGWRD6                # DO NOT TURN OFF PHASE 2 IF MUNFLAG SET.
                MASK            MUNFLBIT
                CCS             A
                TCF             +4

                EXTEND
                DCA             NEG0
                DXCH            -PHASE2

   +4           EXTEND
                DCA             NEG0
                DXCH            -PHASE3

                EXTEND
                DCA             NEG0
                DXCH            -PHASE6

                CAF             OCT33                   # 4.33SPOT FOR GOPOOFIX
                TS              L
                COM
                DXCH            -PHASE4

                TCF             WHIMPER                 # PERFORM A SOFTWARE RESTART AND PROCEED
                                                        # TO GOTOPOOH WHILE SERVICER CONTINUES TO
                                                        # RUN, ALBEIT IN A GROUND STATE WHERE
                                                        # ONLY STATE-VECTOR DEPENDENT FUNCTIONS
                                                        # ARE MAINTAINED.

                EBANK=          DVCNTR
SVEXTADR        2CADR           SERVEXIT
                BANK            32
                SETLOC          SERV1

## Page 867
                BANK
                COUNT*          $$/SERV

SERVEXIT        CA              THREE
                TC              GNUFAZE5

   +2           TCF             ENDOFJOB

                BANK            23
                SETLOC          SERVICES
                BANK

                COUNT*          $$/SERV

## Page 868
# NORMLIZE AND COPYCYCL

NORMLIZE        TC              INTPRET
                VLOAD           BOFF
                                RN1
                                MUNFLAG
                                NORMLIZ1
                VSL6            MXV
                                REFSMMAT
                STCALL          R
                                MUNGRAV
                VLOAD           VSL1
                                VN1
                MXV
                                REFSMMAT
                STOVL           V
                                V(CSM)
                VXV             UNIT
                                R(CSM)
                STORE           UHYP
ASCSPOT         EXIT
                EXTEND                                  # MAKE SURE GOUP 2 IS OFF.
                DCA             NEG0
                DXCH            -PHASE2

                TCF             NORMLIZ2

NORMLIZ1        CALL
                                CALCGRAV
                EXIT

NORMLIZ2        CA              EIGHTEEN
                TC              COPYCYC         +1      # DO NOT COPY MASS IN NORMLIZE
                TC              ENDOFJOB


COPYCYC         CA              OCT24                   # DEC 20
 +1             INHINT
 +2             MASK            NEG1                    # REDUCE BY 1 IF ODD
                TS              ITEMP1
                EXTEND
                INDEX           ITEMP1
                DCA             RN1
                INDEX           ITEMP1
                DXCH            RN
                CCS             ITEMP1
                TCF             COPYCYC         +2
                TC              Q                       # RETURN UNDER INHINT

## Page 869

EIGHTEEN        DEC             18

## Page 870
# ******************* PIPA READER ********************

#                 MOD NO. 00  BY D. LICKLY  DEC.9 1966


# FUNCTIONAL DESCRIPTION

#    SUBROUTINE TO READ PIPA COUNTERS, TRYING TO BE VERY CAREFUL SO THAT IT WILL BE RESTARTABLE.
#    PIPA READINGS ARE STORED IN THE VECTOR DELV. THE HIGH ORDER PART OF EACH COMPONENT CONTAINS THE PIPA READING,
#    RESTARTS BEGIN AT REREADAC.


#    AT THE END OF THE PIPA READER THE CDUS ARE READ AND STORED AS A
# VECTOR IN CDUTEMP.  THE HIGH ORDER PART OF EACH COMPONENT CONTAINS
# THE CDU READING IN 2S COMP IN THE ORDER CDUX,Y,Z.  THE THRUST
# VECTOR ESTIMATOR IN FINDCDUD REQUIRES THE CDUS BE READ AT PIPTIME.

# CALLING SEQUENCE AND EXIT

#    CALL VIA TC, ISWCALL, ETC.

#    EXIT IS VIA Q.


#

# INPUT

#    INPUT IS THROUGH THE COUNTERS PIPAX, PIPAY, PIPAZ, AND TIME2.


# OUTPUT

#    HIGH ORDER COMPONENTS OF THE VECTOR DELV CONTAIN THE PIPA READINGS.
#    PIPTIME CONTAINS TIME OF PIPA READING.


# DEBRIS (ERASABLE LOCATIONS DESTROYED BY PROGRAM)

#          TEMX   TEMY   TEMZ   PIPAGE

                BANK            37
                SETLOC          SERV1
                BANK

                COUNT*          $$/SERV

PIPASR          EXTEND

## Page 871
                DCA             TIME2
                DXCH            PIPTIME1                # CURRENT TIME POSITIVE VALUE
       +3       CS              ZERO                    # INITIALIZE THESE AT NEG. ZERO.
                TS              TEMX
                TS              TEMY
                TS              TEMZ

                CA              ZERO
                TS              DELVZ                   # OTHER DELVS OK INCLUDING LOW ORDER
                TS              DELVY
                TS              PIPAGE                  # SHOW PIPA READING IN PROGRESS

REPIP1          EXTEND
                DCS             PIPAX                   # X AND Y PIPS READ
                DXCH            TEMX
                DXCH            PIPAX                   # PIPAS SET TO NEG ZERO AS READ.
                TS              DELVX
                LXCH            DELVY

REPIP3          CS              PIPAZ                   # REPEAT PROCESS FOR Z PIP
                XCH             TEMZ
                XCH             PIPAZ
DODELVZ         TS              DELVZ

REPIP4          EXTEND                                  # COMPUTE GUIDANCE PERIOD
                DCA             PIPTIME1
                DXCH            PGUIDE
                EXTEND
                DCS             PIPTIME
                DAS             PGUIDE

                CA              CDUX                    # READ CDUS INTO HIGH ORDER CDUTEMPS
                TS              CDUTEMPX
                CA              CDUY
                TS              CDUTEMPY
                CA              CDUZ
                TS              CDUTEMPZ
                CA              DELVX
                TS              PIPATMPX
                CA              DELVY
                TS              PIPATMPY
                CA              DELVZ
                TS              PIPATMPZ

                TC              Q


REREADAC        CCS             PIPAGE
                TCF             READACCS                # PIP READING NOT STARTED. GO TO BEGINNING

## Page 872

                CAF             DONEADR                 # SET UP RETURN FROM PIPASR
                TS              Q

                CCS             DELVZ
                TCF             REPIP4                  # Z DONE, GO DO CDUS
                TCF             +3                      # Z NOT DONE, CHECK Y.
                TCF             REPIP4
                TCF             REPIP4

                ZL
                CCS             DELVY
                TCF             +3
                TCF             CHKTEMX                 # Y NOT DONE, CHECK X.
                TCF             +1
                LXCH            PIPAZ                   # Y DONE, ZERO Z PIP.

                CCS             TEMZ
                CS              TEMZ                    # TEMZ NOT = -0, CONTAINS -PIPAZ VALUE.
                TCF             DODELVZ
                TCF             -2
                LXCH            DELVZ                   # TEMZ = -0, L HAS ZPIP VALUE.
                TCF             REPIP4

CHKTEMX         CCS             TEMX                    # HAS THIS CHANGED
                CS              TEMX                    # YES
                TCF             +3                      # YES
                TCF             -2                      # YES
                TCF             REPIP1                  # NO
                TS              DELVX

                CS              TEMY
                TS              DELVY

                CS              ZERO                    # ZERO X AND Y PIPS
                DXCH            PIPAX                   # L STILL ZERO FROM ABOVE

                TCF             REPIP3

DONEADR         GENADR          PIPSDONE

## Page 873
                BANK            33
                SETLOC          SERVICES
                BANK

                COUNT*          $$/SERV

TMPTOSPT        CA              CDUTEMPY                # THIS SUBROUTINE, CALLED BY AN RTB FROM
                TS              CDUSPOTY                # INTERPRETIVE, LOADS THE CDUS CORRESPON-
                CA              CDUTEMPZ                # DING TO PIPTIME INTO THE CDUSPOT VECTOR.
                TS              CDUSPOTZ
                CA              CDUTEMPX
                TS              CDUSPOTX
                TC              Q

# LRHTASK IS A WAITLIST TASK SET BY READACCS DURING THE DESCENT BRAKING
# PHASE WHEN THE ALT TO THE LUNAR SURFACE IS LESS THAN 25,000 FT.  THIS
# TASK CLEARS THE ALTITUDE MEASUREMENT MADE DISCRETE AND INITIATES THE
# LANDING RADAR MEASUREMENT JOB (LRHJOB) TO TAKE A ALTITUDE MEASUREMENT
# 50 MS PRIOR TO THE NEXT READACCS TASK.

                BANK            21
                SETLOC          R10
                BANK

                COUNT*          $$/SERV

LRHTASK         CS              FLGWRD11
                MASK            LRBYBIT
                EXTEND
                BZF             GRP2OFF                 # LR BYPASS SET - BYPASS ALL LR READING.

                CA              READLBIT
                MASK            FLGWRD11                # IS READLR FLAG SET?
                EXTEND
                BZF             GRP2OFF                 # NO.  BYPASS LR READ.

                CS              FLGWRD11
                MASK            NOLRRBIT                # IS LR READ INHIBITED?
                EXTEND
                BZF             GRP2OFF                 # YES.  BYPASS LR READ.

                CA              PRIO32                  # LR READ OK   SET JOB TO DO IT
                TC              NOVAC                   # ABOUT 50 MS PRIOR TO PIPA READ
                EBANK=          HMEAS
                2CADR           LRHJOB
GRP2OFF         EXTEND
                DCA             NEG0
                DXCH            -PHASE2
                TCF             R10,R11A

## Page 874

                BANK            33
                SETLOC          SERVICES
                BANK

                COUNT*          $$/SERV

# HIGATASK IS ENTERED APPROXIMATELY 6 SECS PRIOR TO HIGATE DURING THE
# DESCENT PHASE.  HIGATASK SETS THE HIGATE FLAG (BIT11) AND THE LR INHIBIT
# FLAG (BIT10) IN LRSTAT.  THE HIGATJOB IS SET UP TO REPOSITION THE LR
# ANTENNA FROM POSITION 1 TO POSITION 2.  IF THE REPOSITIONING IS
# SUCCESSFUL THE ALT BEAM AND VELOCITY BEAMS ARE TRANSFORMED TO THE NEW
# ORIENTATION IN NB COORDINATES AND STORED IN ERASABLE.

HIGATASK        INHINT
                CS              PRIO3                   # SET HIGATE AND LR INHIBIT FLAGS
                MASK            FLGWRD11
                AD              PRIO3
                TS              FLGWRD11
                CAF             PRIO32
                TC              FINDVAC                 # SET LR POSITIONING JOB (POS2)
                EBANK=          HMEAS
                2CADR           HIGATJOB
                TCF             CONTSERV                # CONTINUE SERVICER

## Page 875
#   MUNRETRN IS THE RETURN LOC FROM SPECIAL AVE G ROUTINE (MUNRVG)

MUNRETRN        EXIT

                CS              FLGWRD11
                MASK            LRBYBIT
                EXTEND
                BZF             COPYCYC1                # BYPASS LR LOGIC IF BIT15 IS SET.

                CA              READLBIT                # SEE IF ALT < 35000 FT LAST CYCLE
                MASK            FLGWRD11
                EXTEND
                BZF             35KCHK                  # ALT WAS > 35000 FT LAST CYCLE   CHK NOW

                CAF             XORFLBIT                # WERE WE BELOW 30000 FT LAST PASS?
                MASK            FLGWRD11
                EXTEND
                BZF             XORCHK                  # NO - TEST THIS PASS

HITEST          CAF             PSTHIBIT                # CHECK FOR HIGATE
                MASK            FLGWRD11
                EXTEND
                BZF             HIGATCHK                # NOT AT HIGATE LAST CYCLE-CHK THIS CYCLE

POS2CHK         CAF             BIT7                    # VERIFY LR IN POS2
                EXTEND
                RAND            CHAN33
                EXTEND
                BZF             UPDATCHK                # IT IS-CHECK FOR LR UPDATE
                CAF             BIT13                   # NOT IN POS2-MAYBE REPOSITIONING
                EXTEND
                RAND            CHAN12
                EXTEND
                BZF             LRPOSALM                # LR NOT IN POS2 OR REPOSITIONING-BAD
                TCF             CONTSERV                # LR BEING REPOSITIONED-CONTINUE SERV

HIGATCHK        CA              TTF/8                   # IS TTF > CRITERION?   (TTF IS NEGATIVE)
                AD              RPCRTIME
                EXTEND
                BZMF            POS1CHK                 # NO

                CA              EBANK4                  # MUST SWITCH EBANKS
                XCH             EBANK
                TS              L                       # SAVE IN L

                EBANK=          XNBPIP
                CS              XNBPIP                  # UXBXP IN GSOP CH5
                EBANK=          DVCNTR
                LXCH            EBANK                   # RESTORE EBANK
                AD              RPCRTQSW                # QSW - UXBXP

## Page 876

                EXTEND
                BZMF            HIGATASK                # IF UXBXP > QSW, THEN REPOSITION

POS1CHK         CAF             BIT6                    # HIGATE NOT IN SIGHT-DO POS1 CHK
                EXTEND
                RAND            33
                EXTEND
                BZF             UPDATCHK                # LR IN POS1-CHECK FOR LR UPDATE

LRPOSALM        TC              ALARM                   # LR NOT IN PROPER POS-ALARM-BYPASS UPDATE
                OCT             511                     # AND CONTINUE SERVICER
CONTSERV        INHINT
                CS              BITS4-7
                MASK            FLGWRD11                # CLEAR LR MEASUREMENT MADE DISCRETES.
                TS              FLGWRD11

                TC              IBNKCALL                # SET LR LITES PROPERLY
                CADR            R12LITES

## Page 877
COPYCYC1        TC              QUIKFAZ5

R29?            CA              FLAGWRD3
                MASK            NR29&RDR
                CCS             A                       # IS NOR29FLG OR READRFLG SET?
                TCF             R29NODES                # YES, SO DON'T DESIGNATE.

                CA              RADMODES                # NO, SO R29 IS CALLED FOR.
                MASK            OCT10002                # IS THE RR NOT ZEROING ITS CDUS, AND
                CCS             A                       # IS THE RENDEZVOUS RADAR IN AUTO MODE?
                TCF             R29NODES                # NO, SO DON'T DESIGNATE.

                CA              RADMODES
                MASK            PRIO22
                CCS             A                       # IS RR REPOSITIONING OR REMODING?
                TCF             NOR29NOW                # YES; COME BACK IN 2 SECONDS & TRY AGAIN.

                TCF             R29

R29NODES        INHINT                                  # R29 NOT ALLOWED THIS CYCLE.
                CS              DESIGBIT                # SHOW THAT DESIGNATION IS OFF.
                MASK            RADMODES
                TS              RADMODES

NOR29NOW        TC              INTPRET                 # INTPRET DOES A RELINT.
                VLOAD           ABVAL                   # MPAC = ABVAL( NEW SM. POSITION VECTOR)
                                R1S
                PUSH            DSU                     #                                     (2)
                                /LAND/
                STORE           HCALC                   # NEW HCALC*2(24)M.
                DMPR            RTB
                                ALTCONV
                                SGNAGREE
                STOVL           ALTBITS                 # ALTITUDE FOR R10 IN BIT UNITS.
                                UNIT/R/
                VXV             VSL1
                                UHYP
                STOVL           UHZP                    # DOWNRANGE HALF-UNIT VECTOR FOR R10.
                                R1S
                VXM             VSR4
                                REFSMMAT
                STOVL           RN1                     # TEMP. REF. POSITION VECTOR*2(29)M.
                                V1S
                VXM             VSL1
                                REFSMMAT
                STOVL           VN1                     # TEMP. REF. VELOCITY VECTOR*2(7)M/CS.
                                UNIT/R/
                VXV             ABVAL
                                V1S

## Page 878
                SL1             DSQ
                DDV
                DMPR            RTB
                                ARCONV1
                                SGNAGREE
COPYCYC2        EXIT                                    # LEAVE ALTITUDE RATE COMPENSATION IN MPAC
                INHINT
                CA              UNIT/R/                 # UPDATE RUNIT FOR R10.
                TS              RUNIT
                CA              UNIT/R/         +2
                TS              RUNIT           +1
                CA              UNIT/R/         +4
                TS              RUNIT           +2
                CA              MPAC                    # LOAD NEW DALTRATE FOR R10.
                TS              DALTRATE

                EXTEND
                DCA             R1S
                DXCH            R
                EXTEND
                DCA             R1S             +2
                DXCH            R               +2
                EXTEND
                DCA             R1S             +4
                DXCH            R               +4
                EXTEND
                DCA             V1S
                DXCH            V
                EXTEND
                DCA             V1S             +2
                DXCH            V               +2
                EXTEND
                DCA             V1S             +4
                DXCH            V               +4

                TCF             COPYCYCL                # COMPLETE THE COYPCYCL.

## Page 879
#     ALTCHK COMPARES CURRENT ALTITUDE (IN HCALC) WITH A SPECIFIED ALTITUDE FROM A TABLE BEGINNING AT ALTCRIT.
# ITS CALLING SEQUENCE IS AS FOLLOWS:-

#        L        CAF    N
#        L+1      TC     BANKCALL
#        L+2      CADR   ALTCHK
#        L+3      RETURN HERE IF HCALC STILL > SPECIFIED CRITERION.   C(L) = +0.
#        L+4      RETURN HERE IF HCALC < OR = SPECIFIED CRITERION.   C(A) = C(L) = +0

# ALTCHK MUST BE BANKCALLED EVEN FROM ITS OWN BANK.   N IS THE LOCATION, RELATIVE TO THE TAG ALTCRIT,
# OF THE BEGINNING OF THE DP CONSTANT TO BE USED AS A CRITERION.

ALTCHK          EXTEND
                INDEX           A
                DCA             ALTCRIT
                DXCH            MPAC            +1
                EXTEND
                DCS             HCALC
                DAS             MPAC            +1
                TC              BRANCH          +4
                CAF             ZERO                    # BETTER THAN A NOOP, PERHAPS
                INCR            BUF2
                TCF             SWRETURN

ALTCRIT         =               25KFT

25KFT           2DEC            7620            B-24    # (0)
50KFT           2DEC            15240           B-24    # (2)
50FT            2DEC            15.24           B-24    # (4)
30KFT           2DEC            9144            B-24    # (6)
2KFT/SEC        DEC             6.096           B-7     # 2000 FT/SEC AT 2(7) M/CS


XORCHK          CAF             SIX                     # ARE WE BELOW 30000 FT?
                TC              BANKCALL
                CADR            ALTCHK
                TCF             HITEST                  # CONTINUE LR UPDATE
                TC              UPFLAG                  # YES: INHIBIT X-AXIS OVERRIDE
                ADRES           XOVINFLG
                TC              UPFLAG
                ADRES           XORFLG
                TCF             HITEST                  # CONTINUE LR UPDATE


35KCHK          CAF             TWO                     # ARE WE BELOW 35000 FT?

## Page 880
                TC              BANKCALL
                CADR            ALTCHK
                TCF             CONTSERV
                TC              UPFLAG
                ADRES           READLR                  # SET READLR FLAG TO ENABLE LR READING.
                TCF             CONTSERV

## Page 881
# *********************************************************************************************************
#

CALCGRAV        UNIT            PUSH                    # SAVE UNIT/R/ IN PUSHLIST            (18)
                STORE           UNIT/R/
                LXC,1           SLOAD                   # RTX2 = 0 IF EARTH ORBIT, =2 IF LUNAR.
                                RTX2
                                RTX2
                DCOMP           BMN
                                CALCGRV1
                VLOAD           DOT                     #                                     (12)
                                UNITZ
                                UNIT/R/
                SL1             PUSH                    #                                     (14)
                DSQ             BDSU
                                DP1/20
                PDDL            DDV
                                RESQ
                                34D                     # (RN)SQ
                STORE           32D                     # TEMP FOR (RE/RN)SQ
                DMP             DMP
                                20J
                VXSC            PDDL
                                UNIT/R/
                DMP             DMP
                                2J
                                32D
                VXSC            VSL1
                                UNITZ
                VAD             STADR
                STORE           UNITGOBL
                VAD             PUSH                    # MPAC = UNIT GRAVITY VECTOR.         (18)
CALCGRV1        DLOAD           NORM                    # PERFORM A NORMALIZATION ON RMAGSQ IN
                                34D                     # ORDER TO BE ABLE TO SCALE THE MU FOR
                                X2                      # MAXIMUM PRECISION.
                BDDV*           SLR*
                                -MUDT,1
                                0       -21D,2
                VXSC            STADR
                STORE           GDT1/2                  # SCALED AT 2(+7) M/CS
                RVQ

CALCRVG         VLOAD           VXM
                                DELV
                                REFSMMAT
                VXSC            VSL1
                                KPIP1
                STORE           DELVREF
                VSR1            PUSH
                VAD             PUSH                    # (DV-OLDGDT)/2 TO PD SCALED AT 2(+7)M/CS

## Page 882
                                GDT/2
                VAD             PDDL                    #                                     (18)
                                VN
                                PGUIDE
                SL              VXSC
                                6D
                VAD             STQ
                                RN
                                31D
                STCALL          RN1                     # TEMP STORAGE OF RN SCALED 2(+29)M
                                CALCGRAV

                VAD             VAD
                VAD
                                VN
                STCALL          VN1                     # TEMP STORAGE OF VN SCALED 2(+7)M/CS
                                31D

DP1/20          2DEC            0.05
SHIFT11         2DEC            1               B-11

## Page 883
#****************************************************************************************************************

# MUNRVG IS A SPECIAL AVERAGE G INTEGRATION ROUTINE USED BY THRUSTING
# PROGRAMS WHICH FUNCTION IN THE VICINITY OF AN ASSUMED SPHERICAL MOON.
# THE INPUT AND OUTPUT QUANTITIES ARE REFERENCED TO THE STABLE MEMBER
# COORDINATE SYSTEM.

RVBOTH          VLOAD           PUSH
                                G(CSM)
                VAD             PDDL
                                V(CSM)
                                PGUIDE
                DDV             VXSC
                                SHIFT11
                VAD
                                R(CSM)
                STCALL          R1S
                                MUNGRAV
                VAD             VAD
                                V(CSM)
                STADR
                STORE           V1S
                EXIT
                TC              QUIKFAZ5
                TC              INTPRET
                VLOAD
                                GDT1/2
                STOVL           G(CSM)
                                R1S
                STOVL           R(CSM)
                                V1S
                STORE           V(CSM)
                EXIT
                TC              QUIKFAZ5
                TC              INTPRET
MUNRVG          VLOAD           VXSC
                                DELV
                                KPIP2
                PUSH            VAD                     # 1ST PUSH: DELV IN UNITS OF 2(8) M/CS
                                GDT/2
                PUSH            VAD                     # 2ND PUSH: (DELV + GDT)/2, UNITS OF 2(7)
                                V                       #                                     (12)
                PDDL            DDV
                                PGUIDE
                                SHIFT11
                VXSC
                VAD
                                R
                STCALL          R1S                     # STORE R SCALED AT 2(+24)M.
                                MUNGRAV

## Page 884
                VAD             VAD
                VAD                                     #                                     (0)
                                V
                STORE           V1S                     # STORE V SCALED AT 2(+7)M/CS.
                ABVAL
                STOVL           ABVEL                   # STORE SPEED FOR LR AND DISPLAYS.
                                UNIT/R/
                DOT             SL1
                                V1S
                STOVL           HDOTDISP                # HDOT = V. UNIT(R)*2(7)M/CS.
                                R1S
                VXV             VSL2
                                WM
                STODL           DELVS                   # LUNAR ROTATION CORRECTION TERM*2(5)M/CS.
                                36D
                DSU
                                /LAND/
                STCALL          HCALC                   # FOR NOW, DISPLAY WHETHER POS OR NEG
                                MUNRETRN
MUNGRAV         UNIT                                    # AT 36D HAVE ABVAL(R), AT 34D R.R
                STODL           UNIT/R/
                                34D
                SL              BDDV
                                6D
                                -MUDTMUN
                DMP             VXSC
                                SHIFT11
                                UNIT/R/
                STORE           GDT1/2                  # 1/2GDT SCALED AT 2(7) M/CS.
                RVQ

1.95SECS        DEC             195
7.5             2DEC            .02286          B-6     # 7.5 FT/SEC AT 2(6) M/CS
2SEC(18)        2DEC            200             B-18
2SEC(28)        2OCT            00000   00310           # 2SEC AT 2(28)
BITS4-7         OCT             110

## Page 885
UPDATCHK        CAF             NOLRRBIT                # SEE IF LR UPDATE INHIBITED.
                MASK            FLGWRD11
                CCS             A
                TCF             CONTSERV                # IT IS-NO LR UPDATE
                CAF             RNGEDBIT                # NO INHIBIT - SEE ALT MEAS. THIS CYCLE.
                MASK            FLGWRD11
                EXTEND
                BZF             VMEASCHK                # NO ALT MEAS THIS CYCLE-CHECK FOR VEL

POSUPDAT        TC              INTPRET
                DLOAD           SL
                                HMEAS                   # COMPUTE SLANT RANGE
                                7
                DMP             VXSC
                                HSCAL                   # SLANT RANGE AT 2(21) M
                                HBEAMNB                 # RANGE VECTOR IN NB COORDINATES AT 2(22)M
                VXM
                                XNBPIP                  # CONVERT TO SM COORDINATES AT 2(23)M
                DOT             DSU
                                UNIT/R/                 # ALTITUDE AT 2(24)M
                                HCALC                   # DELTA H AT 2(24) M
                STORE           DELTAH
                EXIT

                CA              FLGWRD11
                MASK            PSTHIBIT
                EXTEND                                  # DO NOT PERFORM DATA REASONABLENESS TEST
                BZF             NOREASON                # UNTIL AFTER HIGATE

                TC              INTPRET
                ABS             DSU
                                DELQFIX                 # ABS(DELTAH) - DQFIX   50 FT NOM
                SL3             DSU                     # SCALE TO 2(21)
                                HCALC                   # ABS(DELTAH) - (50 + HCALC/8) AT 2(21)
                EXIT

                INCR            LRLCTR
                TC              BRANCH
                TCF             HFAIL                   # DELTA H TOO LARGE
                TCF             HFAIL                   # DELTA H TOO LARGE
                TC              DOWNFLAG                # TURN OFF ALT FAIL LAMP
                ADRES           HFLSHFLG

NOREASON        CS              FLGWRD11
                MASK            LRINHBIT
                CCS             A
                TCF             VMEASCHK                # UPDATE INHIBITED - TEST VELOCITY ANYWAY

                TC              INTPRET                 # DO POSITION UPDATE

## Page 886
                DLOAD           SR4
                                HCALC                   # RESCALE H TO 2(28)M
                EXIT
                EXTEND
                DCA             DELTAH                  # STORE DELTAH IN MPAC AND
                DXCH            MPAC                    # BRING HCALC INTO A,L
                TC              ALSIGNAG
                EXTEND                                  # IF HIGH PART OF HCALC IS NON ZERO, THEN
                BZF             +2                      # HCALC > HMAX,
                TCF             VMEASCHK                # SO UPDATE IS BYPASSED
                TS              MPAC            +2      #   FOR LATER SHORTMP

                CS              L                       # -H AT 2(14) M
                AD              LRHMAX                  # HMAX - H
                EXTEND
                BZMF            VMEASCHK                # IF H >HMAX, BYPASS UPDATE
                EXTEND
                MP              LRWH                    # WH(HMAX - H)
                EXTEND
                DV              LRHMAX                  # WH(1 - H/HMAX)
                TS              MPTEMP
                TC              SHORTMP2                # DELTAH (WH)(1 - H/HMAX) IN MPAC
                TC              INTPRET                 # MODE IS DP FROM ABOVE
                SL1
                VXSC            VAD
                                UNIT/R/                 # DELTAR = DH(WH)(1 - H/HMAX) UNIT/R/
                                R1S
                STCALL          GNUR
                                MUNGRAV
                EXIT

                TC              QUIKFAZ5

                CA              ZERO
                TC              GNURVST

VMEASCHK        TC              QUIKFAZ5                # RESTART AT NEXT LOCATION
                CS              FLGWRD11
                MASK            VELDABIT                # IS V READING AVAILABLE?
                CCS             A
                TCF             VALTCHK                 # NO   SEE IF V READING TO BE TAKEN

VELUPDAT        CS              VSELECT                 # PROCESS VELOCITY DATA
                TS              L
                ADS             L                       # -2 VSELECT IN L
                AD              L
                AD              L                       # -6 VSELECT IN A
                INDEX           FIXLOC
                DXCH            X1                      # X1 = -6 VSELECT, X2 = -2 VSELECT

## Page 887

                CA              EBANK4
                TS              EBANK
                EBANK=          LRXCDU

                CA              LRYCDU                  # STORE LRCDUS IN CDUSPOTS
                TS              CDUSPOT
                CA              LRZCDU
                TS              CDUSPOT         +2
                CA              LRXCDU
                TS              CDUSPOT         +4

                TC              BANKCALL
                CADR            QUICTRIG                # GET SINES AND COSINES FOR NBSM

                CA              FIXLOC
                TS              PUSHLOC                 # SET PD TO ZERO

                TC              INTPRET
                VLOAD*          CALL
                                VZBEAMNB,1              # CONVERT VBEAM FROM NB TO SM
                                *NBSM*
                PDDL            SL                      # STORE IN PD 0-5
                                VMEAS                   # LOAD VELOCITY MEASUREMENT
                                12D
                DMP*            PUSH                    # SCALE TO M/CS AT 2(6)
                                VZSCAL,2                # AND STORE IN PD 6-7
                EXIT
                CS              ONE
                TS              MODE                    # CHANGE STORE MODE TO VECTOR

                CA              PIPTEM                  # STORE DELV IN MPAC
                ZL
                DXCH            MPAC

                CA              PIPTEM          +1
                ZL
                DXCH            MPAC            +3

                CA              PIPTEM          +2
                ZL
                DXCH            MPAC            +5

                CA              EBANK7
                TS              EBANK                   # RESTORE EBANK 7
                EBANK=          DVCNTR
                TC              INTPRET
                VXSC            PDDL
                                KPIP1                   # SCALE DELV TO 2(7) M/CS AND PUSH
                                LRVTIME                 # TIME OF DELV AT 2(28)CS
                DSU             DDV

## Page 888
                                PIPTIME                 # TU - T(N-1)
                                2SEC(28)
                VXSC            VSL1                    # G(N-1)(TU - T(N-1))
                                GDT/2                   # SCALED AT 2(7) M/CS
                VAD             VAD                     # PUSH UP FOR DELV
                                V                       # VU = V(N-1) + DELVU + G(N-1) DTU
                VSL2            VAD                     # SCALE TO 2(5) M/CS AND SUBTRACT
                                DELVS                   #               MOON ROTATION.
                PUSH            ABVAL                   # STORE IN PD
                SR4             DAD                     # ABS(VM)/8 + 7.5 AT 2(6)
                                7.5
                STOVL           20D                     # STORE IN 20D AND PICK UP VM
                DOT             BDSU                    # V(EST) AT 2(6)
                                0                       # DELTAV = VMEAS - V(EST)
                PUSH            ABS
                DSU             EXIT                    # ABS(DV) - (7.5 + ABS(VM)/8))
                                20D

                INCR            LRMCTR
                TC              BRANCH
                TCF             VFAIL                   # DELTA V TOO LARGE     ALARM
                TCF             VFAIL                   # DELTA V TOO LARGE     ALARM

                TC              DOWNFLAG                # TURN OFF VEL FAIL LAMP
                ADRES           VFLSHFLG

                CA              FLGWRD11
                MASK            VXINHBIT
                EXTEND
                BZF             VUPDAT                  # IF VX INHIBIT RESET, INCORPORATE DATA.

                TC              DOWNFLAG
                ADRES           VXINH                   # RESET VX INHIBIT

                CA              VSELECT
                AD              NEG2                    # IF VSELECT = 2 (X AXIS),
                EXTEND                                  # BYPASS UPDATE
                BZF             ENDVDAT

VUPDAT          CS              FLGWRD11
                MASK            LRINHBIT
                CCS             A
                TCF             VALTCHK                 # UPDATE INHIBITED

                TS              MPAC            +1      # ZERO MPAC +1 FOR MULTIPLY LATER
                CS              ABVEL
                AD              LRVMAX                  # VMAX - V
                EXTEND
                BZMF            VALTCHK                 # IF V > VMAX BYPASS UPDATE
                EXTEND

## Page 889
                INDEX           VSELECT                 # WV(VMAX - V)
                MP              LRWVZ
                EXTEND
                DV              LRVMAX                  # WV(1 - V/VMAX)
                TS              MPAC                    # STORE IN MPAC, MODE IS DP FROM ABOVE

                TC              INTPRET
                DMP             VXSC                    # W(DELTA V)(VBEAMSM) UP 6-7, 0-5
                VSL1            VAD
                                V1S                     # ADD WEIGHTED DELTA V TO VELOCITY
                STORE           GNUV
                EXIT

                TC              QUIKFAZ5                # DO NOT RE-UPDATE

                CA              SIX
                TC              GNURVST                 # STORE NEW VELOCITY VECTOR

ENDVDAT         =               VALTCHK

VALTCHK         TC              QUIKFAZ5                # DO NOT REPEAT ABOVE

                CAF             READVBIT                # TEST READVEL TO SEE IF VELOCITY READING
                MASK            FLGWRD11                # IS DESIRED.
                CCS             A
                TCF             READV                   # TES - READ VELOCITY
                CS              ABVEL                   # NO - SEE IF VELOCITY < 2000 FT/SEC
                AD              2KFT/SEC
                EXTEND
                BZMF            CONTSERV                # V > 2000 FT/SEC   DO NOT READ VEL

                TC              UPFLAG                  # V < 2000 FT/SEC   SET READVEL AND READ
                ADRES           READVEL

                CAF             ZERO                    # INITIALIZE VSELECT
                TS              VSELECT

READV           CAF             PRIO32                  # SET UP JOB TO READ VELOCITY BEAMS.
                TC              NOVAC
                EBANK=          HMEAS
                2CADR           LRVJOB

                TCF             CONTSERV                # CONTINUE WITH SERVICER


GNURVST         TS              BUF                     # STORE GNUR (=GNUV) IN R1S OR V1S
                EXTEND                                  # A = 0 FOR R, A = 6 FOR V
                DCA             GNUR
                INDEX           BUF
                DXCH            R1S

## Page 890
                EXTEND
                DCA             GNUR            +2
                INDEX           BUF
                DXCH            R1S             +2
                EXTEND
                DCA             GNUR            +4
                INDEX           BUF
                DXCH            R1S             +4
                TC              Q


QUIKFAZ5        CA              EBANK3
                XCH             EBANK                   # SET EBANK 3
                DXCH            L                       # Q TO A, A TO L
                EBANK=          PHSNAME5
                TS              PHSNAME5
                LXCH            EBANK
                EBANK=          DVCNTR
                TC              A


HFAIL           CS              LRRCTR
                EXTEND
                BZF             NORLITE                 # IF R = 0, DO NOT TURN ON TRK FAIL
                AD              LRLCTR
                MASK            NEG3
                EXTEND                                  # IF L-R LT 4, DO NOT TURN ON TRK FAIL
                BZF             +2
                TCF             NORLITE

                TC              UPFLAG                  # AND SET BIT TO TURN ON TRACKER FAIL LITE
                ADRES           HFLSHFLG

NORLITE         CA              LRLCTR
                TS              LRRCTR                  # SET R = L

                TCF             VMEASCHK


VFAIL           CS              LRSCTR                  #   DELTA Q LARGE
                EXTEND                                  # IF S = 0, DO NOT TURN ON TRACKER FAIL
                BZF             NOLITE
                AD              LRMCTR                  # M-S
                MASK            NEG3                    # TEST FOR M-S > 3
                EXTEND                                  # IF M-S > 3, THEN TWO OR MORE OF THE
                BZF             +2                      #   LAST FOUR V READINGS WERE BAD,
                TCF             NOLITE                  #   SO TURN ON VELOCITY FAIL LIGHT

                TC              UPFLAG                  # AND SET BIT TO TURN ON TRACKER FAIL LITE
                ADRES           VFLSHFLG

## Page 891
NOLITE          CA              LRMCTR                  # SET S = M
                TS              LRSCTR

                CCS             VSELECT                 # TEST FOR Z COMPONENT
                TCF             ENDVDAT                 # NOT Z, DO NOT SET VX INHIBIT

                TC              UPFLAG                  # Z COMPONENT - SET FLAG TO SKIP X
                ADRES           VXINH                   # COMPONENT,AS ERROR MAY BE DUE TO CROSS
                TCF             ENDVDAT                 # LOBE LOCK UP NOT DETECTED ON X AXIS.

## Page 892
# ********************************************************************************************************
#    LRVJOB IS SET WHEN THE LEM IS BELOW 15000 FT DURING THE LANDING PHASE
#    THIS JOB INITIALIZES THE LANDING RADAR READ ROUTINE FOR 5 VELOCITY
#    SAMPLES AND GOES TO SLEEP WHILE THE SAMPLING IS DONE-ABOUT 500 MS.
#    WITH A GOODEND RETURN THE DATA IS STORED IN VMEAS AND BIT7 OF LRSTAT
#    IS SET.  THE GIMBAL ANGLES ARE READ ABOUT MIDWAY IN THE SAMPLING .

170MS           EQUALS          ND1


LRVJOB          CA              170MS                   # SET TASK TO READ CDUS + PIPAS
                TC              WAITLIST
                EBANK=          LRVTIME
                2CADR           RDGIMS

                CCS             VSELECT                 # SEQUENCE LR VEL BEAM SELECTOR
                TCF             +2
                CAF             TWO                     # IF ZERO-RESET TO TWO
                DOUBLE                                  # 2XVSELECT USED FOR VBEAM INDEX IN LRVEL
                TC              BANKCALL                # GO INITIALIZE LR VEL READ ROUTINE
                CADR            LRVEL
                TC              BANKCALL                # PUT LRVJOB TO SLEEP ABOUT 500 MS
                CADR            RADSTALL
                TCF             VBAD
                CCS             STILBADV                # IS DATA GOOD JUST PRESENT?
                TCF             VSTILBAD                # JUST GOOD - MUST WAIT 4 SECONDS.

                INHINT
                EXTEND                                  # GOOD RETURN-STOW AWAY VMEAS
                DCA             SAMPLSUM
                DXCH            VMEAS
                CA              EBANK4                  # FOR DOWNLINK
                TS              EBANK
                EBANK=          LRVTIME

                EXTEND
                DCA             LRVTIME
                DXCH            LRVTIMDL
                EXTEND
                DCA             LRXCDU
                DXCH            LRXCDUDL
                CA              LRZCDU
                TS              LRZCDUDL
                CA              EBANK7
                TS              EBANK
                EBANK=          VSELECT

                CS              FLGWRD11                # SET BIT TO INDICATE VELOCITY
                MASK            VELDABIT                # MEASUREMENT MADE.

## Page 893
                ADS             FLGWRD11
ENDLRV          CCS             VSELECT                 # UPDATE VSELECT
                TCF             +2
                CA              TWO
                TS              VSELECT
                TCF             ENDOFJOB

VBAD            CAF             TWO                     # SET STILBAD TO WAIT 4 SECONDS
VSTILBAD        TS              STILBADV
                TCF             ENDLRV

# LRHJOB IS SET BY LRHTASK WHEN LEM IS BELOW 25000 FT.  THIS JOB
# INITIALIZES THE LR READ ROUTINE FOR AN ALT MEASUREMENT AND GOES TO
# SLEEP WHILE THE SAMPLING IS DONE-ABOUT 95 MS.  WITH A GOODEND RETURN
# THE ALT DATA IS STORED IN HMEAS AND BIT7 OF LRSTAT IS SET.

                BANK            34
                SETLOC          R12STUFF
                BANK

                COUNT*          $$/SERV

LRHJOB          TC              BANKCALL                # INITIATE LR ALT MEASUREMENT
                CADR            LRALT
                TC              BANKCALL                # LRHJOB TO SLEEP ABOUT 95MS
                CADR            RADSTALL
                TCF             HBAD
                CCS             STILBADH                # IS DATA GOOD JUST PRESENT?
                TCF             HSTILBAD                # JUST GOOD - MUST WAIT 4 SECONDS.

                INHINT
                EXTEND
                DCA             SAMPLSUM                # GOOD RETURN-STORE AWAY LRH DATA
                DXCH            HMEAS                   # LRH DATA 1.079 FT/BIT
                EXTEND                                  # FOR DOWNLINK
                DCA             PIPTIME1
                DXCH            MKTIME

                EXTEND
                DCA             CDUTEMPY                # CDUY,Z = AIG,AMG
                DXCH            AIG

                CA              CDUTEMPX                # CDUX = AOG
                TS              AOG

                CS              FLGWRD11                # SET BIT TO INDICATE RANGE
                MASK            RNGEDBIT                # MEASUREMENT MADE.
                ADS             FLGWRD11
ENDLRH          TC              ENDOFJOB                # TERMINATE LRHJOB

## Page 894
HBAD            CA              FLAGWRD5
                MASK            RNGSCBIT                # IS BAD RETURN DUE TO SCALE CHANGE?
                EXTEND
                BZF             HSTILBAD        -1      # NO    RESET HSTILBAD
                TC              DOWNFLAG                # YES   RESET SCALE CHANGE BIT AND IGNORE
                ADRES           RNGSCFLG
                TC              ENDOFJOB


                CAF             TWO                     # SET STILBAD TO WAIT 4 SECONDS
HSTILBAD        TS              STILBADH
                TC              ENDOFJOB

                BANK            32
                SETLOC          SERV2
                BANK

                COUNT*          $$/SERV

#     RDGIMS  IS A TASK SET UP BY LRVJOB TO PICK UP THE IMU CDUS AND TIME
#     AT ABOUT THE MIDPOINT OF THE LR VEL READ ROUTINE WHEN 5 VEL SAMPLES
#     ARE SPECIFIED.

                EBANK=          LRVTIME
RDGIMS          EXTEND
                DCA             TIME2                   # PICK UP TIME2,TIME1
                DXCH            LRVTIME                 #    AND SAVE IN LRVTIME

                EXTEND
                DCA             CDUX                    # PICK UP CDUX AND CDUY
                DXCH            LRXCDU                  #    AND SAVE IN LRXCDU AND LRYCDU

                CA              CDUZ
                TS              LRZCDU                  # SAVE CDUZ IN LRZCDU

                CA              PIPAX
                TS              PIPTEM                  # SAVE PIPAX IN PIPTEM

                EXTEND
                DCA             PIPAY                   # PICK UP PIPAY AND PIPAZ
                DXCH            PIPTEM          +1      #    AND SAVE IN PIPTEM +1 AND PIPTEM +2
                TC              TASKOVER

                BANK            33
                SETLOC          SERVICES
                BANK

                COUNT*          $$/SERV

                EBANK=          DVCNTR

## Page 895
#    HIGATJOB IS SET APPROXIMATELY 6 SECONDS PRIOR TO HIGH GATE DURING
#    THE DESCENT BURN PHASE OF LUNAR LANDING.  THIS JOB INITIATES THE
#    LANDING RADAR REPOSITIONING ROUTINE AND GOES TO SLEEP UNTIL THE
#    LR ANTENNA MOVES FROM POSITION 1 TO POSITION 2.  IF THE LR ANTENNA
#    ACHIEVES POSITION 2 WITHIN 22 SECONDS THE ALTITUDE AND VELOCITY
#    BEAM VECTORS  ARE RECOMPUTED TO REFLECT THE NEW ORIENTATION WITH
#    RESPECT TO THE NB.  BIT10 OF LRSTAT IS CLEARED TO ALLOW LR
#    MEASUREMENTS AND THE JOB TERMINATES.

HIGATJOB        TC              BANKCALL                # START LRPOS2 JOB
                CADR            LRPOS2
                TC              BANKCALL                # PUT HIGATJOB TO SLEEP UNTIL JOB IS DONE
                CADR            RADSTALL
                TCF             POSALARM                # BAD END   ALARM

POSGOOD         CA              PRIO24                  # REDUCE PRIORITY FOR INTERPRETIVE STUFF
                TC              PRIOCHNG

                TC              SETPOS2                 # LR IN POS2 - SET UP TRANSFORMATIONS

                TC              DOWNFLAG
                ADRES           NOLRREAD                # RESET NOLRREAD FLAG TO ENABLE LR READING
                TC              ENDOFJOB

POSALARM        CA              OCT523
                TC              BANKCALL
                CADR            PRIOLARM                # FLASH ALARM CODE
                TCF             GOTOPOOH                # TERMINATE
                TCF             +3                      # PROCEED - TRY AGAIN
                TCF             ENDOFJOB                # V 32 E    TERMINATE R12
                TC              ENDOFJOB

 +3             CA              BIT7                    # SEE IF IN POS2 YET
                EXTEND
                RAND            CHAN33
                EXTEND
                BZF             POSGOOD                 # POS2 ACHIEVED   SET UP ANTENNA BEAMS
                TCF             POSALARM                # STILL DIDN'T MAKE IT   REALARM

OCT523          OCT             00523


SETPOS1         TC              MAKECADR                # MUST BE CALLED BY BANKCALL
                TS              LRADRET1                # SAVE RETURN CADR, SINCE BUF2 CLOBBERED

                CAF             TWO
                TS              STILBADH                # INITIALIZE STILBAD
                TS              STILBADV                # INITIALIZE STILBAD

                CA              ZERO                    # INDEX FOR LRALPHA,LRBETA IN POS 1.

## Page 896
                TS              LRLCTR                  # SET L,M,R, ANS S TO ZERO
                TS              LRMCTR
                TS              LRRCTR
                TS              LRSCTR
                TC              SETPOS                  # CONTINUE WITH COMPUTATIONS

                CA              LRADRET1
                TC              BANKJUMP                # RETURN TO CALLER


SETPOS2         CA              TWO                     # INDEX FOR POS2
SETPOS          EXTEND
                INDEX           A
                DCA             LRALPHA                 # LRALPHA IN A, LRBETA IN L
                TS              CDUSPOT         +4      # ROTATION ABOUT X
                LXCH            CDUSPOT                 # ROTATION ABOUT Y
                CA              ZERO
                TS              CDUSPOT         +2      # ZERO ROTATION ABOUT Z.

                EXTEND
                QXCH            LRADRET                 # SAVE RETURN

                TC              INTPRET
                VLOAD           CALL
                                UNITY                   # CONVERT UNITY(ANTENNA) TO NB
                                TRG*SMNB
                STOVL           VYBEAMNB
                                UNITX                   # CONVERT UNITX(ANTENNA) TO NB
                CALL
                                *SMNB*
                STORE           VXBEAMNB
                VXV             VSL1
                                VYBEAMNB
                STOVL           VZBEAMNB                # Z = X * Y
                                HBEAMANT
                CALL
                                *SMNB*                  # CONVERT TO NB
                STORE           HBEAMNB
                EXIT
                TC              LRADRET
