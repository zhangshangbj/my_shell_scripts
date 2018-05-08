# auto_install_clamav.sh脚本
这个脚本是用来自动安装clamAV检测程序的
可以通过设定内部变量来达到你的要求
```
prefix='/app'                       #默认安装位置
datadir='/data'                     #数据存放位置
```

clamAV依赖zlib包，yum安装的zlib-devel会报错，未排查，直接使用源码安装，将zlib最新版本的源码包房贷“packeges”目录下，脚本会自动读取
```
zlib_ver='zlib-1.2.11.tar.xz'
```

clamAV源码包，可以从[ClamAV官网获得](https://www.clamav.net/downloads)
```
clamAV_ver='clamav-0.100.0.tar.gz'
```
# scan_clamav.sh 脚本
这个脚本是使用clamav扫描你指定的目录并将结果保存到你指定的目录

user_dir 用来定义你要扫描的目录
```
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
```
```
clam_bin='/app/clamav/bin/'     #你的可执行程序目录
clam_cmd='clamscan -r'          #你的执行命令，默认即可
result_dir=''                   #扫描结果存放目录（如定义的目录默认没有会自动创建）
```
