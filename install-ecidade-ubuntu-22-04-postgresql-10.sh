#!/bin/bash

function download_ecidade() {
#URL DO ARQUIVO
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1NykF56ay5uYtKHOLXQGQmoNLiX5lAKDP' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1NykF56ay5uYtKHOLXQGQmoNLiX5lAKDP" -O /tmp/ecidade.tar.bz2
}


#atribui configuraçao
function sed_configuracao() {
	orig=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $origparm ]];then
			origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
	dest=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $destparm ]];then
			destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
case ${dest} in
	\#${orig})
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	\;${orig})
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	${orig})
			if [[ $origparm != $destparm ]]; then
				sed -i "/^$orig/c\\${1}" $2
				else 
					if [[ -z $(grep '[A-Z\_A-ZA-Z]$origparm' $2) ]]; then
						fullorigparm3=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1) 
						fullorigparm4=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fullorigparm5=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						fulldestparm3=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fulldestparm4=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fulldestparm5=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						sed -i "/^$dest.*$fulldestparm3\ $fulldestparm4\ $fulldestparm5/c\\$orig\ \=\ $fullorigparm3\ $fullorigparm4\ $fullorigparm5" $2
					fi
			fi
		;;
		*)
			echo ${1} >> $2
		;;
	esac
}

clear

RELEASE=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -c18-30)

case "$RELEASE" in
    focal)
        echo "É UBUNTU 20.04 FOCAL"
	sleep 2
    ;;
    jammy)
        echo "É UBUNTU 22.04 JAMMY"
	sleep 2
    ;;
    *)
        echo "RELEASE INVALIDA"
	sleep 2
	exit
    ;;
esac
clear


echo "CONFIGURANDO CANAIS DE SOFTWARE DO POSTGRESQL"
sleep 2
case "$RELEASE" in
    bionic)
    touch /etc/apt/sources.list.d/pgdg.list
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7FCC7D46ACCC4CF8    
    ;;
    focal)
    touch /etc/apt/sources.list.d/pgdg.list
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7FCC7D46ACCC4CF8
    ;;
    jammy)
    touch /etc/apt/sources.list.d/pgdg.list
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${RELEASE}-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
    apt-get --force-yes --yes install curl ca-certificates gnupg
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg    
    ;;
    *)
    exit
    ;;
esac
clear

echo "AJUSTANDO REPOSITÓRIOS"
sleep 2
sed -i 's/\/archive/\/br.archive/g' /etc/apt/sources.list
clear


echo "AJUSTANDO IDIOMA"
sleep 2
apt-get update
apt-get --force-yes --yes install language-pack-gnome-pt language-pack-pt-base myspell-pt myspell-pt-br wbrazilian wportuguese software-properties-common

clear
echo "AJUSTANDO ENCODING"
sleep 2
if [[ -z $(grep reorder-after /usr/share/i18n/locales/pt_BR) ]]; then 
    sed -i '/^copy \"iso14651_t1\"/areorder-after <U00A0>\n<U0020><CAP>;<CAP>;<CAP>;<U0020>\nreorder-end' /usr/share/i18n/locales/pt_BR    
fi

chmod 777 /var/lib/locales/supported.d/pt
echo "pt_BR.ISO-8859-1 ISO-8859-1" >> /var/lib/locales/supported.d/pt
localedef -i pt_BR -c -f ISO-8859-1 -A /usr/share/locale/locale.alias pt_BR 
update-locale 
locale-gen --purge
dpkg-reconfigure --frontend noninteractive locales

clear
echo "INSTALANDO POSTGRESQL 10"
sleep 2
apt-get update
apt-get --force-yes --yes install postgresql-10 postgresql-client-10 postgresql-contrib-10

clear
echo "CONFIGURANDO POSTGRESQL"
sleep 2
pg_dropcluster --stop 10 main
pg_createcluster -u postgres -g postgres -e LATIN1 --locale="pt_BR.ISO-8859-1" --lc-collate="pt_BR.ISO-8859-1" 10 ecidade

