#!/bin/bash
LISTA=(
    'ZY.1.2.3 Logging' 
    'ZY.1.2.4 Logging'
    'ZY.1.4.5 System Settings'
    'ZY.1.4.7 System Settings'
)
#function checkeo(){
    # while true; do
    #     echo "Checking for .... "
    # done
function ZY.1.2.3(){
    value=$(ls -la /etc/profile.d/secondary_logging_IBM.sh 2>&1)
    if [[ "$value" == *"No such"* ]]; then
        resultado_ZY123="NO"
        message_ZY123="No existe el fichero de secondary_loggin"
        echo -e "Checking for \e[33mZY.1.2.3 Logging ....\e[0m $resultado_ZY123 : '$message_ZY123'"
    else
        resultado_ZY123="YES"
        message_ZY123=""
        echo -e "Checking for \e[33mZY.1.2.3 Logging ....\e[0m $resultado_ZY123 : '$message_ZY123'"
    fi
}
function ZY.1.2.4(){
    value=$(ls -la /etc/logrotate.conf 2>&1)
    if [[ "$value" == *"No such"* ]]; then
        resultado_ZY124="NO"
        message_ZY124="No existe el fichero de /etc/logrotate.conf"
        echo -e "Checking for \e[33mZY.1.2.4 Logging ....\e[0m $resultado_ZY124 : '$message_ZY124'"
    else
        resultado_ZY124="YES"
        message_ZY124=""
        echo -e "Checking for \e[33mZY.1.2.4 Logging ....\e[0m $resultado_ZY124 : '$message_ZY124'"
    fi
}
function ZY.1.2.5(){
    value=$(ls -la /etc/sudoers 2>&1)
    if [[ "$value" == *"No such"* ]]; then
        resultado_ZY125="NO"
        message_ZY125="No existe el fichero de /etc/sudoers"
        echo -e "Checking for \e[33mZY.1.4.5 System Settings ....\e[0m $resultado_ZY125 : '$message_ZY125'"
    else
        resultado_ZY125="YES"
        message_ZY125=""
        echo -e "Checking for \e[33mZY.1.4.5 System Settings ....\e[0m $resultado_ZY125 : '$message_ZY125'"
    fi
}
clear
echo -e "\e[32m----------------------------INICIO----------------------------\e[0m"
sleep 0.5s    
ZY.1.2.3
sleep 0.5s    
ZY.1.2.4
sleep 0.5s    
ZY.1.2.5
echo -e "\e[31m-----------------------------FIN------------------------------\e[0m"
# for var in "${LISTA[@]}"
# do
#     sleep 0.5s    
#     if [[ $var == "ZY.1.2.3 Logging" ]]; then
#         echo "Checking for $var .... $resultado_ZY123 : '$message_ZY123'"
#     fi
#     sleep 0.5s    
#     if [[ $var == "ZY.1.2.4 Logging" ]]; then
#         echo "Checking for $var .... $resultado_ZY124 : '$message_ZY124'"
#     fi
#     sleep 0.5s
#     if [[ $var == "ZY.1.4.5 System Settings" ]]; then
#         echo "Checking for $var .... $resultado_ZY125 : '$message_ZY125'"
#     fi
# done

#}
