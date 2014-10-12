#/*=========================================================================+
#|  Copyright (c) 2011 Oratechla, San Salvador, El Salvador                 |
#|                         ALL rights reserved.                             |
#+==========================================================================+
#|                                                                          |
#| FILENAME                                                                 |
#|     XXSV_AP012_00002.sh                                                  |
#|                                                                          |
#| DESCRIPTION                                                              |
#|    Shell Script para la instalacion de parches - Proyecto TIGO           |
#|                                                                          |
#| SOURCE CONTROL                                                           |
#|    Version: %I%                                                          |
#|    Fecha  : %E% %U%                                                      |
#|                                                                          |
#| HISTORY                                                                  |
#|    06-Nov-2012  Carlos Torres   Modify   Tigo SV                         |
#+=========================================================================*/


echo ''
echo '                          Oracle LAD eStudio                          '
echo '         Copyright (c) 2011 Oracle El Salvador, San Salvador          '
echo '                        All rights reserved.                          '
echo 'Starting installation process for patch XXSV_FA010_00001              '
echo

# FUNCIONES
read_db_pwd ()
{
    stty -echo # Deshabilito el ECO del Teclado

    PASSWORD_OK="No"

    while [ "${PASSWORD_OK}" != "Yes" ]
    do
        # Leo la contraseña del usuario de BD
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


# Ingreso de la contraseña para el usuario APPS. Usar funcion read_db_pwd $user
read_db_pwd "APPS"
APPS_PASS=$DB_PASS



# Copia de los Objetos. Usar funcion copy_file $origen $destino $file


export NLS_LANG="LATIN AMERICAN SPANISH_AMERICA.WE8ISO8859P1"


# CREACION de Tablas BOLINF

# Compilacion de Permisos APPS to BOLINF FASE 2


cd xbol/admin/import

echo ' '
echo 'Loading Custom Appplication Concurrent Programs'
FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $FND_TOP/patch/115/import/afcpprog.lct C_XXXSVCIPACTFI.ldt - CUSTOM_MODE=FORCE
echo 'End loading Custom Appplication Concurrent Programs'


# Carga de FlexFields
echo ' '
# Carga Record Groups.

echo 'Loading Request Groups'
FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $FND_TOP/patch/115/import/afcpreqg.lct R_All_Reports_and_Programs.ldt - CUSTOM_MODE=FORCE
echo 'End loading Request Groups'



cd ..
cd ..
cd ..


echo 'Loading RTF Templates and XML Data Templates'
# TEMPLATE
cd au/template

FNDLOAD apps/$APPS_PASS 0 Y UPLOAD $XDO_TOP/patch/115/import/xdotmpl.lct D_XXSVCIPACTFI.ldt  - CUSTOM_MODE=FORCE

# DATA DEFINITION
XMLPubTemplateExpUpload.sh $APPS_PASS \
    DATA_TEMPLATE \
    XBOL \
    XXSVCIPACTFI \
    00 \
    00 \
    XML-DATA-TEMPLATE \
    XXSVCIPACTFI.xml

	
# TEMPLATE
XMLPubTemplateExpUpload.sh $APPS_PASS \
    TEMPLATE_SOURCE \
    XBOL \
    XXSVCIPACTFI \
    en \
    00 \
    RTF \
    XXSVCIPACTFI.rtf
	   

echo 'End loading RTF Templates and XML Data Templates'
	
cd ..
cd ..
echo '////////////////////////////////////////////////////'
echo '/                                                  /'
echo '/              Instalation complete.               /'
echo '/                                                  /'
echo '/              Please check log files.             /'
echo '/                                                  /'
echo '////////////////////////////////////////////////////'