# Liberando autenticao
sed -i 's/md5$/trust/g' /etc/postgresql/10/ecidade/pg_hba.conf
sed -i 's/peer$/trust/g' /etc/postgresql/10/ecidade/pg_hba.conf

PGPATH=/etc/postgresql/10/ecidade/postgresql.conf
sed_configuracao "listen_addresses = '*'" "$PGPATH"
sed_configuracao "max_connections = 20" "$PGPATH"
sed_configuracao "bytea_output = 'escape'" "$PGPATH"
sed_configuracao "max_locks_per_transaction = 256" "$PGPATH"
sed_configuracao "default_with_oids = on" "$PGPATH"
sed_configuracao "escape_string_warning = off" "$PGPATH"
sed_configuracao "standard_conforming_strings = off" "$PGPATH"

/etc/init.d/postgresql start

clear
echo "CRIANDO USUÁRIOS"
sleep 2
psql -U postgres -c "CREATE ROLE ecidade WITH SUPERUSER LOGIN PASSWORD 'ecidade';"
psql -U postgres -c "CREATE ROLE dbseller WITH LOGIN PASSWORD 'dbseller';"
psql -U postgres -c "CREATE ROLE plugin WITH LOGIN PASSWORD 'plugin';"

clear
echo "CRIANDO DATA-BASE"
sleep 2
psql -U postgres -c "CREATE DATABASE ecidade OWNER ecidade;"

clear
echo "INSTALANDO APACHE"
sleep 2
apt-get --force-yes --yes install apache2


clear
echo "CONFIGURANDO VIRTUAL HOST"
sleep 2
a2enmod rewrite
a2dissite 000-default default-ssl

cat << APADEF > /etc/apache2/sites-available/ecidade.conf
<VirtualHost *:80>
	
        LimitRequestLine 16382
        LimitRequestFieldSize 16382
        Timeout 12000
        AddDefaultCharset ISO-8859-1
        SetEnv no-gzip 1
        <Directory /var/www/html>
            Options -Indexes +FollowSymLinks +MultiViews
            AllowOverride All
            Require all granted
        </Directory>

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html

	ErrorLog /var/log/apache2/error.log
	CustomLog /var/log/apache2/access.log combined

</VirtualHost>
       
APADEF

a2ensite ecidade
/etc/init.d/apache2 restart

clear
echo "INSTALANDO PHP 5.6"
sleep 2
add-apt-repository -y ppa:ondrej/php
sudo apt-get update
apt-get --force-yes --yes install php5.6 php5.6-bcmath php5.6-bz2 php5.6-cli php5.6-common php5.6-curl php5.6-gd php5.6-interbase php5.6-json php5.6-mbstring php5.6-mcrypt php5.6-pgsql php5.6-soap php5.6-sqlite3 php5.6-xml php5.6-xmlrpc php5.6-zip unzip zip php5.6-common php5.6-interbase libapache2-mod-php5.6
apt-get --force-yes --yes install php5.6 php5.6-bcmath php5.6-bz2 php5.6-cli php5.6-common php5.6-curl php5.6-gd php5.6-interbase php5.6-json php5.6-mbstring php5.6-mcrypt php5.6-pgsql php5.6-soap php5.6-sqlite3 php5.6-xml php5.6-xmlrpc php5.6-zip unzip zip php5.6-common php5.6-interbase libapache2-mod-php5.6

clear
echo "CONFIGURANDO PHP 5.6"
sleep 2
mkdir /var/www/html/tmp
chown -R www-data. /var/www/html/tmp
chmod -R 777 /var/www/html/tmp
mkdir /var/www/tmp
chown -R www-data. /var/www/tmp
chmod -R 777 /var/www/tmp

