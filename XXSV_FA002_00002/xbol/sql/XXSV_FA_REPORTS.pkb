set define off;
CREATE OR REPLACE package body BOLINF.XXSV_FA_REPORTS  as

    procedure CIP_ADDITIONS( ECODE out varchar2 
                            ,ebuff out varchar2 
                            ,P_LEDGER_ID number
                            ,P_BOOK_TYPE_CODE  varchar2    --+ 'SV_TELEMOV_IFRS'
                            ,P_PERIOD     varchar2    --+ '05-13' no se ocupa
                            ,p_PROYECTO    varchar2    --+ 'SV9999-99998'
                            )is

cursor cip_data (P_BOOK_TYPE_CODE)is 
SELECT B.BOOK_TYPE_CODE company,
       a.asset_number ASSET_CODE,
       a.attribute1 lEGACY_CODE,
       a.description,
       (SELECT distinct CC.SEGMENT9
          FROM FA.FA_ASSET_INVOICES AI, GL.GL_CODE_COMBINATIONS CC
         WHERE AI.PAYABLES_CODE_COMBINATION_ID = CC.CODE_COMBINATION_ID
           AND AI.ASSET_ID = A.ASSET_ID
           AND AI.ASSET_INVOICE_ID in
               (SELECT MIN(ASSET_INVOICE_ID)
                  FROM FA.FA_ASSET_INVOICES AI2
                 WHERE AI2.ASSET_ID = A.ASSET_ID)) CAR,
       (SELECT FVT.DESCRIPTION
          FROM FND_FLEX_VALUES     FV,
               FND_FLEX_VALUE_SETS FVS,
               FND_FLEX_VALUES_TL  FVT
         WHERE FV.FLEX_VALUE_SET_ID = FVS.FLEX_VALUE_SET_ID
           AND FV.FLEX_VALUE_ID = FVT.FLEX_VALUE_ID
           AND FVS.FLEX_VALUE_SET_NAME = 'XX_GL_MIC_PROJECT_VS'
           AND FVT.LANGUAGE = 'US'
           AND FV.FLEX_vALUE in
               (SELECT CC.SEGMENT9
                  FROM FA.FA_ASSET_INVOICES AI, GL.GL_CODE_COMBINATIONS CC
                 WHERE AI.PAYABLES_CODE_COMBINATION_ID =
                       CC.CODE_COMBINATION_ID
                   AND AI.ASSET_ID = A.ASSET_ID
                   AND AI.ASSET_INVOICE_ID in
                       (SELECT MIN(ASSET_INVOICE_ID)
                          FROM FA.FA_ASSET_INVOICES AI2
                         WHERE AI2.ASSET_ID = A.ASSET_ID))) CAR_DESCRIPTION,
       a.manufacturer_name,
       a.model_number MANUFACTURER_NUMBER,
       a.serial_number,
       a.asset_type,
       a.attribute_category_code,
       (SELECT MAX (
                     CC1.SEGMENT1
                  || '.'
                  || CC1.SEGMENT2
                  || '.'
                  || CC1.SEGMENT3
                  || '.'
                  || CC1.SEGMENT4
                  || '.'
                  || CC1.SEGMENT5
                  || '.'
                  || CC1.SEGMENT6
                  || '.'
                  || CC1.SEGMENT7
                  || '.'
                  || CC1.SEGMENT8
                  || '.'
                  || CC1.SEGMENT9
                  || '.'
                  || CC1.SEGMENT10
                  || '.'
                  || CC1.SEGMENT11
                  || '.'
                  || CC1.SEGMENT12
                  || '.'
                  || CC1.SEGMENT13)
          FROM fa_asset_invoices ai, gl_code_combinations cc1
         WHERE ai.asset_id = a.asset_id
               AND ai.payables_code_combination_id = cc1.code_combination_id
               AND ai.invoice_transaction_id_in =
                      (SELECT MIN (invoice_transaction_id_in)
                         FROM fa_asset_invoices ai2
                        WHERE ai2.asset_id = a.asset_id))
          CLEARING_ACCOUNT,
        date_placed_in_service Fecha_puesta_servicio,
       B.life_in_months,
       B.cost,
        lc.segment1
       || '-'
       || lc.segment2
       || '-'
       || lc.segment3
       || '-'
       || lc.segment4
       || '-'
       || lc.segment5
       || '-'
       || lc.segment6
          LOCATION,
          (SELECT FT1.DESCRIPTION
          FROM FND_FLEX_VALUES FV1, FND_FLEX_VALUES_TL FT1
         WHERE     FV1.FLEX_VALUE_ID = FT1.FLEX_VALUE_ID
               AND FV1.PARENT_FLEX_VALUE_LOW = 'SV'
               AND ft1.language = 'ESA'
               AND FV1.FLEX_VALUE_SET_ID = 1014903
               AND FV1.FLEX_VALUE = LC.SEGMENT5)
          LOCATION_DESCRIPTION,
          (SELECT P.EMPLOYEE_NUMBER
          FROM fa_distribution_history dh, PER_ALL_PEOPLE_F P
         WHERE     dh.asset_id = b.asset_id
               AND DH.ASSIGNED_TO = P.PERSON_ID
               AND dh.book_type_code = :P_BOOK_TYPE_CODE    --b.book_type_code
               AND dh.transaction_header_id_out IS NULL
               AND ROWNUM = 1)
          EMPLOYEE_ORACLE_NUMBER,
          (SELECT P.FULL_NAME
          FROM fa_distribution_history dh, PER_ALL_PEOPLE_F P
         WHERE     dh.asset_id = b.asset_id
               AND DH.ASSIGNED_TO = P.PERSON_ID
               AND dh.book_type_code = :P_BOOK_TYPE_CODE    --b.book_type_code
               AND dh.transaction_header_id_out IS NULL
               AND ROWNUM = 1)
          ORACLE_EMPLOYEE,
          (SELECT P.ATTRIBUTE1
          FROM fa_distribution_history dh, PER_ALL_PEOPLE_F P
         WHERE     dh.asset_id = b.asset_id
               AND DH.ASSIGNED_TO = P.PERSON_ID
               AND dh.book_type_code = :P_BOOK_TYPE_CODE    --b.book_type_code
               AND dh.transaction_header_id_out IS NULL
               AND ROWNUM = 1)
          LEGACY_EMPLOYEE_NUMBER,
       --AK.SEGMENT1 || '-' || AK.SEGMENT2 PROYECTO_FA,
