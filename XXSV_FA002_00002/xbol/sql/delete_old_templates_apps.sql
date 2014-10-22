DECLARE
   CURSOR C1
   IS
      SELECT 'XXSVCIPACTFI' DATA_TEMPLATE FROM DUAL
      UNION
      SELECT 'XXSVFAREPCIPADDTXT' FROM DUAL
      UNION
      SELECT 'XX_FA_SV_FIXED_ASSET_REP_XML' FROM DUAL
      UNION
      SELECT 'XX_FA_SV_FIXED_ASSET_REPORT' FROM DUAL;
BEGIN
   FOR x IN C1
   LOOP
      BEGIN
         XDO_DS_DEFINITIONS_PKG.
         DELETE_ROW (
                     X_APPLICATION_SHORT_NAME   => 'XBOL'
                    ,X_DATA_SOURCE_CODE         =>  x.DATA_TEMPLATE
                    );
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         XDO_TEMPLATES_PKG.
         DELETE_ROW (
                     X_APPLICATION_SHORT_NAME   => 'XBOL'
                    ,X_TEMPLATE_CODE            => x.DATA_TEMPLATE
                    );
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         DELETE FROM XDO.XDO_LOBS
          WHERE LOB_CODE = x.DATA_TEMPLATE;

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      COMMIT;
   END LOOP;
END;
/
exit
/