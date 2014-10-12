﻿#
#/*=========================================================================+
#|  Copyright (c) 2014 Entrustca, San Salvador, El Salvador                 |
#|                         ALL rights reserved.                             |
#+==========================================================================+
#|                                                                          |
#| FILENAME                                                                 |
#|     XXSV_FA002_00002.sh                                          |
#|                                                                          |
#| DESCRIPTION                                                              |
#|    Shell Script para la instalacion de parches - Proyecto TIGO         |
#|                                                                          |
#| SOURCE CONTROL                                                           |
#|    Version: %I%                                                          |
#|    Fecha  : %E% %U%                                                      |
#|                                                                          |
#| HISTORY                                                                  |
#|    13-06-2014  jonathan Ulloa   Created   Entrustca                        |
#+==========================================================================*/

echo ''
echo '                          Oracle LAD eStudio                          '
echo '           Copyright (c) 2012 Entrust San Salvador, El Salvador        '
echo '                        All rights reserved.                          '
echo 'Starting installation process for patch XX_AH_XTR_REP_MONT_PAG_DEU '
echo

# FUNCIONES
read_db_pwd ()
{
    stty -echo # Deshabilito el ECO del Tecladof

    PASSWORD_OK="No"

    while [ "${PASSWORD_OK}" != "Yes" ]
    do
        # Leo la contrasea del usuario de BD
        DB_PASS='' # Inicializo la Variable de Retorno

        while [ -z "${DB_PASS}" ]
        do
            echo -n "Please enter password for $1 user: "
            read DB_PASS
            echo
        
            if [ -z "${DB_PASS}" ]
            then
                echo "The password entered is null."
            fi

        done

        sqlplus -S /nolog <<EOF
whenever sqlerror exit 1
whenever oserror exit 1
conn $1/$DB_PASS
EOF

        if [ "$?" != "0" ]
        then
            echo "The $1 password entered is incorrect."
        else
            PASSWORD_OK="Yes"
        fi
    done

    stty echo # Rehabilito el ECO del Teclado
}

copy_file ()
{
    if [ -f $1/$3 ]
    then
        if [ -f $2/$3 ]
        then
            mv $2/$3 $2/$3_bak$(date +%Y%m%d%H%M%S)
        fi

        cp $1/$3 $2/
    else
        echo "File $1/$3 does not exist"
    fi
}

# COMIENZO DE INSTALACION DEL PARCHE



# Ingreso de la contrasea para el usuario APPS. Usar funcion read_db_pwd $user
read_db_pwd "APPS"
APPS_PASS=$DB_PASS

# Ingreso de la contrasea para el usuario BOLINF. Usar funcion read_db_pwd $user
read_db_pwd "BOLINF"
BOLINF_PASS=$DB_PASS

# Copia de los Objetos. Usar funcion copy_file $origen $destino $file
echo 'Copying objects SQL to $XBOL_TOP'


# Copia de los Imports
echo 'Copying objects LDT to $XBOL_TOP'

#copy_file xbol/admin/import $XBOL_TOP/admin/import XX_AR_REPCAJ_RES.ldt
#copy_file xbol/admin/import $XBOL_TOP/admin/import Receivables_All.ldt
#copy_file xbol/admin/import $XBOL_TOP/admin/import XX_AR_REPCAJ_RES_TMPL.ldt
#copia los  rdfs

#copy_file au/reports $XBOL_TOP/reports/ESA  XX_AP002F930.rdf

# Compilacion de Scripts
#echo 'Compiling Scripts'
#sqlplus bolinf/$BOLINF_PASS @xbol/sql/XX_AH_GET_CCID_USES.sql

echo '------------------------------------------------------------'
echo 'Compiling XXSV_FA_REPORTS.pks'
sqlplus bolinf/$BOLINF_PASS @xbol/sql/XXSV_FA_REPORTS.pks
echo '------------------------------------------------------------'
echo ' XXSV_FA_REPORTS.pkb'
sqlplus bolinf/$BOLINF_PASS @xbol/sql/XXSV_FA_REPORTS.pkb
echo '------------------------------------------------------------'
echo 'grant_bolinf.sql'
sqlplus bolinf/$BOLINF_PASS @xbol/sql/grant_bolinf.sql
echo '------------------------------------------------------------'
echo ' synonym_apps.sql'
sqlplus apps/$APPS_PASS @xbol/sql/synonym_apps.sql


