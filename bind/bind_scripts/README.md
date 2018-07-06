### 脚本位置
脚本名为update_dns.sh,位192.168.1.43机器的"/app/bind9/bin/"下

### 使用方法
```shell
[root@localhost ~]# ./update_dns.sh 
usage ./update_dns.sh 
-m | --method (add|delete)      #添加偶删除记录
-d | --domain_name domain_name  #域名
-c | --class ( A | AAAA | NS | default:A ) #记录类型 
-i | --data ( ip|domain_name )  #数据，一般为ip
-z | --zone zone_name 显示zone记录 #显示指定zone区的记录
```
### 使用范例
#### 1、添加域名
```shell
update_dns.sh -m add -d ok.flycua.com -c A -i 192.168.1.1 -z flycua.com
```

#### 2、删除单个域名
```shell
update_dns.sh -m delete -d ok.flycua.com -c A -i 192.168.1.1 -z flycua.com
```

#### 3、删除所有指定域名的记录
```shell
update_dns.sh -m delete -d ok.flycua.com -c A
```
#### 4、显示指定zone区的记录
```shell
update_dns.sh -z flycua.com
```
