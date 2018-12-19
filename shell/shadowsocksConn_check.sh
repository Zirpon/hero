#/bin/sh

if [[ $# < 1 ]]; then
    echo "too few agr"
    echo "usage: sh shadowsocksConn_check.sh port"
    #echo usage: sh svnCommitCount.sh "zhangzhipeng" "2017-08"
    exit
fi
#netstat -nap | grep "9905" | grep "ESTABLISHED" | awk -F' ' '{split($5,data,":");cmd="curl https://ip.cn/"data[1];system(cmd)}' >> ./log/9905_conn.log
port=$1
#echo "port:$port"
iplist=`netstat -nap | grep "$port" | grep "ESTABLISHED" | awk -F' ' '{split($5,data,":");print data[1]}'`
#echo "iplist:$iplist"

declare -A dic
logfile="/root/shadowsocks_mgr/log/${port}_conn.log"
#echo $logfile

num=0
for i in ${iplist}; do
    #echo $i
    let num=num+1
    dic+=([$i]=$num)
done

for key in $(echo ${!dic[*]})
do
    #echo "$key : ${dic[$key]}"
    ret=`curl -s https://ip.cn/$key`
    echo "`date` $ret" >> $logfile
done

#echo "iplist:" $iplist
