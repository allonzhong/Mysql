#!/bin/bash
# subject is to backup the mysql
# author  allon zhong
# date `date +%F`
#
date=`date '+%F-%H:%M:%S'`
backdir=/home/backup/mysql/bkdir
tmpbkdir=/home/backup/mysql/tmpbk
dailybkdir=/home/backup/mysql/daily
bklogdir=/home/backup/mysql/log
bklogfile=$bklogdir/mysqlbackup.log
dumpfile=fullbackup_mysql$date.sql
user='root'
password='zftcloud'
tarbkfile=fullbk$date.sql.tar.bz
begin=`date +'%Y-%m-%d-%H:%M:%S'`
[ ! -d $backdir ] && mkdir -pv $backdir &> /dev/null && echo "created the $backdir successfull"
[ ! -d $bklogdir ] && mkdir -pv $bklogdir &> /dev/null && echo "create log directory $bklogdir successfull"
if [ ! -f $bklogfile ]; then
	touch $bklogfile &> /dev/null
#else
#	[ -s $bklogfile ] && cat /dev/null > $bklogfile 
#	echo "$bklogfile is exist"
fi
[ ! -e $dailybkdir ] && mkdir -pv $dailybkdir &> /dev/null && echo "created the $dailybkdir successfull"
sleep 1
/usr/local/mysql/bin/mysqldump -u$user -p$password --quick --all-databases --flush-logs --delete-master-logs --single-transaction > ${tmpbkdir}/$dumpfile  2> /root/error.log
/usr/bin/tar -zcvf $backdir/$tarbkfile $tmpbkdir/$dumpfile &> /dev/null 
#	&& echo "the $dumpfile has stored"
cd $backdir
count=`ls -l *.bz | wc -l`
countnum=0
#if [ $count -gt 5 ]; then
for file in `ls -l *.bz | awk '{print $9}'`
do
	let countnum++	
	totalcount=`expr $count - $countnum`
	if [ $totalcount -gt 4 ]; then
		rm -f $file
	else
		echo -e "\033[32m store file $file \033[0m"
	fi
done
cd $tmpbkdir
digit=`ls -l *.sql | wc -l`
I=0
for files in `ls -l *.sql | awk '{print $9}'`
	do 
	let I++
	totaldigit=$[$digit - $I]
	if [ $totaldigit -gt 0 ]; then
		rm -f $files && echo -e "\033[33m delete completed  \033[0m"
	else
		echo -e "\033[32m stored the file $files \033[0m"
	fi
done
end=`date +'%Y-%m-%d-%H:%M:%S'`
echo -e "you begin to backup the database in $begin, and completd in $end" >> $bklogfile 
cd $dailybkdir
rm -rf * 
