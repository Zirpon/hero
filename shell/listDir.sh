#!/bin/sh 
echo "srcdir:" $1 
if [ "$#" -ne "1" ]; then
	echo "请输入poto文件目录"
	exit 1
fi
#svn revert $1
#svn update $1
#svn st -q | grep ^C > sConflict
#if [ "$sConflict" -ne "" ]; then
#	echo "svn 更新冲突，请检查并解决冲突"
#	exit 1
#fi
pbPath=$1/protocol 
list_alldir(){
echo "list_alldir $1"
#for file2 in $1/*  #'ls -a $1' #`find $1 -name *.proto`  
for file2 in `find ./ |grep -v "svn" |grep -E "*.proto$" |sort -k9`
do  
	if [ "$file2" != "." -a "$file2" != ".." ];then  
		if [ -d "$file2" ];then  
			#echo "dir $file2"  
			list_alldir "$file2"
		else
			if [ "${file2##*.}" = "proto"  ];then
				fname=${file2##*/}
				fname=${fname%.*}
				echo "full $file2" 
				echo "name $fname"
				echo "path ${file2%/*}"
				echo "shortName ${file2%.*}"
				fname="$pbPath/$fname".pb
				echo "PBname $fname"
				./protoc   --descriptor_set_out="$fname" "$file2" 
			fi
		    
		 fi
	fi  
done
	
}

rm -rf $pbPath/*.pb
rm -rf $pbPath/Protocol.lua

list_alldir $1 
./ReadPb $1 $1
#svn status $1 |grep ! |awk '{print $2}'|xargs svn del
#svn st  $1 | grep '^\?' | tr '^\?' ' ' | sed 's/[ ]*//' | sed 's/[ ]/\\ /g' |  xargs svn add
#svn commit -m "自动提交pb文件"
