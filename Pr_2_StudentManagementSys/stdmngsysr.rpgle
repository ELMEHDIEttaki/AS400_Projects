     **Free

        // ************************************************************
        // ** Presented By : El Mehdi Ettaki                          *
        // ** Project      : Student Management System                *
        // ** Start Date   : 15-09-2023                               *
        // ************************************************************

        // ** Control Options  **

           Ctl-opt Option(*NoDebugio:*Srcstmt) ;

        // **Physical File Declaration  **

           Dcl-F LOGINPF   Disk Usage(*Input:*Update) Keyed ;
           Dcl-F STUDENTPF Disk Usage(*Input:*Update:*Delete:*Output) Keyed ;

        // ** Display File Declaration  **

           Dcl-F STDMNGSYSD Workstn Sfile(DSPSFL:RRN) ;

        // ** Variables Declaration  **

           Dcl-S ValidUser     Char(1)  Inz('N') ;
           Dcl-S User_Id       Zoned(4) Inz      ;
           Dcl-S RecordExist   Char(1)  Inz('N') ;
           Dcl-S RRN           Zoned(4) Inz      ;

           Dcl-S AutoId        Zoned(4) Inz      ;

           Dcl-S ValidData     Char(1)  Inz('N') ;

        // ** Main Logic **

           Dow *In03 = *Off                      ;

               S1PROGNAME = 'STDMNGSYS'          ;
               Reset *In12                       ;
               Reset ValidUser                   ;
               Exfmt LOGIN                       ;

        // ** Option F6 : Forgot Password Screen

               If *In06 = *On                    ;
                  Exsr $ResetInd                 ;
              //Clear Forgot Password Screen
                  Reset FORGETPWD                ;
                  S1PROGNAME = 'STDMNGSYS'      ;
                  Dow *In12 = *Off               ;
                      Reset RecordExist          ;
                      Exfmt FORGETPWD            ;
                      Exsr $ValidatePwd          ;
                      If ValidData = 'Y'         ;
                         Exsr $UpdateNewPwd      ;
                         Exsr $ResetInd          ;
                         Reset FORGETPWD         ;
                         S1PROGNAME = 'STDMNGSYS' ;
                         Reset ValidData         ;
                      Endif                      ;
                  Enddo                          ;
                          ValidUser = 'F'        ;
               Endif                             ;

               Clear S1ERRMSG                    ;

               Exsr $VerifyCred                  ;

               If ValidUser = 'Y'                ;

                  Exsr $ClrSubFile               ;
                  Exsr $LoadSubFile              ;
                  Exsr $DspSubFile               ;

               Elseif ValidUser = 'N'            ;
                   S1ERRMSG = 'Login Failed'     ;

               Endif                             ;
           Enddo                                 ;

           *Inlr = *On                           ;

        // **************************************************************
        // $ResetInd : Routine to Clear All Indicators                  *
        //***************************************************************

           Begsr $ResetInd                       ;
                 Reset *In70                     ;
                 Reset *In71                     ;
                 Reset *In72                     ;
                 Reset *In73                     ;
                 Reset *In74                     ;
                 Reset *In75                     ;
                 Reset *In76                     ;
                 Reset *In77                     ;
                 Reset *In86                     ;
                 Reset *In87                     ;
                 Reset *In88                     ;
                 Reset *In89                     ;
                 Reset *In90                     ;
                 Reset *In91                     ;
                 Reset *In92                     ;
                 Reset *In93                     ;
           Endsr                                 ;
        // **************************************************************
        // $ValidatePwd : Routine to Validate Password                  *
        // **************************************************************

           BegSr $ValidatePwd                   ;
                 Chain F1USERNAME LOGINPF       ;
                 If %Found(LOGINPF)             ;
                    RecordExist = 'Y'           ;
                 Endif                          ;

                 Select                         ;
                    When RecordExist = 'N'      ;
                        Exsr $ResetInd          ;
                        *In86 = *On             ;
                        F1ERRMSG = 'Invalid Username' ;

                    When KEYSECURTY <> 'KEY12356' ;
                        Exsr $ResetInd          ;
                        *In87 = *On             ;
                        F1ERRMSG = 'Invalid Security Key' ;

                    When  F1NEWPASSW = *Zeros   ;
                        Exsr $ResetInd          ;
                        *In88 = *On             ;
                        F1ERRMSG = 'Password Field can not be blank' ;

                    When F1CONFPASS = *Zeros    ;
                        Exsr $ResetInd          ;
                        *In89 = *On             ;
                        F1ERRMSG = 'Pwd Conf Field can not be blank' ;
                    When F1NEWPASSW <> F1CONFPASS ;
                        Exsr $ResetInd          ;
                        Clear F1NEWPASSW        ;
                        Clear F1CONFPASS        ;
                        F1ERRMSG = 'Password not Matched!' ;
                    Other                        ;
                         ValidData = 'Y'         ;
                 Endsl                           ;

           EndSr                                ;
        // **************************************************************
        // $UpdateNewPwd : Routine to New Updated Password              *
        // **************************************************************

           BegSr $UpdateNewPwd                  ;
              Chain F1USERNAME LOGINPF          ;
              PASSWORD = F1CONFPASS             ;
              Update LOGINPFr                   ;
           EndSr                                ;

        // **************************************************************
        // $VerifyCred : Routine to Verify Credential                   *
        // **************************************************************

           BegSr $VerifyCred                     ;

              Chain  S1USRNAME LOGINPF           ;
              If %Found(LOGINPF) and S1USRNAME = USERNAME
                 and S1PASSWORD = PASSWORD       ;

                     ValidUser = 'Y'             ;
              Elseif not %Found(LOGINPF) and ValidUser <> 'F' ;

                     ValidUser = 'N'             ;
              Endif                              ;
           Endsr                                 ;

        // **************************************************************
        // $ClrSubFile : Routine to Clear SubFile                       *
        // **************************************************************

           BegSr $ClrSubFile                     ;

              RRN = 0                            ;
              *In91 = *On                        ;
              Write DSPSFLCTL                    ;
              *In91 = *Off                       ;
           Endsr                                 ;

        // **************************************************************
        // $LoadSubFile : Routine to Load SubFile                       *
        // **************************************************************

           BegSr $LoadSubFile                     ;

              Setll *Loval STUDENTPF             ;

              Read STUDENTPF                     ;

              Dow Not %EOF(STUDENTPF)            ;
                  Clear SFL_OPTION               ;
                  RRN = RRN + 1                  ;

                  SFLSTD_ID = STUID              ;
                  SFLSTDNAME = STUNAME           ;
                  SFLSTDMAIL = STUMAIL           ;

                  If RRN > 9999                  ;
                     Leave                       ;
                  Endif                          ;

                  Write DSPSFL                   ;
                  Read STUDENTPF                 ;

                  If %EOF(STUDENTPF)             ;
                     *In90 = *On                 ;
                  Else                           ;
                     *In90 = *Off                ;
                  Endif                          ;
              Enddo                              ;
           Endsr                                 ;

        // **************************************************************
        // $DspSubFile : Routine to Display SubFile                     *
        // **************************************************************

           BegSr $DspSubFile                    ;

              *In92 = *On                       ;
              *In93 = *On                       ;

              If RRN = 0                        ;
                 *In92 = *Off                   ;
              Endif                             ;

              Dow *In03 = *Off                  ;
                  Reset *In05                   ;
                  Reset *In06                   ;
                  S1PROGNAME = 'STDMNGSYS'      ;
                  Write FOOTER                  ;
                  Exfmt DSPSFLCTL               ;

        // ** Refresh Option Screen : Logic for F5 option **
                  If *In05 = *On                ;
                     Reset SFL_OPTION           ;
                     Readc DSPSFL               ;
                     Dow Not %Eof               ;
                        Update DSPSFL           ;
                        Readc DSPSFL            ;
                     Enddo                      ;
                  Endif                         ;

        // ** Add Records option Screen : Logic for F6 option **

                  If *In06 = *On                ;
                  //When *In06 = *On              ;
                     Exsr $ResetInd             ;
                     Exsr $GenAutoId            ;
                     Reset  R1ERRMSG            ;
                     S1PROGNAME = 'STDMNGSYS'   ;
                     Dow *In03 = *Off           ;
                      // Reset *In12            ;
                         Reset *In05            ;
                         Exfmt ADDDATA          ;
                         If *In12 = *On         ;
                          //Exsr $ResetInd      ;
                          //Leave               ;
                            Exfmt DSPSFLCTL     ;
                         Endif                  ;

        // ** Refresh Screen for Add Student Screen : Logic for F5 Option

                       //If *In05 = *On         ;
                       //   Readc DSPSFL        ;
                       //   Reset SFL_OPTION    ;
                       //   Update DSPSFL       ;
                       //Endif                  ;

        // ** Write Records  : Logic for F6 Option

                      // If *In06 = *On          ;
                      //    Exsr $ResetInd       ;
                      //    Exsr $GenAutoId      ;
                      //    S1PROGNAME = 'STDMNGSYS' ;
                      //    Dow *In03 = *Off     ;
                      //        Reset *In12      ;
                      //        Reset *In05      ;
                      //        S1PROGNAME = 'STDMNGSYS' ;
                      //        Exfmt ADDDATA   ;
                      //        If *In12 = *On  ;
                      //           Leave        ;
                      //        Endif           ;

        // **Refresh records for F5 Option : Logic to Refresh Records on ADDDATA Screen

                           If *In05 = *On  ;
                              Exsr $ResetScnFlds ;
                              Exsr $ResetInd ;
                              Clear R1ERRMSG ;
                           Endif             ;

                           If *In05 = *Off   ;
                              Exsr $AddData  ;
                           Endif             ;

                          //Enddo                 ;
                       //Endif                    ;
                     Enddo                        ;

                  Endif                           ;
                //Endsl                           ;

                  Readc DSPSFL                    ;

                  Dow Not %EOF(STDMNGSYSD)       ;

       // ** Display Records : Logic for option 05 on DSPSFL Screen

                    Select                        ;
                       When SFL_OPTION = '05' or SFL_OPTION = '5' ;
                          Exsr $LoadDisplayData     ;
                          Dow *In03 = *Off          ;
                              S1PROGNAME = 'STDMNGSYS' ;
                              Exfmt DSPLAYDATA      ;
                              If *In12 = *On        ;
                                 Leave              ;
                              Endif                 ;
                          Enddo                     ;

       // ** Delete Records : Logic for option 04 On DSPSFL Screen
                       When SFL_OPTION = '04' or SFL_OPTION = '4' ;

                            Reset *In12             ;
                            Reset R1ERRMSG          ;

                            Dow *In03 = *Off        ;

                              D1DLTSTDID = %Char(STUID) ;
                              Exfmt DELETEDATA      ;

                              Select                ;
                                 When *In12 = *On   ;
                                      Leave         ;
                                 When D1DLTCONF = 'Y' or D1DLTCONF = 'y' ;
                                      Exsr $DeleteData ;
                                      Leave           ;

                                 When D1DLTCONF = 'N' or D1DLTCONF = 'n' ;
                                    D1MESSAGE='Press F12 for the prvious scren';

                                  When D1DLTCONF = *Blanks ;
                                    D1MESSAGE='Field should not be blank';

                                  Other            ;
                                    D1MESSAGE = 'Invalid Option';
                              Endsl               ;
                            Enddo ;

       // ** Edit Record : Logic for option 02 On DSPSFL Screen

                       When SFL_OPTION = '02' or SFL_OPTION = '2' ;

                          Reset *In12             ;
                          Reset UPT_ERRMSG        ;
                          Dow *In03 = *Off        ;
                            //Exsr $LoadDisplayData ;
                              E1STUDENID = SFLSTD_ID   ;
                              Chain E1STUDENID STUDENTPF ;
                                 E1STUDENID   =  SFLSTD_ID ;
                                 E1STDNAME    =  STUNAME  ;
                                 E1STDGENDR   =  STUGEN   ;
                                 E1STDEMAIL   =  STUMAIL  ;
                                 E1STDMOBIL   =  %Char(STUMOB)  ;
                                 E1STDSTREM   =  STUSTR   ;
                                 E1STDCDPIN   =  %Char(PINCODE)  ;
                                 E1STDCITY    =  CITY     ;
                                 E1STDCOUTR   =  COUNTRY  ;
                              S1PROGNAME = 'STDMNGSYS' ;
                              Exfmt UPDDATA       ;
                              If *In12 = *On      ;
                                 Leave            ;
                              Endif               ;
                              Exsr $UpdateData    ;
                              UPT_ERRMSG = 'Record Updated!' ;
                          Enddo                   ;

                    Endsl                         ;

                    Readc DSPSFL                  ;
                  Enddo                           ; //End of Read STDMNGSYSD FILE

                  Exsr  $ClrSubFile               ; // Clear SubFile Data

                  Exsr $LoadSubFile               ;

              Enddo                               ;
           Endsr                                  ; //End Subroutine $DSPSubFile


        // **************************************************************
        // $GenAutoId : Routine to Generate Id Users                    *
        // **************************************************************

           BegSr $GenAutoId                       ;
              Chain *Hival STUDENTPF              ;
                 AutoId      = STUID + 1          ;
                 R1STUDENID  = AutoId             ;
           Endsr                                  ;

        // **************************************************************
        // $ResetScnFlds : Routine to Refresh Fields on ADDDATA Screen  *
        // **************************************************************

           BegSr $ResetScnFlds                     ;
                 Reset R1STUDNAME                  ;
                 Reset R1STUDENID                  ;
                 Reset R1STUDGENR                  ;
                 Reset R1STDEMAIL                  ;
                 Reset R1STDMOBIL                  ;
                 Reset R1STDSTREM                  ;
                 Reset R1PINCODE                   ;
                 Reset R1STDCITY                   ;
                 Reset R1COUNTRY                   ;
           Endsr                                   ;

        // **************************************************************
        // $AddData : Routine to ADD DATA ON ADDDATA Screen  *
        // **************************************************************

           BegSr $AddData                          ;

              STUID     =  R1STUDENID              ;
              STUNAME   =  R1STUDNAME              ;
              STUGEN    =  R1STUDGENR              ;
              STUMAIL   =  R1STDEMAIL              ;
              STUMOB    =  R1STDMOBIL              ;
              STUSTR    =  R1STDSTREM              ;
              PINCODE   =  R1PINCODE               ;
              CITY      =  R1STDCITY               ;
              COUNTRY   =  R1COUNTRY               ;

              Exsr $ValidateData                   ;
              If ValidData = 'Y'                   ;
                 Write STUDENTPFR                  ;
                 Exsr $GenAutoId                   ;
                 Exsr $ResetScnFlds                ;
                 Reset ValidData                   ;
              Endif                                ;
           Endsr                                   ;

        //******************************************************************
        //$ValidateData : Routine to Validate Data added by ADDDATA Screen*
        //******************************************************************

           BegSr $ValidateData                     ;
              Select                               ;
                  When R1STUDNAME = *Blanks        ;
                     *In70 = *On                   ;
                     R1ERRMSG = 'Student Name can not be Blank' ;
                  When R1STUDGENR = *Blanks        ;
                     Exsr $ResetInd                ;
                     *In71 = *On                   ;
                     R1ERRMSG = 'Gender Field can not be Blank' ;
                  When R1STDEMAIL = *Blanks        ;
                     Exsr $ResetInd                ;
                     *In72 = *On                   ;
                     R1ERRMSG = 'Mail Field can not be Blank' ;
                  When R1STDMOBIL = *Zeros         ;
                     Exsr $ResetInd                ;
                     *In73 = *On                   ;
                     R1ERRMSG = 'Mobile Field can not be blank' ;
                  When R1STDSTREM = *Blanks        ;
                     Exsr $ResetInd                ;
                     *In74 = *On                   ;
                     R1ERRMSG = 'Stream Field can not be blank' ;
                  When R1PINCODE = *Zeros ;
                     Exsr $ResetInd                ;
                     *In75 = *On                   ;
                     R1ERRMSG = 'Pin Code can not be blank' ;
                  When R1STDCITY  = *Blanks        ;
                     Exsr $ResetInd                ;
                     *In76 = *On                   ;
                     R1ERRMSG = 'City Field can not be blank' ;
                  When R1COUNTRY = *Blanks         ;
                     Exsr $ResetInd                ;
                     *In77 = *On                   ;
                     R1ERRMSG = 'Country Field can not be blank' ;
                  Other                            ;
                      Exsr $ResetInd               ;
                      ValidData = 'Y'              ;
                      Clear R1ERRMSG               ;
              Endsl                                ;
           Endsr                                   ;

        // *********************************************************************
        // $LoadDisplayData / Routine to Display Data                         *
        // *********************************************************************

           BegSr $LoadDisplayData                  ;
              User_Id = SFLSTD_ID                  ;
              Chain User_Id STUDENTPF              ;
            //If %Found(STUDENTPF)                 ;
            //Chain  STUID  STUDENTPF              ;
                 DSP1STDID  = User_Id              ;
                 DSPSTDNAME = STUNAME              ;
                 DSPSTDGEND = STUGEN               ;
                 DSPSTDMAIL = STUMAIL              ;
                 DSPSTDMOBI = %Char(STUMOB)        ;
                 DSPSTDSTRM = STUSTR               ;
                 DS_PINCODE = %Char(PINCODE)       ;
                 DSPSTDCITY = CITY                 ;
                 DSPCOUNTRY = COUNTRY              ;
            //Endif                                ;
           Endsr                                   ;

        // *********************************************************************
        // $DeleteData / Routine to Delete Students Data                       *
        // *********************************************************************

           BegSr $DeleteData                      ;

              Chain SFLSTD_ID STUDENTPF           ;
              If %Found(STUDENTPF)                ;
                 Delete STUDENTPFr                ;
              Endif                               ;
           EndSr                                  ;

        // *********************************************************************
        // $UpdateData / Routine to Update Students Data                       *
        // *********************************************************************

           BegSr $UpdateData                      ;

            //E1STUDENID = SFLSTD_ID              ;
              Chain E1STUDENID STUDENTPF          ;
                STUID    =  E1STUDENID            ;
                STUNAME  =  E1STDNAME             ;
                STUGEN   =  E1STDGENDR            ;
                STUMAIL  =  E1STDEMAIL            ;
                STUMOB   =  %Dec(E1STDMOBIL:10:0) ;
                STUSTR   =  E1STDSTREM            ;
                PINCODE  =  %Dec(E1STDCDPIN:4:0)  ;
                CITY     =  E1STDCITY             ;
                COUNTRY  =  E1STDCOUTR            ;
              Update Studentpfr                   ;
           Endsr                                  ;