--       CT.SEGMENT1 || '-' || CT.SEGMENT2 FA_CATEGORY,
       (SELECT MAX(PO_NUMBER)
          FROM FA.FA_MASS_ADDITIONS MA
         WHERE MA.ASSET_NUMBER = A.ASSET_NUMBER) PO_NUMBER,
         (SELECT MIN (invoice_number)
          FROM fa_asset_invoices ai
         WHERE ai.asset_id = a.asset_id
               AND ai.invoice_transaction_id_in =
                      (SELECT MIN (invoice_transaction_id_in)
                         FROM fa_asset_invoices ai2
                        WHERE ai2.asset_id = a.asset_id))
          INVOICE,
          (SELECT MIN (asu.vendor_name)
          FROM fa_asset_invoices ai, ap_suppliers asu
         WHERE ai.asset_id = a.asset_id
               AND ai.invoice_transaction_id_in =
                      (SELECT MIN (invoice_transaction_id_in)
                         FROM fa_asset_invoices ai2
                        WHERE ai2.asset_id = a.asset_id)
               AND ai.po_vendor_id = asu.vendor_id)
          SUPPLIER,
           ak.segment1 || '-' || ak.segment2 PROYECTO_ACTIVO,
           (SELECT FT1.DESCRIPTION || '-' || FT2.DESCRIPTION
          FROM FND_FLEX_VALUES FV1,
               FND_FLEX_VALUES_TL FT1,
               FND_FLEX_VALUES FV2,
               FND_FLEX_VALUES_TL FT2
         WHERE     FV1.FLEX_VALUE_ID = FT1.FLEX_VALUE_ID
               AND FV2.FLEX_VALUE_ID = FT2.FLEX_VALUE_ID
               AND FV2.PARENT_FLEX_VALUE_LOW = FV1.FLEX_VALUE
               AND FV1.FLEX_VALUE || '-' || FV2.FLEX_VALUE =
                      ak.segment1 || '-' || ak.segment2
               AND FV1.flex_value LIKE 'SV%'
               AND ft1.language = 'ESA'
               AND ft2.language = 'ESA'
               AND FV1.FLEX_VALUE_SET_ID = 1014897
               AND FV2.FLEX_VALUE_SET_ID = 1014898)
          DESCRIPTION_PROJECT, 
