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

	export MYSQL_PWD=${mysqlPassword}

	( mysqldump -h ${mysqlHost} -P ${mysqlPort} \
	 -u ${mysqlUser} --single-transaction ${mysqlDatabases} | gzip > ${mysqlBackupsDir}/${nowMonth}/${nowDay}.sql.gz ) 2>> ${scriptDir}/runTimeErrors

}

# Бэкап PostgreSQL
posrgresqlBackup(){

	loging "Making PostgreSQL backup"

	mkdir -p ${posrgresqlBackupsDir}/${nowMonth}

	while read item; do

		( pg_dump -U ${posrgresqlUser} -h ${posrgresqlHost} \
	 	-p ${posrgresqlPort} ${item} | gzip > ${posrgresqlBackupsDir}/${nowMonth}/${nowDay}.${item}.sql.gz  ) 2>> ${scriptDir}/runTimeErrors		

	done < <( egrep -v '^ *(#|$)' < "${posrgresqlDbList}")


}