# Configura o php5
PHPPATH=/etc/php/5.6/apache2/php.ini
sed_configuracao "register_argc_argv = On" "$PHPPATH"
sed_configuracao "post_max_size = 200M" "$PHPPATH"
sed_configuracao "upload_max_filesize = 200M" "$PHPPATH"
sed_configuracao "default_socket_timeout = 60000" "$PHPPATH"
sed_configuracao "max_execution_time = 60000" "$PHPPATH"
sed_configuracao "max_input_time = 60000" "$PHPPATH"
sed_configuracao "memory_limit = 512M" "$PHPPATH"
sed_configuracao "display_errors = Off" "$PHPPATH"
sed_configuracao "log_errors = On" "$PHPPATH"
sed_configuracao "session.gc_maxlifetime = 7200" "$PHPPATH"
sed_configuracao "short_open_tag = On" "$PHPPATH"
sed_configuracao "error_log = /var/log/apache2/php_errors.log" "$PHPPATH"
sed_configuracao 'date.timezone = "America/Sao_Paulo"' "$PHPPATH"
sed_configuracao "ignore_repeated_errors = On" "$PHPPATH"

PHPPATH=/etc/php/5.6/cli/php.ini
sed_configuracao "register_argc_argv = On" "$PHPPATH"
sed_configuracao "post_max_size = 200M" "$PHPPATH"
sed_configuracao "upload_max_filesize = 200M" "$PHPPATH"
sed_configuracao "default_socket_timeout = 60000" "$PHPPATH"
sed_configuracao "max_execution_time = 60000" "$PHPPATH"
sed_configuracao "max_input_time = 60000" "$PHPPATH"
sed_configuracao "memory_limit = 512M" "$PHPPATH"
sed_configuracao "display_errors = Off" "$PHPPATH"
sed_configuracao "log_errors = On" "$PHPPATH"
sed_configuracao "session.gc_maxlifetime = 7200" "$PHPPATH"
sed_configuracao "short_open_tag = On" "$PHPPATH"
sed_configuracao "error_log = /var/log/php/php_errors.log" "$PHPPATH"
sed_configuracao 'date.timezone = "America/Sao_Paulo"' "$PHPPATH"
sed_configuracao "ignore_repeated_errors = On" "$PHPPATH"

PHPPATH=/etc/php/5.6/apache2/php.ini

sed 's,~E_DEPRECATED,~E_NOTICE,g'  /etc/php/5.6/apache2/php.ini > /tmp/php.ini
sed 's,~E_STRICT,~E_DEPRECATED,g'  /tmp/php.ini > /tmp/php2.ini

rm /etc/php/5.6/apache2/php.ini
mv /tmp/php2.ini /etc/php/5.6/apache2/php.ini
chmod 777 /etc/php/5.6/apache2/php.ini

mkdir /var/log/php
touch /var/log/php/php_errors.log
chmod 777 /var/log/php/php_errors.log
touch /var/log/apache2/php_errors.log
chmod 777 /var/log/apache2/php_errors.log
cp /etc/logrotate.d/postgresql-common /etc/logrotate.d/php
sed -i 's/postgresql/php/g' /etc/logrotate.d/php

/etc/init.d/apache2 restart

clear
echo "INSTALANDO LIBREOFFICE"
sleep 2

apt-get --force-yes --yes install libreoffice-writer python3-uno openjdk-8-jre ttf-mscorefonts-installer

clear
echo "CONFIGURANDO LIBREOFFICE"
sleep 2

