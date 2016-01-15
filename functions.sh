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

		tar $filesTarCreateParam --file=${filesBackupsDir}/archives/$1.tar.gz \
		--listed-incremental=${filesBackupsDir}/meta/$1 --exclude-from=${filesExclude} ./

		# Вернулись в каталог скрипта
		cd ${scriptDir}

		# Cинхронизация с amazon
		#if [ "$filesUseAws" == "yes" ];

			#then

				#loging "Syncing with AWS"

				#s3cmd put ${filesBackupsDir}/$1.tar.gz s3://${awsBucketName}/files/

		#fi
	
}

# Бэкап MySQL
mysqlBackup(){

	loging "Making MySQL backup"

	mkdir -p ${mysqlBackupsDir}/${nowMonth}

	mysqldump -h ${mysqlHost} -P ${mysqlPort} -u ${mysqlUser} -p${mysqlPassword} ${mysqlDatabases} | gzip > ${mysqlBackupsDir}/${nowMonth}/${nowDay}.sql.gz

}

# Синхронизация Read-only контента
syncReadOnly(){

	loging "Syncing Read-only files with AWS"

}