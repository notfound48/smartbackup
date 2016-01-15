# Логгировние 
loging(){
	
	echo [`date +'%x %H:%M:%S'`] $1
	echo [`date +'%x %H:%M:%S'`] $1 >> logs

}

# Извещение об ошибке
errorReporting(){

	echo [`date +'%x %H:%M:%S'`] $1
	
}

# Архивирование tar'ом
# $1 - имя файла мета-данных
tarBackup(){

		# Перемещаемся в целевой каталог
		cd ${filesTargetDir}

		tar $filesTarCreateParam --file=${filesBackupsDir}/$1.tar.gz \
		--listed-incremental=${scriptDir}/meta/$1 --exclude-from=${filesExclude} ./

		# Вернулись в каталог скрипта
		cd ${scriptDir}

		# Cинхронизация с amazon
		if [ "$filesUseAws" == "yes" ];

			then

				loging "Syncing with AWS"

				s3cmd put ${filesBackupsDir}/$1.tar.gz s3://${awsBucketName}/files/

		fi
	
}

tarBackupMonth(){

		loging "Making full month backup"

		rm -f ${scriptDir}/meta/month

		tarBackup month

}

tarBackupWeek(){

		if [ ! -f ${scriptDir}/meta/month ];
			
			then

				loging "Have not month backup"

				tarBackupMonth

		fi

		loging "Making incremental week backup"

		cp ${scriptDir}/meta/month ${scriptDir}/meta/week

		tarBackup week

}

tarBackupDay(){

		if [ ! -f ${scriptDir}/meta/week ];
			
			then

				loging "Have not week backup"

				tarBackupWeek

		fi

		loging "Making incremental day backup"

		execDay=`date +%A`

		cp ${scriptDir}/meta/week ${scriptDir}/meta/${execDay,,}

		tarBackup ${execDay,,}

}

# Бэкап MySQL
mysqlBackup(){

	loging "Making MySQL backup"

	[ `date +%d` = $filesMonthDay ] && mysqlDumpName="month" || [ `date +%u` = 1 ] && mysqlDumpName="week" || mysqlDumpName=`date +%A`

	mysqldump -h ${mysqlHost} -P ${mysqlPort} -u ${mysqlUser} -p${mysqlPassword} ${mysqlDatabases} | gzip > ${mysqlBackupsDir}/${mysqlDumpName,,}.sql.gz

	# Cинхронизация с amazon
	if [ "$mysqlUseAws" == "yes" ];

		then

			loging "Syncing with AWS"

			s3cmd put ${mysqlBackupsDir}/${mysqlDumpName,,}.sql.gz s3://${awsBucketName}/mysql/

	fi

}

# Синхронизация Read-only контента
syncReadOnly(){

	loging "Syncing Read-only files with AWS"

}