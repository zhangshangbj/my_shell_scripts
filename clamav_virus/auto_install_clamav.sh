#!/bin/bash
#
#********************************************************************
#Author:          zhangshang
#Date:            2018-05-08
#URL:             http://blog.vservices.top/myblog
#Description：    自动安装clamav
#Copyright (C):   2018 All rights reserved
#********************************************************************
###
# 
###

declare -a needed_rpm
needed_rpm=(
"gcc" 
"zlib" 
"zlib-devel"
)
prefix='/app'
datadir='/data'
zlib_ver='zlib-1.2.11.tar.xz'
clamAV_ver='clamav-0.100.0.tar.gz'

function test_rpm_packeges(){
    count=0
    declare -a PACKAGES
    local rpm=$1
    for i in ${rpm[@]}
    do
        install_stats=rpm -qa $i | wc -l
	if [ $install_stats -eq 0 ]
	    then
	    echo "$1 is not installed."
	    PACKEGES[$count]=$i
	    let count+=1
	fi
    done
}

function install_rpm_packeges(){
    local pkg=$1
    for i in ${pkg[@]}
    do
        yum install $i -y 1>/dev/null
    done
}

function install_zlib(){
    cd ./packeges
    tar -xf $zlib_ver
    cd zlib-1.2.11
    ./configure --prefix=$prefix/zlib 1>/dev/null
    make 1>/dev/null && make install 1>/dev/null
    cd ..
    rm -rf zlib-1.2.11
    cd ..
}

function install_clamav(){
    groupadd clamav
    useradd -g clamav -s /bin/false -c "Clam AntiVirus" clamav
    cd ./packeges
    tar -xf $clamAV_ver
    cd clamav-0.100.0
    ./configure --prefix=$prefix/clamav --disable-clamav --with-zlib=$prefix/zlib 1>/dev/null
    make 1>/dev/null && make install 1>/dev/null
}

function setup_clamav_conf(){
      sed -i 's/^Example/#Example/g' $prefix/clamav/etc/clamd.conf.sample
      sed -i 's/^Example/#Example/g' $prefix/clamav/etc/freshclam.conf.sample
      mkdir -p $datadir/clamav/logs
      mkdir -p $datadir/clamav/updata
      touch $datadir/clamav/logs/freshclam.log
      touch $datadir/clamav/logs/clamd.log
      chown -R clamav:clamav $datadir/clamav
      chown -R clamav.clamav $prefix/clamav
      cp $prefix/clamav/etc/clamd.conf.sample $prefix/clamav/etc/clamd.conf
      cp $prefix/clamav/etc/freshclam.conf.sample $prefix/clamav/etc/freshclam.conf
      echo "
LogFile $prefix/clamav/logs/clamd.log
PidFile $datadir/clamav/updata/clamd.pid
DatabaseDirectory $datadir/clamav/updata/clamav
#tag_old
      " >>/$prefix/clamav/etc/clamd.conf

      #更新数据库
      mkdir -p $prefix/clamav/share/clamav
      chown -R clamav.clamav $prefix/clamav 
      $prefix/clamav/bin/freshclam
}

test_rpm_packeges $need_rpm
install_rpm_packeges $PACKEGES
install_zlib
install_clamav
setup_clamav_conf
