     **Free
        //** ****************************************************************
        //** **  Presented By : Ettaki El Mehdi                             *
        //** **  Session      : Leave Management System                     *
        //** **  Date         : 24-09-2023                                  *
        //** ****************************************************************

        // *****************************************************************
        // *                      Log Informations                         *
        // *****************************************************************
        // *  Login Dashboard System :        TS01                         *
        // *  Employee Dashboard Processing : TS02                         *
        // *  Manager Dashboard Processing  : TS03                         *
        // *****************************************************************


        // ** Control Options    **

           Ctl-Opt Option(*nodebugio:*Srcstmt)  ;

        // ** Desplay File Declaration

           Dcl-F LEVMNGSYSD Workstn Indds(PGMIND) ;

        // ** Physical File Declaration **

           Dcl-F EmpLevDtl Disk Usage(*Input:*Output:*Update) Keyed ; //TS02

        // ** Variables Declaration      **                           //TS01

           Dcl-S W_UsrType     Char(1) ;                              //TS01
           Dcl-S W_S1USERNAME  Char(8) ;                              //TS01
           Dcl-S W_S1PASSWORD  Zoned(8) ;                             //TS01
           Dcl-S W_DateValidation  Char(1) ;                          //TS02
           Dcl-S W_NumberOfDays    Zoned(4) ;                         //TS02
           Dcl-S W_LeaveDate       Date  ;                            //TS02
           Dcl-S W_Date2           Date   ;                           //TS02
           Dcl-S W_LeaveDateNum    Zoned(8:0)  ;                      //TS02
           Dcl-S Day_Of_Week       Zoned(1) ;                         //TS02
           Dcl-S LeaveSkip         Zoned(1) ;                         //TS02

        // ** ProtoType Declaration  **                               //TS01

           Dcl-Pr CheckUsrType Char(1)  ;                             //TS01
              S1USERNAME  Char(8)      ;                              //TS01
              S1PASSWORD  Zoned(8)     ;                              //TS01
           End-Pr                      ;                              //TS01

           Dcl-Pr ShowMng              ;  //External Procedure        //TS03
           End-Pr                      ;                              //TS03

        // ** Data Structure Indicators Declaration  **               //TS01

           DCL-DS PGMIND ;                              //TS01
             EXIT Char(1) Pos(03) ;                                //TS01
             CANCEL Char(1) Pos(12) ;                              //TS01
             FROMDATERIPC Char(1) Pos(90) ;                        //TS02
             TODATERIPC Char(1) Pos(91) ;                          //TS02
             UPDATEIND Char(1) Pos(06) ;                           //TS02
             LEVAVAIL Char(1) Pos(95);
             EARNEDLEV Char(1) Pos(96);
             CASUALLEV Char(1) Pos(97);
           END-DS ;                                                //TS01

        // ** Main Logic   **                                         //TS01

           Dow EXIT = *Off  ;                                         //TS02
               S1PROGNAME = 'LEVMNGSYSR'  ;                           //TS02
               Exfmt LOGIN_PAGE           ;                           //TS02
               W_S1USERNAME = S1UserName  ;                           //TS01
               W_S1PASSWORD = S1PASSWORD  ;                           //TS01
               W_UsrType = CheckUsrType(W_S1USERNAME:W_S1PASSWORD) ;  //TS01
               Select  ;                                              //TS01

        // ** Employee Dashboard   **                                 //TS02

               When W_UsrType = 'E'   ;                               //TS01
                  Reset S1ERRMSG      ;                               //TS02
                  Reset FROMDATERIPC  ;                               //TS02
                  Reset TODATERIPC    ;                               //TS02

               Dow EXIT = *Off        ;
                 $LoadEmpData()       ;
                 S1PROGNAME = 'EMPDASHBRD' ;
                 Exfmt Emp_DASHB      ;
                 Reset E1ERRMSG       ;
                 If CANCEL = *On      ;
                    Reset CANCEL      ;
                    Leave             ;
                 Endif                ;
                 $ValidateDate()      ;
               Enddo                  ;

        //** Manager Dashboard **                                     //TS03
               When W_UsrType = 'M'   ;                               //TS01
                  ShowMng()           ;  //External Procedure         //TS03
               Other                  ;                               //TS01
                  S1ERRMSG = 'Invalid User' ;                         //TS01
               Endsl                  ;                               //TS01
            Enddo                     ;                               //TS01

            *Inlr = *On               ;

        //** ****************************************************************
        //** **                                                             *
        //** ** $LoadEmpData : Procedure To Load Employee Data       TS02   *
        //** **                                                             *
        //** ****************************************************************

            Dcl-Proc $LoadEmpData            ;                       //TS02
               CHAIN(n) S1USERNAME EmpLevDtl ;                       //TS02
               If %Found(EmpLevDtl)          ;                       //TS02
                  E1_EMPID   =  E_EMPID      ;                       //TS02
                  E1LEVAVAIL =  %Char(E_LEVAVAIL) ;                  //TS02
                  E1_LEVEARN =  %Char(E_ELBAL) ;                     //TS02
                  E1_LEVCASL =  %Char(E_CLBAL) ;                     //TS02
               Endif                         ;                       //TS02
            End-Proc                         ;                       //TS02

        //** ****************************************************************
        //** **                                                             *
        //** ** $ValidateDate: Procedure To Validate date range      TS02   *
        //** **                                                             *
        //** ****************************************************************

            Dcl-Proc $ValidateDate           ;                       //TS02
               Clear W_DateValidation        ;                       //TS02

               Test(de) *ISO FROM_DATE       ;                       //TS02
               If %Error()                   ;                       //TS02
                  W_DateValidation = 'F'     ;                       //TS02
               Endif                         ;                       //TS02

               Test(de) *ISO TO_DATE         ;                       //TS02
               If %Error();                                             //TS02
                  W_DateValidation = 'T'     ;                       //TS02
               Endif                         ;                       //TS02

               If FROM_DATE > TO_DATE and FROM_DATE <> *Zeros        //TS02
               and TO_DATE <> *Zeros  ;                              //TS02
                  W_DateValidation = 'I' ;                           //TS02
               Endif                     ;                           //TS02

               If E1SELLEV = *Zeros and  W_DateValidation = *Blanks ; //TS02
                  W_DateValidation = 'R' ;                            //TS02
               Endif                     ;                            //TS02

               Select                    ;                            //TS02
                  When W_DateValidation = 'F' ;                       //TS02
                    $ClearInds()         ;                            //TS02
                    E1ERRMSG = 'Invalid From Date' ;                  //TS02
                    FROMDATERIPC = *On ;                             //TS02
                    Clear FROM_DATE    ;                              //TS02
                  When W_DateValidation  = 'T' ;                      //TS02
                    $ClearInds()       ;                              //TS02
                    E1ERRMSG = 'Invalid To Date' ;                    //TS02
                    TODATERIPC = *On             ;                 //TS02
                    Clear TO_DATE      ;                              //TS02
                  When W_DateValidation = 'I' ;                       //TS02
                    $ClearInds()       ;                              //TS02
                    E1ERRMSG = 'Invalid Date Range' ;                 //TS02
                    Clear FROM_DATE ;                                 //TS02
                    Clear TO_DATE   ;                                 //TS02
                  When W_DateValidation = 'R' ;                       //TS02
                    $ClearInds()    ;                                 //TS02
                    E1ERRMSG = 'Please Select leave type'  ;          //TS02
                  Other             ;                                 //TS02
                    $ClearInds()    ;                                 //TS02

                    $CalculateLeaves() ;                              //TS02
                    Select ;                                          //TS02
                    //E1_EMPID = S1USERNAME ;
                      When E1SELLEV = 1 ;                             //TS02
                        Setll E1_EMPID EMPLEVDTL  ;                  //TS02
                        If %Found(EMPLEVDTL)      ;                   //TS02
                           Read EMPLEVDTLR  ;                  //Correction
                           W_NumberofDays = %Diff(%Date(TO_DATE)      //TS02
                           : %Date(FROM_DATE): *Days) + 1 ;
                           W_NumberofDays = W_NumberofDays - Leaveskip ; //TS02
                           E_ELBAL = E_ELBAL - W_NumberofDays ;       //TS02
                           E_LEVAVAIL = E_LEVAVAIL + W_NumberofDays ; //TS02
                           Update EMPLEVDTLR  ;                       //TS02
                           Clear Leaveskip    ;                       //TS02
                        Endif                 ;                       //TS02
                      When E1SELLEV = 2       ;                       //TS02
                        Setll E1_EMPID EMPLEVDTL  ;                   //TS02
                        If %Found(EMPLEVDTL)  ;                       //TS02
                           Read EMPLEVDTLR    ;                //Correction
                           W_NumberofDays = %Diff(%Date(TO_DATE)      //TS02
                           : %Date(FROM_DATE) : *Days) + 1 ;          //TS02
                           W_NumberofDays = W_NumberofDays - Leaveskip ; //TS02
                           E_CLBAL = E_CLBAL - W_NumberofDays ;       //TS02
                           E_LEVAVAIL = E_LEVAVAIL + W_NumberofDays ; //TS02
                           Update EMPLEVDTLR  ;                       //TS02
                           Clear Leaveskip    ;                       //TS02
                        Endif                 ;                       //TS02
                    Endsl                     ;                       //TS02
                    Clear Emp_Dashb           ;                       //TS02
               Endsl                          ;                       //TS02
            End-Proc                          ;                       //TS02


        //** ****************************************************************
        //** **                                                             *
        //** ** $ClearInds : Procedure To Clear Indiicators        //TS02   *
        //** **                                                             *
        //** ****************************************************************

            Dcl-Proc $ClearInds  ;                                      //TS02
               Reset FROMDATERIPC ;                                     //TS02
               Reset TODATERIPC   ;                                     //TS02
            End-Proc              ;                                     //TS02


        //** ****************************************************************
        //** **                                                             *
        //** ** $CalculateLeaves : Procedure To Calculate Leaves Days       *
        //** **                                                             *
        //** ****************************************************************

            Dcl-Proc $CalculateLeaves ;                                //TS02
               W_NumberOfDays = %Diff(%Date(TO_DATE)                   //TS02
               : %Date(FROM_DATE): *Days) + 1 ;                        //TS02
               W_LeaveDate = %Date(FROM_DATE:*ISO) ;                   //TS02
               LeaveSkip   = 0 ;

               Dow W_NumberOfDays <> 0     ;                           //TS02
                  W_LeaveDateNum = %Dec(W_LeaveDate) ;                 //TS02

                  Day_Of_Week = %Rem(%Diff(%date(W_LeaveDateNum:*ISO)  //TS02
                  :d'0001-01-01':*Days):7) + 1;     //Correction       //TS02
                  If Day_Of_Week = 6 or Day_Of_Week = 7 ;              //TS02
                     LeaveSkip = LeaveSkip + 1 ;                       //TS02
                  Endif                        ;                       //TS02
                  W_LeaveDate = W_LeaveDate + %Days(1) ;               //TS02
                  W_NumberofDays = W_NumberofDays - 1 ;                //TS02
               Enddo                            ;                      //TS02

            End-Proc                            ;                      //TS02