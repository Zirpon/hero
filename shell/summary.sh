#/bin/sh

declare -A dic
num=0
var=""
#tail -n 10 ./log/9905_conn.log | awk -F' ' '{cmd1="let num=num+1;dic+=([$var]=$num)";cmd3=("\""$8"\"");cmd4="var="cmd3""";";cmd=(cmd4""cmd1);print(cmd1,cmd4,cmd);system(cmd4);system(cmd1)}'
cat ./log/9905_conn.log | awk -F' ' '{print $8}' > tmp.txt

while read line
do
    #arr=($line)
    let num=num+1
    dic+=([$line]=$num)
    #echo $line $num
done < tmp.txt
num=0
for key in $(echo ${!dic[*]})
do
    #echo "$key : ${dic[$key]}"
    ret=`curl -s https://ip.cn/$key`
    echo $ret >> tmpaddress.txt
    let num=num+1
done
echo "total user count" $num
cat tmpaddress.txt | sort
rm -f tmp.txt
rm -f tmpaddress.txt

