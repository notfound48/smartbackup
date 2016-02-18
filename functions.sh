# Логгировние 
loging(){
	
	echo [`date +'%x %H:%M:%S'`] $1 | tee -a ${scriptDir}/logs

}

# Архивирование tar'ом
# $1 - имя файла мета-данных
tarBackup(){

		# Перемещаемся в целевой каталог
		cd ${filesTargetDir}

		( tar $filesTarCreateParam --file=${filesBackupsDir}/archives/$1.tar.gz \
		--listed-incremental=${filesBackupsDir}/meta/$1 --exclude-from=${filesExclude} ./ ) 2>> ${scriptDir}/runTimeErrors

		# Вернулись в каталог скрипта
		cd ${scriptDir}
		
}

# Бэкап MySQL
mysqlBackup(){

	loging "Making MySQL backup"

	mkdir -p ${mysqlBackupsDir}/${nowMonth}

	( mysqldump -h ${mysqlHost} -P ${mysqlPort} \
	 -u ${mysqlUser} -p${mysqlPassword} ${mysqlDatabases} | gzip > ${mysqlBackupsDir}/${nowMonth}/${nowDay}.sql.gz ) 2>> ${scriptDir}/runTimeErrors

}