--       B.COST,
--       LC.SEGMENT1 || '-' || LC.SEGMENT2 || '-' || LC.SEGMENT3 || '-' ||
--       LC.SEGMENT4 || '-' || LC.SEGMENT5 || '-' || LC.SEGMENT6 LOCATION_CODE,
--       FVT1.DESCRIPTION LOCATION_DESCRIPTION,
       (SELECT DP.PERIOD_NAME
          FROM FA.FA_ADJUSTMENTS ADJ, FA.FA_DEPRN_PERIODS DP
         WHERE SOURCE_TYPE_CODE = 'CIP ADDITION'
           AND ADJUSTMENT_TYPE = 'CIP COST'
           AND ADJ.BOOK_TYPE_CODE = B.BOOK_TYPE_CODE
           AND ASSET_ID = A.ASSET_ID
           AND ADJ.PERIOD_COUNTER_ADJUSTED = DP.PERIOD_COUNTER
           AND ADJ.BOOK_TYPE_CODE = DP.BOOK_TYPE_CODE) PERIODO_ADICION
  FROM APPS.FA_ADDITIONS            A,
       FA.FA_ASSET_KEYWORDS         AK,
       FA.FA_BOOKS                  B,
       FA.FA_TRANSACTION_HEADERS    TH,
       APPS.FA_CATEGORIES           CT,
       APPS.FA_LOCATIONS            LC,
       APPS.FA_DISTRIBUTION_HISTORY DH,
       APPS.FND_FLEX_VALUE_SETS     FVS1,
       APPS.FND_FLEX_VALUES         FV1,
       APPS.FND_FLEX_VALUES_TL      FVT1
WHERE A.ASSET_ID = B.ASSET_ID
AND (AK.SEGMENT1 || '-' || AK.SEGMENT2) = NVL(:P_PROYECTO,(AK.SEGMENT1 || '-' || AK.SEGMENT2))
   AND A.ASSET_KEY_CCID = AK.CODE_COMBINATION_ID
      --   AND A.ASSET_TYPE = 'CIP'
   AND A.ASSET_CATEGORY_ID = CT.CATEGORY_ID
   AND B.BOOK_TYPE_CODE = 'SV_TELEMOV_IFRS'
   AND B.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE
   AND A.ASSET_ID = TH.ASSET_ID
   AND B.TRANSACTION_HEADER_ID_IN = TH.TRANSACTION_HEADER_ID
   AND TH.TRANSACTION_HEADER_ID in
       (SELECT MAX(TH2.TRANSACTION_HEADER_ID)
          FROM FA.FA_TRANSACTION_HEADERS TH2
         WHERE TH2.ASSET_ID = A.ASSET_ID
           AND B.BOOK_TYPE_CODE = TH2.BOOK_TYPE_CODE
           AND TH2.TRANSACTION_DATE_ENTERED <
               TO_DATE(:P_FECHA_HASTA, 'DD/MM/YYYY')
           AND TH2.TRANSACTION_TYPE_CODE IN
               ('CIP ADDITION', 'CIP ADJUSTMENT', 'FULL RETIREMENT'))
   AND NOT EXISTS
