#！ /bin/bash

function usage(){
echo "usage $0 
-m | --method (add|delete) 
-d | --domain_name domain_name 
-c | --class ( A | AAAA | NS | default:A ) 
-i | --data ( ip|domain_name )
-z | --zone zone_name 显示zone记录
"
}

[ $# -eq 0 ] && usage && exit 1

ARGV=`getopt -o m:d:c:i:-z:h -l method:,domain_name:,class:,data:,zone:,help  -n test.sh -- "$@"`
eval set --"$ARGV"
while true
do
    case "$1" in
    -m|--method)
    method="$2"
        shift
        ;;
    -d|--domain_name)
    domain_name="$2"
        shift
        ;;
    -c|--class)
    class="$2"
        shift
        ;;
    -i|--data)
    data="$2"
        shift
        ;;
    -z|--zone)
    zone="$2"
	shift
	;;
    -h|--help)
    usage
    exit 0
        ;;
    --)
        shift
    break
        ;;
    *) 
    usage
        exit 0
    ;;
    esac
shift
done

cmd=/app/bind9/bin/nsupdate

function test_argments(){
    [ -z $1 ]
}
test_argments $class && class=A

function add_domain(){
$cmd -v <<EOF
server 127.0.0.1 53
update $method $domain_name 86400 IN $class $data
send
quit
EOF
}
function del_domain(){
$cmd -v <<EOF
server 127.0.0.1 53
update $method $domain_name $class $data
send
EOF
}
function show_domain(){
dig -t axfr $zone @127.0.0.1 | grep '^[^;]' | grep -v SOA
}
if [ "$method" == 'add' ]
    then
    test_argments $domain_name && echo 'method为add ,domain_name 不能为空' && test_argments $data && echo 'metod为add,data 不能为空' || add_domain
elif [ "$method" == 'delete' ]
    then
    test_argments $domain_name && echo 'metod为del ,domain_name 不能为空' || del_domain
fi
test_argments $zone || show_domain