cat << LIBRE > /etc/init.d/e-cidade_libreoffice-server
#!/bin/bash
### BEGIN INIT INFO
# libreoffice.org headless server script
# Provides:          DBSeller (equipe.infraestrutura)
# Required-Start:   
# Required-Stop:    
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: start/stop/restart libreoffice.org headless server script
### END INIT INFO
OOo_HOME=/usr/bin 
SOFFICE_PATH=\$OOo_HOME/soffice 
PIDFILE=/var/run/e-cidade_libreoffice-server/libreoffice-server.pid 
set -e 
[ -d /var/run/e-cidade_libreoffice-server ] || mkdir -p /var/run/e-cidade_libreoffice-server 
case "\$1" in 
  start) 
    if [ -f \$PIDFILE ]; then 
      echo "LibreOffice headles foi iniciado." 
      sleep 2 
      exit 
    fi 
    echo "Iniciando LibreOffice headless" 
    \$SOFFICE_PATH --headless --nologo --nofirststartwizard --accept="socket,host=127.0.0.1,port=8100;urp" & > /dev/null 2>&1    
    touch \$PIDFILE    
    ;; 
  stop) 
    if [ -f \$PIDFILE ]; then 
      echo "Parando LibreOffice headless." 
      pkill -9 soffice 
     rm -f \$PIDFILE 
      exit 
    fi 
    echo "O LibreOffice headless não está executando." 
    exit 
    ;; 
  restart) 
    /etc/init.d/e-cidade_libreoffice-server stop 
    /etc/init.d/e-cidade_libreoffice-server start 
    exit     
    ;; 
  *) 
    echo "Usage: \$0 {start|stop|restart}" 
    exit 1 
esac 
exit 0
LIBRE

chmod +x /etc/init.d/e-cidade_libreoffice-server
update-rc.d e-cidade_libreoffice-server defaults
/etc/init.d/e-cidade_libreoffice-server start

#faz download do e-cidade
clear
chmod 777 /tmp
chmod 777 /var/www/html
logout
echo "FAZENDO DOWNLOAD DO PACOTE DO E-CIDADE"
sleep 2
ARQUIVO=0
while [[ $ARQUIVO -lt 490904 ]]
do
download_ecidade
if [[ -e /tmp/ecidade.tar.bz2 ]]
then
ARQUIVO=$(du --threshold=M /tmp/ecidade.tar.bz2 | cut -f 1)
else
ARQUIVO=0
fi
if [[ $ARQUIVO -gt 490904 ]]
then
	echo "DOWNLOAD CONCLUIDO"
	break
fi
echo "FALHA AO FAZER DOWNLOAD,COMEÇANDO NOVAMENTE"
ARQUIVO=0
rm -rf /tmp/ecidade.tar.bz2
done

#configurando servidor
clear
echo "CONFIGURANDO SERVIDOR"
sleep 2

clear
echo "AJUSTANDO PERMISSÕES NA CRIAÇÃO DE ARQUIVOS"
sleep 2
#configura permissoes na criaçao de arquivo
sudo sed -i 's/UMASK[ \t]*[0-9]*$/UMASK\t\t002/g' /etc/login.defs

#no segundo arquivo
chmod 777  /etc/apache2/envvars
echo "umask 002" >> /etc/apache2/envvars


clear
echo "EXTRAINDO PACOTE DO E-CIDADE"
sleep 2
sudo chmod 777 /var/www/html
cd /tmp
tar -jxvf /tmp/ecidade.tar.bz2
FOLDER=$(ls | grep e-cidade)
sudo mv /tmp/${FOLDER}/e-cidade /var/www/html/e-cidade


clear
echo "CONFIGURANDO O E-CIDADE"
sleep 2

sudo cat << ECID > /var/www/html/e-cidade/libs/db_conn.php
<?php
\$DB_COR_FUNDO = "#00CCFF";
\$DB_FILES     = "/dbportal2/imagens/files";
\$DB_DIRPCB    = "/home/sistema";
\$DB_EXEC      = "/usr/bin/dbs";
\$DB_NETSTAT   = "netstat";

\$DB_SERVIDOR  = "localhost";
\$DB_PORTA     = "5432";
\$DB_PORTA_ALT = "5432";
\$DB_BASE      = "ecidade";
\$DB_USUARIO   = "ecidade";
\$DB_SENHA     = "ecidade";
\$DB_SELLER    = "";
\$DB_VALIDA_REQUISITOS = false; 
\$lUtilizaCaptcha = false; 
?>

ECID

# configurando os plugins do e-cidade

sudo cat << ECIDPLG > /var/www/html/e-cidade/config/plugins.json
{
  "AcessoBase" : {
    "usuario" : "plugin",
    "senha" : "plugin"
  }
}
ECIDPLG

