pids=`tasklist | grep dev | awk -F' ' '{print $2}'`
#echo $pids
num=0
for i in ${pids}; do
	echo $i
	tskill $i
	let num=num+1
done
echo "close $num clients "
