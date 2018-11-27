#! /bin/bash

if [[ $# < 2 ]]; then
    echo "too few agr"
    echo usage: sh svnCommitCount.sh "zhangzhipeng" "2017-08-21" "2017-08-22"
    #echo usage: sh svnCommitCount.sh "zhangzhipeng" "2017-08"
	exit
fi

username=$1
repositoryList="repositoryList_$username.txt"
diff="diff_$username.txt"

for var in "$@"
do
    if [[ $var = $username ]]; then
        continue
    fi
    #usagesh svnCommitCount.sh "zhangzhipeng" "2017-08"
    # echo svn log --search $username --search-and $var -q
    #svn log --search "$username" --search-and "$var" -q >> $repositoryList 
done
    #echo $1 $2 $3
    #usage: sh svnCommitCount.sh "zhangzhipeng" "2017-08-21" "2017-08-22"
    svn log --search "$username" -r {$2}:{$3} -q | grep $username > $repositoryList 
# cat $repositoryList

vs=
while read line
do
    arr=($line)
    vs="$vs "${arr[0]}

done < $repositoryList
#echo $vs

marr=($vs)
num=${#marr[*]}
echo "there are ${num} versions"

for ((i=0;i<num;i++))
{
    szVersion=${marr[i]}
	
	#echo "------------------------------------------------------------------------"
    if [[ $szVersion =~ '----------------------------' ]]; then
		#echo "continue"
        continue;
    fi
	
	#echo "|$szVersion|" 
	#echo 'nono'
   	len_szVersion=${#szVersion}
	#echo $len_szVersion
   	nVersion=${szVersion:1:${len_szVersion}}
	#echo $nVersion
	
    let second=$nVersion
    let first=${second}-1

    #echo $first
    #echo $second

    svn diff -r ${first}:${second} >> $diff
}


let n=0
while read line
do
	#if [[ $line =~ "+" ]];then
		#echo "$line||${line:0:1}||${line:0:3}"
	#fi
	
	if [[ ${line:0:1} = "+" ]];then
		let n++
	fi

    if [[ ${line:0:3} = "+++" ]];then
		let n--
    fi
	# if [[ ${line:0:1} = "-" ]];then
	# let n++
	# fi
	
done < $diff

echo "$username commit code $n line"

  rm $diff
  rm $repositoryList
