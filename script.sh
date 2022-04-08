#!/bin/bash

#
# nodemgr Oracle Weblogic all services unified
# chkconfig: 345 85 15
# description: Oracle Weblogic all services unified
### BEGIN INIT INFO
# Provides: weblogic.sh
# Required-Start: $network $local_fs
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
# Short-Description: Oracle Weblogic all services unified.
# Description: Starts and stops Oracle Weblogic all services unified.
### END INIT INFO

########################################################################################
##@Brief Weblogic all services start / stop script.
##@Author: Emilio Granados
##@Ver 1.4 Implementacion inicial.
##@POST:
## Error codes:
## 0 - OK
## 1 - Don't exist param file
## 2 - User incorrect
## 3 - Don't exists Weblogic nodemanager.sh script
## 4 - Don't exists Weblogic adminserver.sh script
## 5 - Don't exists Weblogic instances.sh script
## 6 - Error in the script execution - Weblogic component.
#######################################################################################

## Fichero con los parametros de configuracion
##################################################################
CONF_FILE="/etc/weblogic.opt"

## Fichero de arranque para HP Diagnostics
###################################################################
hpdiag=0

## Retorno de la ejecucion
###################################################################
retcode=0

## Constantes
###################################################################
SERVICE_NAME=`/bin/basename $0`
fec1=`date "+%Y-%m-%d %H:%M:%S"`
fec2=`date "+%Y-%m-%d"`

## Funcion status
##################################################################
function status()
{
	echo
	echo "`hostname` ${fec1}: Status All services Weblogic: "
	echo

	if [ -f /tmp/hpdiag.lock ]; then
		echo "HP Diagnostics is ENABLE."
	else
		echo "HP Diagnostics is DISABLE."
	fi

	$SCRIPT_RUT/nodemanager.sh status
	if [[ $ISADMIN == [Ss] ]]; then
		$SCRIPT_RUT/adminserver.sh status
	fi
	$SCRIPT_RUT/instances.sh status
	echo
	retcode=0
}

## Funcion de arranque
###################################################################
function start() 
{
	echo >> ${LOGWEB_START}
	echo "----------------------------------------------------------------" >> ${LOGWEB_START} 
	echo "`hostname` ${fec1}: Starting All Weblogic components:" | tee -a ${LOGWEB_START} 
	echo "Generating log at ${LOGWEB_START}" | tee -a ${LOGWEB_START}

	if [ $hpdiag -eq 1 ]; then
		echo | tee -a ${LOGWEB_START}
		echo "Enable HP Diagnostics ..."
		echo | tee -a ${LOGWEB_START}
		touch /tmp/hpdiag.lock
		if [ $? -ne 0 ]; then
			echo "ERROR: Can not enable HP Diagnostics. Can not create /tmp/hpdiag.lock." | tee -a ${LOGWEB_START}
		else
			\chown orawls:oinstall /tmp/hpdiag.lock
		fi
	else
		if [ -f /tmp/hpdiag.lock ]; then
			\rm -f /tmp/hpdiag.lock
		fi
	fi

	echo | tee -a ${LOGWEB_START}
	echo "`date +"%H:%M:%S"`: Starting Nodemanager component ... " | tee -a ${LOGWEB_START}
	$SCRIPT_RUT/nodemanager.sh start
	retcodeN=$?
	if [ $retcodeN -ne 0 ]; then
		echo "ERROR: Can not start nodemanager component" | tee -a ${LOGWEB_START}
		echo "ABORT WEBLOGIC STARTUP - You must review nodemanager LOG to determine problem !!" | tee -a ${LOGWEB_START}
		exit $retcodeN
	fi

	if [[ $ISADMIN == [Ss] ]]; then 
		echo | tee -a ${LOGWEB_START}
		echo "`date +"%H:%M:%S"`: Starting AdminServer component ... " | tee -a ${LOGWEB_START}
		$SCRIPT_RUT/adminserver.sh start
		retcodeA=$?
		if [ $retcodeA -ne 0 ]; then
			echo "ERROR: Can not start adminserver component" | tee -a ${LOGWEB_START}
			echo "ABORT AdminServer STARTUP - You must review adminserver LOG to determine problem !!" | tee -a ${LOGWEB_START}
		fi
	fi
	
	echo | tee -a ${LOGWEB_START}
	echo "`date +"%H:%M:%S"`: Starting Instances component ... " | tee -a ${LOGWEB_START}
	##
	## Por desgracia, no podemos controlar el tiempo que tarda en arrancar una instacia, asi que lo unico
	## que podemos hacer es lanzar en segundo plano para NO INTERRUMPIR AL SYSV DEL SO.
	$SCRIPT_RUT/instances.sh start ${INSTANCES} &
	retcodeI=$?
	if [ $retcodeI -ne 0 ]; then
		echo "ERROR: Can not start instances component" | tee -a ${LOGWEB_START}
		echo "ABORT STARTUP - You must review instances LOG to determine problem !!" | tee -a ${LOGWEB_START}
	fi

	let retcode=$retcodeN+$retcodeA+$retcodeI
	if [ $retcode -eq 0 ]; then
		echo "OK: All Weblogic components started." | tee -a ${LOGWEB_START}
	else
		echo "FAIL: Some Weblogic components don't start."
	fi
}
		