#criando arquivo de e-mail
sudo cp /var/www/html/e-cidade/libs/config.mail.php.dist /var/www/html/e-cidade/libs/config.mail.php
sudo cp /var/www/html/e-cidade/config/require_extensions.xml.dist /var/www/html/e-cidade/config/require_extensions.xml
sudo chown -R www-data. /var/www/html/e-cidade
sudo chmod -R 775 /var/www/html/e-cidade
sudo chmod -R 777 /var/www/html/e-cidade/tmp

while read -r -t 0; do read -r; done

clear
echo "INSTALACAO CONCLUIDA, CRIADO DATABASE ecidade VAZIA, DESEJA RESTAURAR ALGUM CONTEUDO NESTA BASE?"
echo "0 - NAO RESTAURAR"
echo "1 - RESTAURAR BASE SCHEMA"
echo "2 - RESTAURAR BASE DEMO"
read -p "SELECIONE OPÇAO E PRESSIONE ENTER! " OPC

case "$OPC" in
    1)
      psql -U ecidade -d ecidade -f /tmp/${FOLDER}/sql/schema.sql
      psql -U ecidade -d ecidade -c "VACUUM ANALYZE VERBOSE"
      clear
    ;;
    2)
      psql -U ecidade -d ecidade -f /tmp/${FOLDER}/sql/demo.sql
      psql -U ecidade -d ecidade -c "VACUUM ANALYZE VERBOSE"
      clear
    ;;
    *)
      echo "NAO FOI FEITO RESTORE ALGUM!"
      sleep 2
    ;;  

esac


sudo chown -R www-data. /var/www/html/e-cidade
sudo chmod -R 775 /var/www/html/e-cidade
sudo chmod -R 777 /var/www/html/e-cidade/tmp
sudo chmod -R 777 /var/www/html/e-cidade/config/require_extensions.xml
sudo mv /var/www/html/index.html /var/www/html/index.html.old

sudo cat << INDEX > /var/www/html/index.html
<html>
<head>
<title>E-cidade</title>
<meta http-equiv="refresh" content="0;URL=e-cidade" />
</head>
<body>
</body>
</html>

INDEX

clear
echo "CONFIGURANDO O E-CIDADEONLINE"

#copiando pacote
sudo mv /tmp/${FOLDER}/e-cidadeonline /var/www/html/e-cidadeonline

sudo cat << ECIDON > /var/www/html/e-cidadeonline/libs/db_conn.php
<?php
\$DB_INSTITUICAO = "1";
\$DB_SERVIDOR="localhost";
\$DB_BASEDADOS = "ecidade";
\$DB_USUARIO="ecidade";
\$DB_SENHA="ecidade";
\$DB_PORTA="5432";
global \$configsite;
\$configsite = "";
ini_set("error_reporting","E_ALL & ~NOTICE");
?>
ECIDON

sudo cp /var/www/html/e-cidadeonline/libs/config.mail.php.dist /var/www/html/e-cidadeonline/libs/config.mail.php

sudo chown -R www-data. /var/www/html/e-cidadeonline
sudo chmod -R 775 /var/www/html/e-cidadeonline
sudo chmod -R 777 /var/www/html/e-cidadeonline/tmp

#configura rotação de logs
clear
echo "CONFIGURANDO ROTAÇÃO DE LOGS"
sudo mkdir /var/www/html/e-cidade/integracao_externa/auditoria/log
sudo chmod -R 777 /var/www/html/e-cidade/integracao_externa/auditoria/log

clear
echo "REINICIANDO POSTGRESQL"
sudo /etc/init.d/postgresql restart
sleep 10
clear

echo "INSTALACAO TERMINADA,USUARIO:dbseller SENHA:deixar em branco,ACESSE ATRAVÉS DE SEU NAVEGADOR WEB EM http://$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1)/e-cidade MAIS DÚVIDAS ENVIAR E-MAIL PARA suporte@dbseller.com.br"