(SELECT '1'
          FROM FA.FA_TRANSACTION_HEADERS TH2, FA.FA_ADJUSTMENTS ADJ
         WHERE TH2.ASSET_ID = A.ASSET_ID
           AND B.BOOK_TYPE_CODE = TH2.BOOK_TYPE_CODE
           AND TH2.BOOK_TYPE_CODE = ADJ.BOOK_TYPE_CODE
           AND TH2.TRANSACTION_HEADER_ID = ADJ.TRANSACTION_HEADER_ID
           AND TH2.ASSET_ID = ADJ.ASSET_ID
           AND TH2.TRANSACTION_DATE_ENTERED <
               TO_DATE(:P_FECHA_HASTA, 'DD/MM/YYYY')
           AND ADJ.SOURCE_TYPE_CODE = 'ADDITION'
           AND ADJUSTMENT_TYPE = 'CIP COST')
   AND FVS1.FLEX_VALUE_SET_NAME = 'XX_FA_MIC_SITE_VS'
   AND FVS1.FLEX_VALUE_SET_ID = FV1.FLEX_VALUE_SET_ID
   AND FV1.FLEX_VALUE = LC.SEGMENT5
   AND FV1.FLEX_VALUE_ID = FVT1.FLEX_VALUE_ID
   AND FVT1.LANGUAGE = 'US'
   AND FV1.PARENT_FLEX_VALUE_LOW = 'SV'
   AND A.ASSET_ID = DH.ASSET_ID
   AND DH.BOOK_TYPE_CODE = B.BOOK_TYPE_CODE
   and dh.distribution_id =
       (select max(distribution_id)
          FROM FA.FA_DISTRIBUTION_HISTORY DH2
         WHERE DH2.ASSET_ID = A.ASSET_ID
           AND DH2.BOOK_TYPE_CODE = B.BOOK_TYPE_CODE)
   AND DH.DATE_INEFFECTIVE IS NULL
   and lc.location_id = dh.location_id
   AND B.COST !=0;
   

    V_DELIMITER varchar2 (1):= chr(9);
    line varchar2(4000);
    
    
    begin
        fnd_file.put_line(fnd_file.log,'+---------------------------------------------------------------------------+');
        fnd_file.put_line(fnd_file.log,'P_LIBRO_CONTABLE  '||P_BOOK_TYPE_CODE);
        fnd_file.put_line(fnd_file.log,'p_PROYECTO   '||p_PROYECTO);
        fnd_file.put_line(fnd_file.log,'P_PERIOD     '||P_PERIOD);
        fnd_file.put_line(fnd_file.log,'+---------------------------------------------------------------------------+');

        line := 'COMPANY' || V_DELIMITER  || 
                'ASSET_CODE' || V_DELIMITER  || 
                'LEGACY_CODE' || V_DELIMITER  || 
                'DESCRIPTION' || V_DELIMITER  || 
                'CAR' || V_DELIMITER  || 
                'CAR_DESCRIPTION' || V_DELIMITER  || 
                'MANUFACTURER_NAME' || V_DELIMITER  || 
                'MANUFACTURER_NUMBER' || V_DELIMITER  || 
                'SERIAL_NUMBER' || V_DELIMITER  || 
                'ASSET_TYPE' || V_DELIMITER  || 
                'ATTRIBUTE_CATEGORY_CODE' || V_DELIMITER  || 
                'CLEARING_ACCOUNT' || V_DELIMITER  || 
                'DATE_PLACED_IN_SERVICE' || V_DELIMITER  || 
                'LIFE_IN_MONTHS' || V_DELIMITER  || 
                'COST' || V_DELIMITER  || 
                'LOCATION' || V_DELIMITER  || 
                'LOCATION_DESCRIPTION' || V_DELIMITER  || 
                'EMPLOYEE_ORACLE_NUMBER' || V_DELIMITER  || 
                'ORACLE_EMPLOYEE' || V_DELIMITER  || 
                'LEGACY_EMPLOYEE_NUMBER' || V_DELIMITER  || 
                'PO_NUMBER' || V_DELIMITER  || 
                'INVOICE' || V_DELIMITER  || 
                'SUPPLIER' || V_DELIMITER  || 
                'PROYECTO_ACTIVO' || V_DELIMITER  || 
                'DESCRIPTION_PROJECT' ;

        fnd_file.put_line(fnd_file.output,'Asset Book  '|| V_DELIMITER ||P_BOOK_TYPE_CODE);
        fnd_file.put_line(fnd_file.output,'Project   '|| V_DELIMITER ||p_PROYECTO);
        fnd_file.put_line(fnd_file.output,'P_PERIOD     ' || V_DELIMITER  || P_PERIOD);
        
        fnd_file.put_line(fnd_file.output,line);
        
        for x in cip_data loop        
        line := 
            X.COMPANY                                       || V_DELIMITER  ||
            X.ASSET_CODE                                    || V_DELIMITER  ||
            X.LEGACY_CODE                                   || V_DELIMITER  ||
            X.DESCRIPTION                                   || V_DELIMITER  ||
            X.CAR                                           || V_DELIMITER  ||
            X.CAR_DESCRIPTION                               || V_DELIMITER  ||
            X.MANUFACTURER_NAME                             || V_DELIMITER  ||
            X.MANUFACTURER_NUMBER                           || V_DELIMITER  ||
            X.SERIAL_NUMBER                                 || V_DELIMITER  ||
            X.ASSET_TYPE                                    || V_DELIMITER  ||
            X.ATTRIBUTE_CATEGORY_CODE                       || V_DELIMITER  ||
            X.CLEARING_ACCOUNT                              || V_DELIMITER  ||
            X.DATE_PLACED_IN_SERVICE                        || V_DELIMITER  ||
            X.LIFE_IN_MONTHS                                || V_DELIMITER  ||
            X.COST                                          || V_DELIMITER  ||
            X.LOCATION                                      || V_DELIMITER  ||
            X.LOCATION_DESCRIPTION                          || V_DELIMITER  ||
            X.EMPLOYEE_ORACLE_NUMBER                        || V_DELIMITER  ||
            X.ORACLE_EMPLOYEE                               || V_DELIMITER  ||
            X.LEGACY_EMPLOYEE_NUMBER                        || V_DELIMITER  ||
            X.PO_NUMBER                                     || V_DELIMITER  ||
            X.INVOICE                                       || V_DELIMITER  ||
            X.SUPPLIER                                      || V_DELIMITER  ||
            X.PROYECTO_ACTIVO                               || V_DELIMITER  ||
            X.DESCRIPTION_PROJECT                           || V_DELIMITER;

              
            fnd_file.put_line(fnd_file.output,line);

        end loop;
    exception
        when others then 
            ebuff := 'Error al Main Procedure ' || sqlerrm;
            ECODE := '2';
    end;                                
                                
 -- finaliza cip report
