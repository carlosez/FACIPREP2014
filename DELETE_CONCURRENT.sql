/* Formatted on 10/9/2014 9:41:46 AM (QP5 v5.139.911.3011) */
DECLARE
   CURSOR XC1
   IS
      SELECT C.CONCURRENT_PROGRAM_NAME
            ,C.DESCRIPTION
            ,B.APPLICATION_SHORT_NAME
        FROM FND_APPLICATION_VL B, FND_CONCURRENT_PROGRAMS_VL C
       WHERE B.APPLICATION_ID = C.APPLICATION_ID
         AND C.CONCURRENT_PROGRAM_NAME IN
                ('XX_FA_SV_FIXED_ASSET_REP_XML', 'XXSVFACIPADD')
      ORDER BY 1;


   CURSOR C1
   IS
      SELECT A.EXECUTABLE_NAME
            ,C.CONCURRENT_PROGRAM_NAME
            ,C.DESCRIPTION
            ,B.APPLICATION_SHORT_NAME
        FROM FND_EXECUTABLES_FORM_V A
            ,FND_APPLICATION_VL B
            ,FND_CONCURRENT_PROGRAMS_VL C
       WHERE C.EXECUTABLE_ID = A.EXECUTABLE_ID
         AND B.APPLICATION_ID = C.APPLICATION_ID
         AND A.EXECUTABLE_NAME IN
                ('XX_FA_SV_FIXED ASSET REPORT', 'XXSVFAREPCIPADDTXT')
      ORDER BY 1;



   CURSOR C2
   IS
      SELECT A.EXECUTABLE_NAME, B.APPLICATION_SHORT_NAME
        FROM FND_EXECUTABLES_FORM_V A, FND_APPLICATION_VL B
       WHERE B.APPLICATION_ID = A.APPLICATION_ID
         AND A.EXECUTABLE_NAME IN
                ('XXSVFAREPCIPADDTXT', 'XX_FA_SV_FIXED ASSET REPORT')
      ORDER BY 1;
BEGIN
   --    begin
   --        drop         PACKAGE XXSV_FA_REPORTS;
   --
   --        REVOKE ALL ON BOLINF.XXSV_FA_REPORTS FROM APPS;
   --
   --        DROP PUBLIC SYNONYM XXSV_FA_REPORTS;
   --    end;

   FOR i IN XC1
   LOOP
      BEGIN
         FND_PROGRAM.
         delete_program (
                         program_short_name   => i.CONCURRENT_PROGRAM_NAME
                        ,application          => i.APPLICATION_SHORT_NAME
                        );
      END;
   END LOOP;


   FOR i IN C1
   LOOP
      BEGIN
         FND_PROGRAM.
         delete_program (
                         program_short_name   => i.CONCURRENT_PROGRAM_NAME
                        ,application          => i.APPLICATION_SHORT_NAME
                        );
      END;
   END LOOP;

   COMMIT;

   -- Suprimiendo Ejecutables
   FOR j IN C2
   LOOP
      BEGIN
         FND_PROGRAM.
         delete_executable (
            executable_short_name   => j.EXECUTABLE_NAME
           ,application             => j.APPLICATION_SHORT_NAME);
      END;
   END LOOP;
   commit;
END;