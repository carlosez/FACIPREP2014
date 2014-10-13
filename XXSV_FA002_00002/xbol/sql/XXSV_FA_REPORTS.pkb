CREATE OR REPLACE package body BOLINF.XXSV_FA_REPORTS  as

cursor  FLEX_VALUE_DESCRIPTION_DATA( p_FLEX_VALUE_SET_NAME varchar, p_FLEX_VALUE varchar, p_language varchar) is
 select FLEX_VALUE_SET_NAME, FV1.FLEX_VALUE, FVT1.DESCRIPTION
   from APPS.FND_FLEX_VALUE_SETS FVS1
       ,APPS.FND_FLEX_VALUES FV1
       ,APPS.FND_FLEX_VALUES_TL FVT1
   where FVS1.FLEX_VALUE_SET_NAME = p_FLEX_VALUE_SET_NAME --'XX_INV_MIC_SEGMENT_VALUES_VS'
     AND FVS1.FLEX_VALUE_SET_ID = FV1.FLEX_VALUE_SET_ID
     AND FV1.FLEX_VALUE_ID = FVT1.FLEX_VALUE_ID
     AND FVT1.LANGUAGE = p_language 
     and FV1.FLEX_VALUE = p_FLEX_VALUE
     ;


cursor PROJECT_DESCRIPTION_DATA (  p_project varchar , p_lang varchar) is
SELECT   substr( FT1.DESCRIPTION,1,45) || '-' || substr(FT2.DESCRIPTION,1,45) DESCRIPTION
          FROM FND_FLEX_VALUES FV1,  FND_FLEX_VALUES_TL FT1,   FND_FLEX_VALUES FV2, FND_FLEX_VALUES_TL FT2      
         WHERE     FV1.FLEX_VALUE_ID = FT1.FLEX_VALUE_ID
               AND FV2.FLEX_VALUE_ID = FT2.FLEX_VALUE_ID
               AND FV2.PARENT_FLEX_VALUE_LOW = FV1.FLEX_VALUE
               AND FV1.FLEX_VALUE || '-' || FV2.FLEX_VALUE = p_project
               AND ft1.language = p_lang
               AND ft2.language = p_lang
               AND FV1.FLEX_VALUE_SET_ID = 1014897
               AND FV2.FLEX_VALUE_SET_ID = 1014898
               ;


FUNCTION sub_lat_chr (Pin_string  VARCHAR2) RETURN VARCHAR2  IS
    pout_string  VARCHAR2(4000);
    special_chr varchar2 (150);
    replace_chr varchar2 (150);

BEGIN

    special_chr := chr(50048)||chr(50049)||chr(50050)||chr(50051)||chr(50052)||chr(50056)||chr(50057)||chr(50058)||chr(50059)||chr(50060)||chr(50061)||chr(50062)||chr(50063)||chr(50065)||chr(50066)||chr(50067)||chr(50068)||chr(50069)||chr(50070)||chr(50073)||chr(50074)||chr(50075)||chr(50076)||chr(50080)||chr(50081)||chr(50082)||chr(50083)||chr(50084)||chr(50085)||chr(50086)||chr(50088)||chr(50089)||chr(50090)||chr(50091)||chr(50092)||chr(50093)||chr(50094)||chr(50095)||chr(50097)||chr(50098)||chr(50099)||chr(50100)||chr(50101)||chr(50102)||chr(50105)||chr(50106)||chr(50107)||chr(50108)||chr(50087)||chr(50055);
    replace_chr := 'AAAAAEEEEIIIINOOOOOUUUUaaaaaaeeeeeiiiinooooouuuucC';
    pout_string := translate ( pin_string, special_chr, replace_chr);

    RETURN pout_string;

END sub_lat_chr;

function FLEX_VALUE_DESCRIPTION ( p_FLEX_VALUE_SET_NAME varchar, p_FLEX_VALUE varchar, p_language varchar2 default 'US' ) return varchar2 is
v_description varchar2(240);
begin
    for X in  FLEX_VALUE_DESCRIPTION_data( p_FLEX_VALUE_SET_NAME , p_FLEX_VALUE, p_language ) loop
        v_description := x.DESCRIPTION;
    end loop;
    return v_description;
exception when others then
    return v_description;
end;


function PROJECT_DESC (  p_FLEX_VALUE varchar , p_language varchar2 default 'ESA' ) return varchar2 is
v_description varchar2(240);
begin
    for X in  PROJECT_DESCRIPTION_DATA( p_FLEX_VALUE , p_language ) loop
        v_description := x.DESCRIPTION;
    end loop;
    return v_description;
exception when others then
    return v_description;
end;

end  XXSV_FA_REPORTS;
/
