     **Free

        //** ************************************************************** **
        //** **  Presented By : Ettaki El Mehdi                             **
        //** **  Session      : Procedure for Manager Dashboard             **
        //** **  Date Release : 26-09-2023
        //** ************************************************************** **
        //** ************************************************************** **
        //** *   Manager Dashboard            : TS03                        **
        //** ************************************************************** **

        // ** File Declaration **
           Dcl-F LEVMNGSYSD Workstn INDDS(PGMIND) ;
           Dcl-F EMPLEVDTL Disk Usage(*Input:*Output:*Update) Keyed ;

        // ** Data Structure Declaration **

           DCL-DS PGMIND;
             Exit   Char(1) Pos(03);
             CANCEL Char(1) Pos(12);
             FROMDATERIPC Char(1) Pos(90);
             TODATERIPC Char(1) Pos(91);
             UPDATEIND Char(1) Pos(06);
             LEVAVAIL Char(1) Pos(95);
             EARNEDLEV Char(1) Pos(96);
             CASUALLEV Char(1) Pos(97);
           END-DS;

        //** ************************************************************** **
        //** *   Procedure for Display Manager Screen                       **
        //** ************************************************************** **

           Dcl-Proc ShowMng Export ;
           Reset Exit ;
           Reset M1_ERRMSG ;
           Dow EXIT = *Off ;
               S1PROGNAME = 'MANAGERDSB' ;
               Exfmt MNG_DASHB          ;
               If CANCEL = *On          ;
                  Reset CANCEL          ;
                  Leave                 ;
               Endif                    ;
               Clear M1_ERRMSG          ;
               If UPDATEIND = *Off      ;
                  $LoadData()           ;
               Endif                    ;
               If UPDATEIND = *On       ;
                  $UpdateData()         ;
                  $LoadData()           ;
                  Reset UPDATEIND       ;
               Endif                    ;
           Enddo                        ;
             *Inlr = *On                ;
           End-Proc                     ;

        //** ************************************************************** **
        //** *  $LoadData : Procedure for Load Data into Manager Screen     **
        //** ************************************************************** **

           Dcl-Proc $LoadData   ;
              Chain(n) M1_EMPID  EMPLEVDTL ;
              If %Found(EMPLEVDTL)  ;

                 M1LEVAVAIL  =  E_LEVAVAIL  ;
                 M1_LEVEARN  =  E_ELBAL     ;
                 M1_LEVCASL  =  E_CLBAL     ;

              Else                          ;
                 Clear Mng_Dashb            ;
                 M1_ERRMSG = 'Invalid Employee Id' ;
              Endif                         ;

              *Inlr = *On                   ;
           End-Proc                         ;

        //** ************************************************************** **
        //** *  $UpDateData  : Procedure for Update Data From Manager       **
        //** ************************************************************** **

           Dcl-Proc $UpdateData  ;

              Setll M1_EMPID EMPLEVDTL    ;
              If %Found(EMPLEVDTL)        ;
                 Read EMPLEVDTLR         ;   //Correcting
                 E_LEVAVAIL = M1LEVAVAIL  ;
                 E_ELBAL    = M1_LEVEARN  ;
                 E_CLBAL    = M1_LEVCASL  ;

                 Select ;
                    When M1LEVAVAIL = *Zeros   ;
                      LEVAVAIL = *On           ;
                      M1_ERRMSG = 'Zone Must not be Blank!';
                      Reset LEVAVAIL;
                    When M1_LEVEARN = *Zeros ;
                      EARNEDLEV = *On     ;
                      M1_ERRMSG = 'Earned Leave Must not be Blank!';
                      Reset EARNEDLEV;
                    When M1_LEVCASL = *Zeros ;
                      CASUALLEV = *On;
                      M1_ERRMSG = 'Casual Leave Should not be Blank!';
                      Reset CASUALLEV ;
                    Other ;
                      Update EMPLEVDTLR        ;
                      Clear UPDATE_MSG ;
                      UPDATE_MSG = 'Your Submit is updated!' ;
                 Endsl;
              Else                        ;
                 Clear Mng_Dashb          ;
                 M1_ERRMSG = 'Invalid Employee Id' ;
              Endif                       ;

              *Inlr = *On                 ;
           End-Proc                        ;