CREATE OR REPLACE package BOLINF.XXSV_FA_REPORTS authid current_user as
-- 
--                           XXSV_FA_REPORTS  SV
-- 
--
-- Reference       XXSV_AP011_00008
-- Program Name    XXSV_FA_REPORTS
-- Description     Create Report for Text Output
--
-- DEVELOPMENT AND MAINTENANCE HISTORY
--
-- Date          Author             Version  Description
-- ------------  -----------------  -------  ---------------------------------------
-- 06-JUN-2014   Carlos Torres        1.0      Initial Creation
-- 06-JUN-2014   jonathan ulloa       1.1      
--
--         

procedure CIP_ADDITIONS( ECODE out varchar2 
                        ,ebuff out varchar2 
                        ,P_LEDGER_ID number
                        ,P_BOOK_TYPE_CODE  varchar2    --+ 'SV_TELEMOV_IFRS'
                        ,P_PERIOD     varchar2    --+ 
                        ,p_PROYECTO    varchar2    --+ 'SV9999-99998'
                        );
                        


--------------------------------------------------------------------------------------
--                         XX_SV_FA_FIXED_ASSET_REPORT
-- 
--
-- Reference       XXSV_AP011_00008
-- Program Name    XX_SV_FA_FIXED_ASSET_REPORT
-- Description     Create Report for Text Output
--
-- DEVELOPMENT AND MAINTENANCE HISTORY
--
-- Date          Author             Version  Description
-- ------------  -----------------  -------  ---------------------------------------
-- 12-06-14      jonathan ulloa     1.0      reporte auxiliar de activo fijo

procedure ALL_ASSET( ECODE out varchar2 
                        ,ebuff out varchar2 
                         ,P_LEDGER_ID number
                        ,P_BOOK_TYPE_CODE  varchar2    --+ 'SV_TELEMOV_IFRS'
                        ,P_PERIOD     varchar2    --+  formate MM-YY
                        );
                        
end ;
/
exit 
/
