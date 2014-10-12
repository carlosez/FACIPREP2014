/* Formatted on 2014/06/13 18:43 (Formatter Plus v4.8.8) */
DECLARE
   CURSOR c1
   IS
      SELECT   c.concurrent_program_name, c.description,
               b.application_short_name
          FROM fnd_application_vl b, fnd_concurrent_programs_vl c
         WHERE b.application_id = c.application_id
           AND c.concurrent_program_name IN ('XXSVFACIPADD','XX_FA_SV_FIXED_ASSET_REP_XML')
      ORDER BY 1;
BEGIN
   -- Suprimiendo Program o Concurrente
   FOR i IN c1
   LOOP
      BEGIN
         fnd_program.delete_program
                            (program_short_name      => i.concurrent_program_name,
                             application             => i.application_short_name
                            );
      END;
   END LOOP;

   COMMIT;
END;
/