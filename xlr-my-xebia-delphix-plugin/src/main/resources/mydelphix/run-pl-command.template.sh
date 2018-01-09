#!/bin/bash
#description     :This script will mange some of vdb action's (enable,disable, delete,refresh,snapsync,start,stop)
# more to come
#author		     :Mouhssine SAIDI - MOUSS
#date            :20150303
#version         :0.2    
#usage		     :sh mkscript.sh <VDB_NAME> <ACTION>
#bash_version    :0.2-release
#==============================================================================
#PUT HERE YOUR DELPHIX ENGIE IP
DE="192.168.247.132"
#DELPHIX ADMIN ACCOUNT
DELPHIX_ADMIN="delphix_admin"
#DELPHIX ADMIN PASSWORD 
DELPHIX_PASS="landshark"

VDB=$1
OPT=$2
get_session() {
curl -s -X POST -k --data @- http://${DE}/resources/json/delphix/session \
    -c ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "APISession",
    "version": {
        "type": "APIVersion",
        "major": 1,
        "minor": 8,
        "micro": 2
    }
}
EOF
}

do_login() {
curl -s -X POST -k --data @- http://${DE}/resources/json/delphix/login \
    -b ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "LoginRequest",
    "username": "${DELPHIX_ADMIN}",
    "password": "${DELPHIX_PASS}"
}
EOF
}

get_params() {
ref=`curl -s -X GET -k http://${DE}/resources/json/delphix/database  \
    -b ~/cookies.txt -H "Content-Type: application/json" | python -m json.tool | jq -r '.result[] | select(.name=="'$VDB'") | .reference'`
cont=`curl -s -X GET -k http://${DE}/resources/json/delphix/database  \
    -b ~/cookies.txt -H "Content-Type: application/json" | python -m json.tool | jq -r '.result[] | select(.name=="'$VDB'") | .provisionContainer'`
vsrc=`curl -s -X GET -k http://${DE}/resources/json/delphix/source  \
    -b ~/cookies.txt -H "Content-Type: application/json" | python -m json.tool | jq -r '.result[] | select(.name=="'$VDB'") | .reference'`
}

do_refresh() {
curl -s -X POST -k --data @- http://${DE}/resources/json/delphix/database/$ref/refresh  \
    -b ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
       "type": "OracleRefreshParameters",
       "timeflowPointParameters": {
               "type": "TimeflowPointSemantic",
               "container": "$cont",
               "location": "LATEST_SNAPSHOT"
       }
}

EOF
}

do_snapsync() {
curl -s -X POST -k --data @- http://${DE}/resources/json/delphix/database/$ref/sync  \
    -b ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
       "type": "OracleSyncParameters"
}

EOF
}

do_start() {
  curl -s -X POST -k http://${DE}/resources/json/delphix/source/${vsrc}/start \
    -b ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "OracleStartParameters"
}

EOF
}

do_stop() {
  curl -s -X POST -k http://${DE}/resources/json/delphix/source/${vsrc}/stop \
    -b ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "OracleStopParameters"
}

EOF
}

do_delete() {
  curl -s -X POST -k http://${DE}/resources/json/delphix/database/$ref/delete \
    -b ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "OraclDeleteeParameters"
}

EOF
}

do_enable() {
  curl -s -X POST -k http://${DE}/resources/json/delphix/source/${vsrc}/enable \
    -b ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "OracleEnableParameters"
}

EOF
}

do_disable() {
  curl -s -X POST -k http://${DE}/resources/json/delphix/source/${vsrc}/disable \
    -b ~/cookies.txt -H "Content-Type: application/json" <<EOF
{
    "type": "OracleDisableParameters"
}

EOF
}

get_session
do_login
get_params
case $OPT in
start)
do_start
;;
stop)
do_stop
;;
refresh)
do_refresh
;;
snapsync)
do_snapsync
;;
delete)
do_delete
;;
enable)
do_enable
;;
disable)
do_disable
;;
*)
  echo "Unknown option: $OPT"
;;
esac

do_logout() {
curl -s -X POST -k --data @- http://${DE}/resources/json/delphix/logout \
    -b ~/cookies.txt -H "Content-Type: application/json"
}
