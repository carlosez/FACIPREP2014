DECLARE
   CURSOR C1
   IS
        SELECT A.EXECUTABLE_NAME,
               C.CONCURRENT_PROGRAM_NAME,
               C.DESCRIPTION,
               B.APPLICATION_SHORT_NAME
          FROM FND_EXECUTABLES_FORM_V A,
               FND_APPLICATION_VL B,
               FND_CONCURRENT_PROGRAMS_VL C
         WHERE    C.EXECUTABLE_ID = A.EXECUTABLE_ID
               AND B.APPLICATION_ID = C.APPLICATION_ID
               AND A.EXECUTABLE_NAME IN ('XXSVFAREPCIPADDTXT','XX_FA_SV_FIXED ASSET REPORT')
      ORDER BY 1;

   CURSOR C2
   IS
        SELECT A.EXECUTABLE_NAME, B.APPLICATION_SHORT_NAME
          FROM FND_EXECUTABLES_FORM_V A, FND_APPLICATION_VL B
         WHERE B.APPLICATION_ID = A.APPLICATION_ID
               AND A.EXECUTABLE_NAME IN ('XXSVFAREPCIPADDTXT','XX_FA_SV_FIXED ASSET REPORT')
      ORDER BY 1;
BEGIN
   -- Suprimiendo Program o Concurrente
   FOR i IN C1
   LOOP
      BEGIN
         FND_PROGRAM.
         delete_program (program_short_name => i.CONCURRENT_PROGRAM_NAME,
                         application => i.APPLICATION_SHORT_NAME);
      END;
   END LOOP;

   COMMIT;

   -- Suprimiendo Ejecutables
   FOR j IN C2
   LOOP
      BEGIN
         FND_PROGRAM.
         delete_executable (executable_short_name => j.EXECUTABLE_NAME,
                            application => j.APPLICATION_SHORT_NAME);
      END;
   END LOOP;

   COMMIT;
END;
/