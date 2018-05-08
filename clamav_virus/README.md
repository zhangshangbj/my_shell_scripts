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