## Funcion stop
####################################################################
function stop() 
{
	retcode=0
	echo | tee -a ${LOGWEB_STOP}
	echo "----------------------------------------------------------------------------------" | tee -a ${LOGWEB_STOP}
	echo "`hostname` ${fec1}: Stopping All Weblogic components:" | tee -a ${LOGWEB_STOP} 
	echo "Generating log at ${LOGWEB_STOP}" | tee -a ${LOGWEB_STOP}
	
	echo | tee -a ${LOGWEB_STOP}
	echo "`date +"%H:%M:%S"`: Stopping Instances ... " | tee -a ${LOGWEB_STOP}
        $SCRIPT_RUT/instances.sh stop ${INSTANCES}
	retcodeI=$?
        if [ $retcodeI -ne 0 ]; then
                echo "ERROR: Can not stop instances component" | tee -a ${LOGWEB_STOP}
                echo "You must review instances LOG to determine problem !!" | tee -a ${LOGWEB_STOP}
                echo "Continue with next service ..." | tee -a ${LOGWEB_STOP} 
	fi

	if [[ $ISADMIN == [Ss] ]]; then
        	echo | tee -a ${LOGWEB_STOP}
		echo "`date +"%H:%M:%S"`: Stopping AdminServer ... " | tee -a ${LOGWEB_STOP}
        	$SCRIPT_RUT/adminserver.sh stop
		retcodeA=$?
        	if [ $retcodeA -ne 0 ]; then
                	echo "ERROR: Can not stop adminserver component" | tee -a ${LOGWEB_STOP}
                	echo "You must review adminserver LOG to determine problem !!" | tee -a ${LOGWEB_STOP}
                	echo "Continue with next service ..." | tee -a ${LOGWEB_STOP}
		fi
	fi
	
	echo | tee -a ${LOGWEB_STOP}
	echo "`date +"%H:%M:%S"`: Stopping Nodemanager ... "  | tee -a ${LOGWEB_STOP}
        $SCRIPT_RUT/nodemanager.sh stop
	retcodeN=$?
        if [ $retcodeN -ne 0 ]; then
               	echo "ERROR: Can not stop nodemanager component" | tee -a ${LOGWEB_STOP}
               	echo "You must review nodemanager LOG to determine problem !!" | tee -a ${LOGWEB_STOP}
               	echo "Continue with next service ..." | tee -a ${LOGWEB_STOP}
	fi

	let retcode=$retcodeA+$retcodeN+$retcodeI
	if [ ! -z "`ps -ef | grep orawls | grep -i java | grep -v grep | awk '{ print $2; }'`" ]; then
		echo | tee -a ${LOGWEB_STOP}
		echo "*** FORCE TO STOP UNSTABLE COMPONENTS FROM OS ***" | tee -a ${LOGWEB_STOP}
		for i in $(ps -ef | grep orawls | grep -i java | grep -v grep | awk '{ print $2; }'); do kill -15 $i; done
		echo "PROCESS REMAINING: `ps -ef | grep orawls | grep -i java | grep -v grep`" | tee -a ${LOGWEB_STOP}
		echo | tee -a ${LOGWEB_STOP}
	fi
	
	if [ -e /tmp/hpdiag.lock ]; then
		\rm -f /tmp/hpdiag.lock &> /dev/null
	fi
	
	echo | tee -a ${LOGWEB_STOP}
	if [ $retcode -eq 0 ]; then
		echo "OK: All Weblogic components stopped." | tee -a ${LOGWEB_STOP} 
	else
		echo "ERROR: Some Weblogic components stopped with error" | tee -a ${LOGWEB_STOP}
	fi
}

## Main
#####################################################################

# Comprobamos usuario de ejecucion
if [ `id -u` -ne 0 ] && [ "`id -un`" != "orawls" ]; then
	echo "ERROR: User `id -un` incorrect, only root or orawls."
	exit 1
fi

# Cargamos la opcion de entrada
nom=`basename $0 | cut -f1 -d. | awk '{ print tolower($0); }'`
if [ "$nom" == "start" ] || [ "$nom" == "stop" ]; then
	opt="$nom"
	if [ ! -z "$1" ]; then
                val=`echo $1 | awk '{ print tolower($0); }'`
                if [ "$val" == "hpdiag" ]; then
                        hpdiag=1
                else
                        hpdiag=0
                fi
        fi
else
	if [ -z "$1" ]; then
		echo
		echo "`basename $0` usage: < start | stop | restart | status >"
		echo
		exit 1
	fi

	opt=`echo $1 | awk '{ print tolower($0); }'`
	
	if [ ! -z "$2" ]; then
                val=`echo $2 | awk '{ print tolower($0); }'`
                if [ "$val" == "hpdiag" ]; then
                        hpdiag=1
                else
                        hpdiag=0
                fi
        fi
fi

# Buscamos el fichero de parametros
if [ ! -f $CONF_FILE ]; then
	echo "ERROR: Don't exists needed param file $CONF_FILE"
	exit 2
else
	source $CONF_FILE
fi

##
########################### Logs para la salida de nohup
LOGWEB_START="${RUTLOG}/start_nohup_weblogic_${fec2}.log"
LOGWEB_STOP="${RUTLOG}/stop_nohup_weblogic_${fec2}.log"
# Procesamos los ficheros de logs
if [ ! -f ${LOGWEB_START} ]; then
        touch ${LOGWEB_START}
fi

if [ ! -f ${LOGWEB_STOP} ]; then
        touch ${LOGWEB_STOP}
fi
chown orawls:oinstall ${LOGWEB_START} &> /dev/null
chown orawls:oinstall ${LOGWEB_STOP} &> /dev/null

# Seleccion de la opcion operativa
case "$opt" in
	'start')	start
			;;

	'stop')		stop
			;;

	'restart')	stop
			sleep 2
			start
			;;
	
	'status')	status
			;;

	*)		echo "`basename $0` usage: < start | stop | restart | status >"
			;;
esac
exit $retcode

