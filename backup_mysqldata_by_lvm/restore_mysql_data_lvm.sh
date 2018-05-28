#!/bin/bash
#********************************************************************
#encoding  -*-utf8-*-
#Author:        zhangshang
#URL:         http://blog.vservices.top/myblog
#Description：    To backup mysql databases
#QQ Numbers: 765030447
#********************************************************************
ARGV=`getopt -o d:b:h -l dbpath:,backpath:,help  -n test.sh -- "$@"`
eval set --"$ARGV"
while true
do
    case "$1" in
    -d|--dbpath)
    dbpath="$2"
        shift
        ;;
    -b|--backpath)
    backpath="$2"
        shift
        ;;
    -h|--help)
    echo "
This tool can helps you to restore your databases which located on the LVM
-d|--dbpath : The real path of databases;
-b|--backpath : The backup directory
-h|--help : It helps you to use this tool!
"
    exit 0
#       shift
        ;;
    --)
        shift
    break
        ;;
    *) 
    echo "Internal error!" ; 
        echo "
This tool can helps you to restore your databases which located on the LVM
-d|--dbpath : The real path of databases;
-b|--backpath : The backup directory
-h|--help : It helps you to use this tool!
"
        exit 0
    ;;
    esac
shift
done


#Mysql's configuration
dbport='3306'
dbpasswd='123123'
#dbsock='/var/lib/mysql.sock'
dbuser='root'
#db_run_cmd="mysql -u$dbuser -p$dbpasswd -S $dbsock -e "
db_run_cmd="mysql -u$dbuser -p$dbpasswd -P $dbport -e"
db_start_cmd=""
db_stop_cmd=""
stop_iptables=""

function test_argments(){
    [ -z $1 ]
}

test_argments $dbpath && dbpath='/var/lib/mysql'
test_argments $backpath && backpath='/backup'
test_argments $db_start_cmd && db_start_cmd='systemctl start mysqld'
test_argments $db_stop_cmd && db_stop_cmd='systemctl stop mysqld'


#Test the dbpath
function test_dbpath(){
    local i=''
    local count=0
    for i in `ls -l $1 | grep '^d' | awk '{print $9}'`
    do
        [ "$i" == 'mysql' ] && let count+=1
        [ "$i" == 'performance_schema' ] && let count+=1
    done
    [ "$count" -lt 2 ] && echo "There have not db_datas!" && exit 1
}

test_dbpath $dbpath
test_dbpath $backpath



function restore_db(){
    eval $db_stop_cmd
    [ $? -ne 0 ] &&  echo -e "\033[31mStop failed!\033[0m" && exit 1
    [ -z "$dbpath" ] && echo -e "\033[31mThe dbpath is null,do notiong!\033[0m" && exit 1
    rm -rf $dbpath/*
    cd $backpath
    ls | grep -v 'gz$' | xargs -i /usr/bin/cp -ra {} $dbpath
    iptables -A INPUT -p tcp --dport $dbport -j DROP
    eval $db_start_cmd
    eval $db_run_cmd '"set sql_log_bin=0"'
    echo ''
    echo -e "\033[31mHas banned mysql client to connect to the server, do not forget to use 
\033[0m\033[32m\"iptables -D INPUT -p tcp --dport $dbport -j DROP\"\033[0m\033[31mto delete the firewall rules\033[0m"
    echo ''
    echo -e "\033[31mdo not forget to up the binlog saveing! You can use the command 
\033[0m\033[32m\"$db_run_cmd set sql_log_bin=1\"\033[0m\033[31m to up it! Don't forget!\033[0m"
}

restore_db
