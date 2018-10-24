
dirs=`ls | grep "dev"`
#echo "ddddd ${dirs}"

num=0
for i in ${dirs}; do

	
	exedir=./$i
	if [ -d $exedir ]; then
		echo "rm -rf $exedir"
		rm -rf $exedir
		let num=num+1
	fi
done


zipfile="dev.zip"
if [ $# -gt 0 ]; then
	zipfile=$1
fi
echo "zipfile $zipfile"

unzip -q $zipfile

for ((i=1;i<10;i++)); do
    echo $i
    newdev="dev$i"
    echo "cp -r dev/ $newdev"
    cp -r dev/ $newdev
done
