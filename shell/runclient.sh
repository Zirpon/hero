
dirs=`ls | grep "dev"`
#echo "ddddd ${dirs}"

maxnum=100
if [ $# -gt 0 ]; then
	maxnum=$1
fi
echo "maxnum $maxnum"

num=0
for i in ${dirs}; do
	if [ $num -eq $maxnum ]; then
		break
	fi
	
	exedir=./$i
	if [ -d $exedir ]; then
		echo $exedir
		exepath=$exedir/dev.exe
		start $exepath
		let num=num+1
	fi
done
echo "open $num clients "
