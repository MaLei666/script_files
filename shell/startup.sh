#!/bin/bash 
#保留文件数 
ReservedNum=3 
FileDir=/data/mysqldata
logfile=/data/log/backup.log.$(date "+%Y-%m-%d")
mysqlpw=QQvkIg3@v6
mysqlsock=/var/lib/mysql/mysql.sock
backup2ip=192.168.1.197
backup2pw=EAffMbA5Y2
backup3ip=192.168.1.177
backup3pw=l3gxA61WuD
date=$(date "+%Y_%m_%d-%H_%M_%S")
echo "**************************************************************" >>$logfile 2>&1
echo "mysql backup starting..." >>$logfile 2>&1
echo "**************************************************************" >>$logfile 2>&1
innobackupex --user=root --password=$mysqlpw --port=3306 --socket=$mysqlsock --no-timestamp $FileDir/$date >>$logfile 2>&1
innobackupex --apply-log $FileDir/$date >>$logfile 2>&1
tar zcvf $FileDir/$date.tar.gz $FileDir/$date >>$logfile 2>&1
rm -rf $FileDir/$date/
echo "backup1 localhost complete!" >>$logfile 2>&1
sshpass -p $backup2pw scp -r $FileDir/$date.tar.gz root@$backup2ip:$FileDir
echo "backup2 $backup2ip complete!" >>$logfile 2>&1
sshpass -p $backup3pw scp -r $FileDir/$date.tar.gz root@$backup3ip:$FileDir
echo "backup3 $backup3ip complete!" >>$logfile 2>&1

FileNum=$(ls -l $FileDir|grep ^- |wc -l)
while(( $FileNum > $ReservedNum)) 
do 
	OldFile=$(ls -rt $FileDir| head -1) 
	echo $date "Delete File:"$OldFile >>$logfile 2>&1	
	rm -f $FileDir/$OldFile 
	let "FileNum--" 
done