---------------------------------------------------------------------------------
--- PAQUETE ACTIVO FIJO Y PROCEDIMIENTO DE FIXED ASSET REPORT

procedure ALL_ASSET( ECODE out varchar2 
                        ,ebuff out varchar2 
                        ,P_LEDGER_ID number
                        ,P_BOOK_TYPE_CODE  varchar2    --+ 'SV_TELEMOV_IFRS'
                        ,P_PERIOD     varchar2    --+  formate MM-YY
                        ) is
cursor fixed_data is 
select a.asset_number codigo,
       a.attribute1 codigo_legado,
       a.description,
       a.manufacturer_name marca,
       a.model_number,
       a.serial_number,
       a.asset_type,
       a.attribute_category_code,
       (select min(CC2.SEGMENT1 || '.' || CC2.SEGMENT2 || '.' || CC2.SEGMENT3 || '.' ||
               CC2.SEGMENT4 || '.' || CC2.SEGMENT5 || '.' || CC2.SEGMENT6 || '.' ||
               CC2.SEGMENT7 || '.' || CC2.SEGMENT8 || '.' || CC2.SEGMENT9 || '.' ||
               CC2.SEGMENT10 || '.' || CC2.SEGMENT11 || '.' || CC2.SEGMENT12 || '.' ||
               CC2.SEGMENT13)
          from fa.FA_DISTRIBUTION_HISTORY DH, gl.gl_code_combinations cc2
         where DH.asset_id = a.asset_id
           AND DH.BOOK_TYPE_CODE = :P_BOOK_TYPE_CODE--B.BOOK_TYPE_CODE
           and DH.code_combination_id = cc2.code_combination_id
           and DH.DISTRIBUTION_ID =
               (select min(DISTRIBUTION_ID)
                  from fa.FA_DISTRIBUTION_HISTORY DH2
                 where DH2.asset_id = a.asset_id)) CUENTA_GASTO,
       CC.SEGMENT1 || '.' || CC.SEGMENT2 || '.' || CC.SEGMENT3 || '.' ||
       CC.SEGMENT4 || '.' || CC.SEGMENT5 || '.' || CC.SEGMENT6 || '.' ||
       CC.SEGMENT7 || '.' || CC.SEGMENT8 || '.' || CC.SEGMENT9 || '.' ||
       CC.SEGMENT10 || '.' || CC.SEGMENT11 || '.' || CC.SEGMENT12 || '.' ||
       CC.SEGMENT13 CUENTA_ACTIVO, -- cuenta de activo
       (select min(CC1.SEGMENT1 || '.' || CC1.SEGMENT2 || '.' || CC1.SEGMENT3 || '.' ||
               CC1.SEGMENT4 || '.' || CC1.SEGMENT5 || '.' || CC1.SEGMENT6 || '.' ||
               CC1.SEGMENT7 || '.' || CC1.SEGMENT8 || '.' || CC1.SEGMENT9 || '.' ||
               CC1.SEGMENT10 || '.' || CC1.SEGMENT11 || '.' || CC1.SEGMENT12 || '.' ||
               CC1.SEGMENT13)
          from fa.fa_asset_invoices ai, gl.gl_code_combinations cc1
         where ai.asset_id = a.asset_id
           and ai.payables_code_combination_id = cc1.code_combination_id
           and ai.invoice_transaction_id_in =
               (select min(invoice_transaction_id_in)
                  from fa.fa_asset_invoices ai2
                 where ai2.asset_id = a.asset_id)) CUENTA_CLEARING,
       -- cuenta clearing
       b.date_placed_in_service,
       B.life_in_months,
       b.cost,
       (select MAX(DEPRN_RESERVE)
                      FROM FA.FA_DEPRN_PERIODS DP, FA.FA_DEPRN_DETAIL DD
                     WHERE DP.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
                       AND DD.BOOK_TYPE_CODE = b.book_type_code
                       AND DD.ASSET_ID = B.ASSET_ID
                       AND DP.PERIOD_COUNTER = DD.PERIOD_COUNTER
                       AND DD.DEPRN_SOURCE_CODE != 'B'
                       AND DP.PERIOD_COUNTER <= (SELECT DP2.PERIOD_COUNTER 
                                                   FROM FA.FA_DEPRN_PERIODS DP2 
                                                  WHERE DP2.PERIOD_NAME = :P_PERIODO
                                                    AND DP2.BOOK_TYPE_CODE = :P_BOOK_TYPE_CODE)) DEPRECIACION_ACUMULADA,
       (select SUM(YTD_DEPRN)
          FROM FA.FA_DEPRN_PERIODS DP, FA.FA_DEPRN_DETAIL DD
         WHERE DP.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
           AND DD.ASSET_ID = B.ASSET_ID
           AND DD.BOOK_TYPE_CODE = b.book_type_code
           AND DP.PERIOD_COUNTER = DD.PERIOD_COUNTER
           AND DP.PERIOD_NAME = :P_PERIODO) DEPRECIACION_YTD,
       (select SUM(DEPRN_AMOUNT)
          FROM FA.FA_DEPRN_PERIODS DP, FA.FA_DEPRN_DETAIL DD
         WHERE DP.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
           AND DD.BOOK_TYPE_CODE = b.book_type_code
           AND DD.ASSET_ID = B.ASSET_ID
           AND DP.PERIOD_COUNTER = DD.PERIOD_COUNTER
           AND DP.PERIOD_NAME = :P_PERIODO) DEPRECIACION_MES,
       b.cost - nvl((select MAX(DEPRN_RESERVE)
                      FROM FA.FA_DEPRN_PERIODS DP, FA.FA_DEPRN_DETAIL DD
                     WHERE DP.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
                       AND DD.BOOK_TYPE_CODE = b.book_type_code
                       AND DD.ASSET_ID = B.ASSET_ID
                       AND DP.PERIOD_COUNTER = DD.PERIOD_COUNTER
                       AND DD.DEPRN_SOURCE_CODE != 'B'
                       AND DP.PERIOD_COUNTER <= (SELECT DP2.PERIOD_COUNTER 
                                                   FROM FA.FA_DEPRN_PERIODS DP2 
                                                  WHERE DP2.PERIOD_NAME = :P_PERIODO 
                                                    AND DP2.BOOK_TYPE_CODE = :P_BOOK_TYPE_CODE)),
                    0) VALOR_NETO,
       l.segment1 || '-' || l.segment2 || '-' || l.segment3 || '-' ||
       l.segment4 || '-' || l.segment5 || '-' || l.segment6 LOCATION,
       (SELECT FT1.DESCRIPTION
          FROM FND_FLEX_VALUES FV1, FND_FLEX_VALUES_TL FT1
         WHERE FV1.FLEX_VALUE_ID = FT1.FLEX_VALUE_ID
           and FV1.PARENT_FLEX_VALUE_LOW = 'SV'
           and ft1.language = 'ESA'
           AND FV1.FLEX_VALUE_SET_ID = 1014903
           AND FV1.FLEX_VALUE = L.SEGMENT5) DESCRIPCION_LOCATION,
        (select P.EMPLOYEE_NUMBER
          from fa.fa_distribution_history dh, PER_ALL_PEOPLE_F P
         where dh.asset_id = b.asset_id
           AND DH.ASSIGNED_TO = P.PERSON_ID
           and dh.book_type_code = :P_BOOK_TYPE_CODE--b.book_type_code
           and dh.transaction_header_id_out is null
           AND ROWNUM = 1) CODIGO_EMPLEADO_ORACLE,   
       (select P.FULL_NAME
          from fa.fa_distribution_history dh, PER_ALL_PEOPLE_F P
         where dh.asset_id = b.asset_id
           AND DH.ASSIGNED_TO = P.PERSON_ID
           and dh.book_type_code = :P_BOOK_TYPE_CODE--b.book_type_code
           and dh.transaction_header_id_out is null
           AND ROWNUM = 1) EMPLEADO_ORACLE,
       (select P.ATTRIBUTE1
          from fa.fa_distribution_history dh, PER_ALL_PEOPLE_F P
         where dh.asset_id = b.asset_id
           AND DH.ASSIGNED_TO = P.PERSON_ID
           and dh.book_type_code = :P_BOOK_TYPE_CODE--b.book_type_code
           and dh.transaction_header_id_out is null
           AND ROWNUM = 1) EMPLEADO_LEGADO,
       (select min(po_number)
          from fa.fa_asset_invoices ai
         where ai.asset_id = a.asset_id
           and ai.invoice_transaction_id_in =
               (select min(invoice_transaction_id_in)
                  from fa.fa_asset_invoices ai2
                 where ai2.asset_id = a.asset_id)) OC,
       (select min(invoice_number)
          from fa.fa_asset_invoices ai
         where ai.asset_id = a.asset_id
          and ai.invoice_transaction_id_in =
               (select min(invoice_transaction_id_in)
                  from fa.fa_asset_invoices ai2
                 where ai2.asset_id = a.asset_id)) FACTURA,
       (select min(asu.vendor_name)
          from fa.fa_asset_invoices ai, ap_suppliers asu
         where ai.asset_id = a.asset_id
           and ai.invoice_transaction_id_in =
               (select min(invoice_transaction_id_in)
                  from fa.fa_asset_invoices ai2
                 where ai2.asset_id = a.asset_id)
           and ai.po_vendor_id = asu.vendor_id) PROVEEDOR,
       ak.segment1 || '-' || ak.segment2 PROYECTO, -- proyecto
       (SELECT FT1.DESCRIPTION || '-' || FT2.DESCRIPTION
          FROM FND_FLEX_VALUES    FV1,
               FND_FLEX_VALUES_TL FT1,
               FND_FLEX_VALUES    FV2,
               FND_FLEX_VALUES_TL FT2
         WHERE FV1.FLEX_VALUE_ID = FT1.FLEX_VALUE_ID
           AND FV2.FLEX_VALUE_ID = FT2.FLEX_VALUE_ID
           and FV2.PARENT_FLEX_VALUE_LOW = FV1.FLEX_VALUE
           and FV1.FLEX_VALUE || '-' || FV2.FLEX_VALUE =
               ak.segment1 || '-' || ak.segment2
           and FV1.flex_value like 'SV%'
           and ft1.language = 'ESA'
           and ft2.language = 'ESA'
           AND FV1.FLEX_VALUE_SET_ID = 1014897
           AND FV2.FLEX_VALUE_SET_ID = 1014898) DESCRIPCION_PROYECTO -- descripción del proyecto
  from apps.fa_additions_v     a,
       fa.fa_books             b,
       fa.fa_asset_keywords    ak,
       fa.fa_locations         l,
       FA.FA_CATEGORY_BOOKS    CB,
       GL.GL_CODE_COMBINATIONS CC
