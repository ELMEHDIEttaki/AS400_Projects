     **Free

        // ******************************************************* **
        // **         Presented By : Ettaki El Mehdi               **
        // **         Task         : Procedure for login portal    **
        // **         Date Release : 25-09-2023                    **
        // ******************************************************* **


        // ** Procedure for deciding login portal **              //TS01

        Dcl-F LOGIN Disk Usage(*Input) Keyed ;                  //TS01

        Dcl-Proc CheckUsrType Export      ;                     //TS01

        // ** Procedure Interface **                              //TS01

           Dcl-Pi CheckUsrType Char(1) ;                          //TS01
              S1USERNAME Char(8)       ;                          //TS01
              S1PASSWORD Zoned(8)      ;                          //TS01
           End-Pi                      ;                          //TS01

        // ** Variables Declaration                               //TS01

           Dcl-S W_UsrType   Char(1)   ;                          //TS01

        // ** Main Logic     **                                   //TS01

           Chain S1USERNAME LOGIN  ;

           Select ;

           When %Found(LOGIN) and S1PASSWORD = PASSWORD            //TS01
           and USERTYPE = 'E' ;                                   //TS01
               W_UsrType = 'E' ;
                                                                  //TS01
           When %Found(LOGIN) and S1PASSWORD = PASSWORD           //TS01
           and USERTYPE = 'M' ;                                   //TS01
               W_UsrType = 'M' ;                                  //TS01

           Other  ;                                               //TS01
               W_UsrType = 'I' ;                                  //TS01
           Endsl               ;                                  //TS01

           Return W_UsrType    ;                                  //TS01
           *Inlr = *On         ;                                  //TS01
        End-Proc               ;                                  //TS01
