#! /bin/bash
#
#********************************************************************
#Author:          zhangshang
#Date:            2018-05-08
#URL:             http://blog.vservices.top/myblog
#Description：    Linux 下扫描挂马目录依赖于clamAV
#Copyright (C):   2018 All rights reserved
#********************************************************************
###
# 这个脚本可以使用clamAV扫描你所指定的所有目录下的文件
# 在user_dir下定义你要扫描的目录
# clam_bin变量定义了你要指定的clamAV可执行程序目录
# clam_cmd变量定义了你要执行的命令
# result_dir变量定义了，你要将结果保存到何处，默认空值为"/tmp"
###
declare -a user_dir
user_dir=(
'/usr/bin'
'/usr/sbin'
'/bin'
'/sbin'
'/init.d/'
'/rc.d/'
'/usr/java/default/bin'
'/usr/java/bin'
'/usr/local/bin'
'/usr/local/sbin'
'/home/'
'/root/'
)
clam_bin='/app/clamav/bin/'
clam_cmd='clamscan -r'
result_dir=''

#搜索指定目录
function scan_dir(){
[ -d "$result_dir" ] || result_dir='/tmp'
base_dir="$result_dir/clam_`date '+%F_%H_%M'`"
[ -d $base_dir ] && echo 'Please wait 1 minute.' && exit 1 || mkdir $base_dir
for i in ${user_dir[@]}
	do
	sub_file=${i//\//_}
	env_data_file=$base_dir/$sub_file
	virus_file=$base_dir/Virus$sub_file
	$clam_bin$clam_cmd $i 2>/dev/null 1>$env_data_file
	virus_count=`cat $env_data_file | grep 'FOUND'  | wc -l`
	[ $virus_count -ne 0 ] && echo "\033[31mWarning $sub_file had viruses.\033[0m" && cat $env_data_file | grep 'FOUND' >$virus_file
	done
}

#扫描并输出结果
scan_dir
