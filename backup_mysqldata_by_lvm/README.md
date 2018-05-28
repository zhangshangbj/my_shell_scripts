## backup_mysql_lvm.sh脚本用来备份mysql的数据库
### 使用范例
```
sh <script_name> -d <db_path> -b <backup_path> -l <lvm_name> -v <vg_of_lvm>
#-d 数据库数据位置
#-b 备份文件目录
#-l mysql数据所在lvm名称
#-v lvm所在的vg名称
#--binlog 备份数据的同时备份binlog文件
```

##restore_mysql_data_lvm.sh脚本还原lvm备份的mysql数据库
### 使用范例
```
sh <script_name> -d <db_path> -b <backup_path>
#-d 数据库数据位置
#-b 备份文件目录
```
注意：使用还原脚本之后需要手动会不binlog的数据差异
