# Логгировние
loging(){

	echo [`date +'%x %H:%M:%S'`] $1 | tee -a ${scriptDir}/logs

}

# Архивирование tar'ом
# $1 - имя файла мета-данных
tarBackup(){


		( tar $filesTarCreateParam --file=${filesBackupsDir}/archives/$1.tar.gz \
		--listed-incremental=${filesBackupsDir}/meta/$1 \
		--exclude-from=${scriptDir}/tmpFilesExclude \
		--files-from=${scriptDir}/filesList ) 2>> ${scriptDir}/runTimeErrors

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

	done < <( egrep -v '^ *(#|$)' < "${scriptDir}/pgDbList")

}

# Синхронизация с AWS
syncWithAWS(){

	s3cmd -c ${scriptDir}/.s3cfg --acl-private --delete-removed --guess-mime-type sync $1/ s3://${awsBucketName}/$2/

}
