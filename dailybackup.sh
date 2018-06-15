#!/bin/bash
# subject this shell is used for backup the binary log everyday
# author: allon zhong 
# date: 2018.6.14
#
bakdir=/home/backup/mysql/daily
bindir=/mnt/mydata/data
logfile=/home/backup/mysql/log/mysqlbackup.log
binfile=/mnt/mydata/data/mysql-bin.index
/usr/local/mysql/bin/mysqladmin -uroot -pzftcloud flush-logs &> /dev/null
counter=`wc -l $binfile | awk '{print $1}'`
NextNum=0
for file in `cat $binfile`
	do 
	base=`basename $file`
#	NextNum=`expr $NextNum +1`
	let NextNum++
	if [ $NextNum -eq $counter ]; then
		echo "$base skip!" >> $logfile
	else
		dest=$bakdir/$base
		if (test -e $dest)
		 then
			echo $base exist! >> $logfile
		else 
			cp $bindir/$base $bakdir && echo -e  "\033[32m in `date '+%F-%H:%M:%S'`,$base backup successfull.\033[0m"
			echo $base copying >> $logfile
		fi
	fi
done
echo "`date '+%F-%H:%M:%S'` $NextNum was backup succsess" >> $logfile
cd $bakdir 
Count=`ls -l mysql* | wc -l`
Number=0
for binfiles in `ls -l mysql* | awk '{print $9}'`
	do
	let Number++ 
	LastNum=`expr $Count - $Number`	
	if [ $LastNum -gt 4 ]; then
		rm -f $binfiles && echo -e "\033[30m delete $binfiles...\033[0m"
		mysql -uroot -pzftcloud -e "purge binary logs to '$binfiles'" &> /dev/null
	else
		echo -e "\033[033m stored for file $binfiles \033[0m"
	fi
done