where a.asset_id = b.asset_id
   AND A.ASSET_CATEGORY_ID = CB.CATEGORY_ID
   AND B.COST != 0
   AND CB.BOOK_TYPE_CODE = b.book_type_code
   and l.location_id =
       (select min(location_id)
         from fa.fa_distribution_history dh
         where dh.asset_id = b.asset_id
           and dh.book_type_code = :P_BOOK_TYPE_CODE--b.book_type_code
           and dh.transaction_header_id_out is null)
   and b.transaction_header_id_out is null
   and b.book_type_code = :P_BOOK_TYPE_CODE
   and a.asset_key_ccid = ak.code_combination_id
   AND CB.ASSET_COST_ACCOUNT_CCID = CC.CODE_COMBINATION_ID
   --AND (L.SEGMENT5='&SITIO' OR '&SITIO' IS NULL);

   ;
   

    V_DELIMITER varchar2 (1):= chr(9);
    line varchar2(4000);
    
    
    begin
        fnd_file.put_line(fnd_file.log,'+---------------------------------------------------------------------------+');
        fnd_file.put_line(fnd_file.log,'P_LIBRO_CONTABLE  '||P_BOOK_TYPE_CODE);
        fnd_file.put_line(fnd_file.log,'P_PERIOD     '||P_PERIOD);
        fnd_file.put_line(fnd_file.log,'+---------------------------------------------------------------------------+');

        line := 'CODIGO' || V_DELIMITER  || 
                'LEGACY_CODE' || V_DELIMITER  || 
                'DESCRIPTION' || V_DELIMITER  || 
                'MANUFACTURER_NAME' || V_DELIMITER  || 
                'MODEL_NUMBER' || V_DELIMITER  || 
                'SERIAL_NUMBER' || V_DELIMITER  || 
                'ASSET_TYPE' || V_DELIMITER  || 
                'ATTRIBUTE_CATEGORY_CODE' || V_DELIMITER  || 
                'CUENTA_GASTO' || V_DELIMITER  || 
                'CUENTA_ACTIVO' || V_DELIMITER  || 
                'CLEARING_ACCOUNT' || V_DELIMITER  || 
                'DATE_PLACED_IN SERVICE' || V_DELIMITER  || 
                'LIFE_IN_MONTHS' || V_DELIMITER  || 
                'COST' || V_DELIMITER  || 
                'DEPRECIACION_ACUMULADA' || V_DELIMITER  || 
                'DEPRECIACION_YTD' || V_DELIMITER  || 
                'DEPRECIACION_MES' || V_DELIMITER  || 
                'VALOR_NETO' || V_DELIMITER  || 
                'LOCATION' || V_DELIMITER  || 
                'LOCATION_DESCRIPTION' || V_DELIMITER  || 
                'CODIGO_EMPLEADO_ORACLE' || V_DELIMITER  || 
                'EMPLEADO_ORACLE' || V_DELIMITER  || 
                'EMPLEADO_LEGADO' || V_DELIMITER  || 
                'PO_NUMBER' || V_DELIMITER  || 
                'INVOICE' || V_DELIMITER  || 
                'SUPPLIER' || V_DELIMITER  || 
                'PROYECTO' || V_DELIMITER  || 
                'DESCRIPTION_PROJECT' ; 

        fnd_file.put_line(fnd_file.output,'Asset Book  '|| V_DELIMITER ||P_BOOK_TYPE_CODE);
        fnd_file.put_line(fnd_file.output,'P_PERIOD     ' || V_DELIMITER  || P_PERIOD);
        
        fnd_file.put_line(fnd_file.output,line);
        
        for Y in fixed_data loop        
        line := 
                to_char(Y.CODIGO)           || V_DELIMITER  || 
                Y.LEGACY_CODE               || V_DELIMITER  || 
                Y.DESCRIPTION               || V_DELIMITER  || 
                Y.MANUFACTURER_NAME         || V_DELIMITER  || 
                to_char(Y.MODEL_NUMBER)     || V_DELIMITER  || 
                to_char(Y.SERIAL_NUMBER)    || V_DELIMITER  || 
                Y.ASSET_TYPE                || V_DELIMITER  || 
                Y.ATTRIBUTE_CATEGORY_CODE   || V_DELIMITER  || 
                Y.CUENTA_GASTO              || V_DELIMITER  || 
                Y.CUENTA_ACTIVO             || V_DELIMITER  || 
                Y.CLEARING_ACCOUNT          || V_DELIMITER  || 
                Y.DATE_PLACED_IN_SERVICE    || V_DELIMITER  || 
                Y.LIFE_IN_MONTHS            || V_DELIMITER  || 
                to_char (Y.COST)            || V_DELIMITER  || 
                Y.DEPRECIACION_ACUMULADA    || V_DELIMITER  || 
                Y.DEPRECIACION_YTD          || V_DELIMITER  || 
                Y.DEPRECIACION_MES          || V_DELIMITER  || 
                to_char(Y.VALOR_NETO)       || V_DELIMITER  || 
                Y.LOCATION                  || V_DELIMITER  || 
                Y.LOCATION_DESCRIPTION      || V_DELIMITER  || 
                Y.CODIGO_EMPLEADO_ORACLE    || V_DELIMITER  || 
                Y.EMPLEADO_ORACLE           || V_DELIMITER  || 
                Y.EMPLEADO_LEGADO           || V_DELIMITER  || 
                to_char (Y.PO_NUMBER)       || V_DELIMITER  || 
                to_char (Y.INVOICE)         || V_DELIMITER  || 
                Y.SUPPLIER                  || V_DELIMITER  || 
                Y.PROYECTO                  || V_DELIMITER  || 
                Y.DESCRIPTION_PROJECT       || V_DELIMITER;
            

              
            fnd_file.put_line(fnd_file.output,line);

        end loop;
    exception
        when others then 
            ebuff := 'Error al Main Procedure ' || sqlerrm;
            ECODE := '2';
    end;                                
                                

end  XXSV_FA_REPORTS;
/
exit
/
