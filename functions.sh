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

	if [ $mysqlDatabases = "--all-databases" ]; then

		databases=`mysql  -h ${mysqlHost} -P ${mysqlPort} -u ${mysqlUser} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

		for database in $databases; do
  			( mysqldump -h ${mysqlHost} -P ${mysqlPort} -u ${mysqlUser} --single-transaction --databases ${database} | gzip > ${mysqlBackupsDir}/${nowMonth}/${nowDay}_${database}.sql.gz ) 2>> ${scriptDir}/runTimeErrors
		done

	else
		( mysqldump -h ${mysqlHost} -P ${mysqlPort} \
	 	-u ${mysqlUser} --single-transaction ${mysqlDatabases} | gzip > ${mysqlBackupsDir}/${nowMonth}/${nowDay}.sql.gz ) 2>> ${scriptDir}/runTimeErrors
	fi

}

# Бэкап PostgreSQL
posrgresqlBackup(){

	loging "Making PostgreSQL backup"

	mkdir -p ${posrgresqlBackupsDir}/${nowMonth}

	while read item; do

		( pg_dump -U ${posrgresqlUser} -h ${posrgresqlHost} \
	 	-p ${posrgresqlPort} ${item} | gzip > ${posrgresqlBackupsDir}/${nowMonth}/${nowDay}_${item}.sql.gz  ) 2>> ${scriptDir}/runTimeErrors

	done < <( egrep -v '^ *(#|$)' < "${scriptDir}/pgDbList")

}

# Синхронизация с AWS
syncWithAWS(){

	s3cmd -c ${scriptDir}/.s3cfg --acl-private --delete-removed --guess-mime-type sync $1/ s3://${awsBucketName}/$2/

}
