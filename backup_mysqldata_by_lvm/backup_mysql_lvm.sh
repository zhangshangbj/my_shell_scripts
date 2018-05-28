#!/bin/bash
#********************************************************************
#encoding  -*-utf8-*-
#Author:        zhangshang
#URL:         http://blog.vservices.top/myblog
#Description：    To backup mysql databases
#QQ Numbers: 765030447
#********************************************************************

ARGV=`getopt -o d:b:l:v:h -l dbpath:,backpath:,dblvm:,dbvg:,help,binlog:  -n test.sh -- "$@"`
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
    -l|--dblvm)
    dblvm="$2"
        shift
        ;;
    -v|--dbvg)
    dbvg="$2"
        shift
        ;;
    --binlog)
    binlog="$2"
    shift
    ;;
    -h|--help)
    echo "
This tool can helps you to backup your databases which located on the LVM


-d|--dbpath : The path of databases;
-b|--backpath : The backup directory 
-l|--dblvm : The lvm name of which your databases's locate
-v|--dbvg : Filling out your vg's name which your database located
--binlog : Tar a packege of binlog
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
This tool can helps you to backup your databases which located on the LVM


-d|--dbpath : The path of databases;
-b|--backpath : The backup directory 
-l|--dblvm : The lvm name of which your databases's locate
-v|--dbvg : Filling out your vg's name which your database located
--binlog : Tar a packege of binlog
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
current_data=`date +%F`

#Test the given options's values
function test_argments(){
    [ -z $1 ]
}

test_argments $dbpath && dbpath='/var/lib/mysql'
test_argments $backpath && backpath='/backup'
test_argments $dblvm && dblvm='dblvm'
test_argments $dbvg && dbvg='dbvg'

#Test the dbpath
function test_dbpath(){
    local i=''
    local count=0
    for i in `ls -l $dbpath | grep '^d' | awk '{print $9}'`
    do
        [ "$i" == 'mysql' ] && let count+=1
        [ "$i" == 'performance_schema' ] && let count+=1
    done
    [ "$count" -lt 2 ] && echo 'There not a dbpath!' && exit 1
}

test_dbpath

#Create a snapshot
function mk_snapshot(){
    eval $db_run_cmd '"FLUSH TABLES WITH READ LOCK;"'
    [ $? -ne 0 ] && { echo 'Lock tables failed!' ; exit 1; }
    eval $db_run_cmd '"show binary logs" | tail -n 1 > /$backpath/binlog_position'
    lvcreate -n sql_data_snapshot -L 2G -s -p r /dev/$dbvg/$dblvm &>/dev/null
    [ $? -ne 0 ] && echo -e "\033[31msql_data_snapshot already exists! It's meaning that previous copy wasn't completed\033[0m" && exit 1
    eval $db_run_cmd '"flush logs;"'
    eval $db_run_cmd '"unlock tables;"'
}

#Backup the dbdate
function bk_db(){
    mkdir -p $backpath &>/dev/null
    mkdir -p /snapshot_tmp &>/dev/null
    mount -o nouuid,norecovery /dev/$dbvg/$dblvm /snapshot_tmp/ &>/dev/null
    [ $? -ne 0 ] &&  echo 'mount error!' && exit 1
    /usr/bin/cp -ra /snapshot_tmp /backup/mariadb_backup.$current_data
    [ $? -ne 0 ] && echo "\033[31mCopying failed! Please check the harddisk-room. Cleaning the copy-data!\033[0m" && rm -rf /backup/mariadb_backup.$current_data && state=1
    umount /snapshot_tmp
    [ $? -ne 0 ] && echo 'Umount error !'
    cd / && rm -rf /snapshot_tmp
}

#Remove the snapshot
function rm_snapshot(){
    [ -n "$state" ]  && echo -e "\033[31mThe databases's snapshot has't been remove! Don't forget to use this command \033[0m\033[32m\`lvremove -y /dev/$dbvg/sql_data_snapshot \`\033[0m\033[31m to remove it! \033[0m" && exit 1
    lvremove -y /dev/$dbvg/sql_data_snapshot 1>/dev/null
}

#Copy the position-file to backup path
function cp_positon_file(){
    /usr/bin/cp $backpath/binlog_position $backpath/mariadb_backup.$current_data/
}

#Backup the binlog
function tar_binlog(){
    cd $binlog
    echo -e "\033[31mAs you need ,you can modify the regex!\033[0m"
    ls | grep '.*bin\.[[:digit:]]\{6\}$' | xargs tar cvzf $backpath/mariadb_backup.$current_data/binlog.$current_data.tar.gz 1>/dev/null
    [ $? -ne 0 ] &&  echo '\033[31mCopying failed! Please check the harddisk-room. Cleaning the copy-binlog-data!\033[0m' && rm -rf $backpath/mariadb_backup.$current_data/binlog.$current_data.tar.gz && exit 1
}

#Begin to starting backup
mk_snapshot
bk_db
rm_snapshot
cp_positon_file
if [ -n "$binlog" ]
    then
    tar_binlog
fi