#sqlplus bolinf/$BOLINF_PASS @xbol/sql/grants.sql
# En apps
#sqlplus apps/$APPS_PASS @xbol/sql/indexs.sql
#sqlplus apps/$APPS_PASS @xbol/sql/synonyms.sql


# Carga Concurrentes.
echo '------------------------------------------------------------'
echo 'Carga de Concurrentes'
echo 'C_XX_FA_SV_FIXED_ASSET_REP_XML.ldt'
FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct xbol/admin/import/C_XX_FA_SV_FIXED_ASSET_REP_XML.ldt CUSTOM_MODE="FORCE"
echo '------------------------------------------------------------'
echo 'C_XX_FA_SV_FIXED_ASSET_REPORT.ldt  ' 
FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct xbol/admin/import/C_XX_FA_SV_FIXED_ASSET_REPORT.ldt CUSTOM_MODE="FORCE"
echo '------------------------------------------------------------'
echo 'C_XXSVFACIPADD.ldt '
FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct xbol/admin/import/C_XXSVFACIPADD.ldt CUSTOM_MODE="FORCE"
echo '------------------------------------------------------------'
echo 'C_XXSVFAREPCIPADDTXT.ldt'
FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct xbol/admin/import/C_XXSVFAREPCIPADDTXT.ldt CUSTOM_MODE="FORCE"

# Carga Request Group.
echo '------------------------------------------------------------'
echo 'R_All_Reports_and_Programs.ldt'
FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $FND_TOP/patch/115/import/afcpreqg.lct xbol/admin/import/R_All_Reports_and_Programs.ldt CUSTOM_MODE="FORCE"

# Carga Template.
echo '------------------------------------------------------------'
echo 'Carga de Template'
echo 'T_XX_FA_SV_FIXED_ASSET_REP_XML.ldt'
FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $XDO_TOP/patch/115/import/xdotmpl.lct  xbol/admin/import/T_XX_FA_SV_FIXED_ASSET_REP_XML.ldt CUSTOM_MODE="FORCE" 
echo '------------------------------------------------------------'
echo 'T_XXSVFACIPADD.ldt '
FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $XDO_TOP/patch/115/import/xdotmpl.lct  xbol/admin/import/T_XXSVFACIPADD.ldt CUSTOM_MODE="FORCE" 

echo ' '
# Carga Template.
echo 'Carga de Data Definition'
#####################################################################################
# UPLOAD TEMPLATES  XML y RTF
#####################################################################################
echo 'XMLPubTemplateExpUpload.sh '
cd au/template
 #DATA DEFINITION
XMLPubTemplateExpUpload.sh $APPS_PASS \
   DATA_TEMPLATE \
    XBOL \
   	XXSVFACIPADD\
	00\
    00 \
    XML-DATA-TEMPLATE \
    XXSVFACIPADD.xml
	
	XMLPubTemplateExpUpload.sh $APPS_PASS \
   DATA_TEMPLATE \
    XBOL \
   	XX_FA_SV_FIXED_ASSET_REP_XML \
	00\
    00 \
    XML-DATA-TEMPLATE \
    XX_FA_SV_FIXED_ASSET_REP_XML.xml
	
echo 'Carga de Template rtf'
echo 'XMLPubTemplateExpUpload.sh '
XMLPubTemplateExpUpload.sh $APPS_PASS \
    TEMPLATE_SOURCE \
    XBOL \
    XX_FA_SV_FIXED_ASSET_REP_XML \
    en \
    00 \
    RTF \
    FIXEDASSETREPORT.rtf	
	
	XMLPubTemplateExpUpload.sh $APPS_PASS \
    TEMPLATE_SOURCE \
    XBOL \
    XXSVFACIPADD \
    en \
    00 \
    RTF \
    XXSVFACIPADD2.rtf

	XMLPubTemplateExpUpload.sh $APPS_PASS \
    TEMPLATE_SOURCE \
    XBOL \
    XX_FA_SV_FIXED_ASSET_REP_XML \
    esa \
    00 \
    RTF \
    FIXEDASSETREPORT.rtf	
	
	XMLPubTemplateExpUpload.sh $APPS_PASS \
    TEMPLATE_SOURCE \
    XBOL \
    XXSVFACIPADD \
    esa \
    00 \
    RTF \
    XXSVFACIPADD2.rtf

    
cd ..
cd ..
echo '+----------------------------------------------------------+'
echo '|                                                          |'
echo '|      Installation Complete. Please check log files       |'
echo '|                                                          |'
echo '+----------------------------------------------------------+'

