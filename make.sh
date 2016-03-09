#!/bin/bash

# Выясняем путь до скрипта
scriptDir=$(dirname $(readlink -e $0))

# Подключаем настройки
source "${scriptDir}/config"

# Подключаем функции
source "${scriptDir}/functions.sh"

loging "Start working"

nowMonth=`date +%m`
nowDay=`date +%d`

# Файловый бекап
if [ "$filesMakeBackups" == "yes" ];
	then

	loging "Start backup files"
	
	# Синхронизация read-only контента
	# При синхронизации создать tmp список исключений архивирования
	# В него добавить все записи из filesRO c добавление ./имя папки/*
	if [ "$filesUseRO" == "yes" ];
		then 

		loging "Syncing Read-Only content"

		while read item; do

    		(rsync -avzul ${filesTargetDir}/${item} ${filesBackupsDir}/readOnly/ ) 2>> ${scriptDir}/runTimeErrors

		done < <( egrep -v '^ *(#|$)' < "${filesRO}")

	fi

	if [ ! -f ${filesBackupsDir}/meta/${nowMonth}/full ];
		then

		loging "Making full month backup ${nowMonth}"

		mkdir -p ${filesBackupsDir}/meta/${nowMonth}
		mkdir -p ${filesBackupsDir}/archives/${nowMonth}

		rm -f ${filesBackupsDir}/meta/${nowMonth}/full

		tarBackup ${nowMonth}/full

		loging "Clearing old files backups"

	fi

	loging "Making incremental regular backup ${nowMonth}/${nowDay}"

	cp ${filesBackupsDir}/meta/${nowMonth}/full ${filesBackupsDir}/meta/${nowMonth}/${nowDay}

	tarBackup ${nowMonth}/${nowDay}

	find ${filesBackupsDir}/archives/* -type d -mtime +$[$filesMonthsCount*31] | xargs rm -rf
	find ${filesBackupsDir}/meta/* -type d -mtime +$[$filesMonthsCount*31] | xargs rm -rf

	# Синхронизация с AWS
	if [ "$filesUseAws" == "yes" ];
		then

		loging "Syncing with AWS"

		syncWithAWS ${filesBackupsDir} files

	fi

fi

# MySQL бекап
if [ "$mysqlMakeBackups" == "yes" ];
	then

	mysqlBackup 

	loging "Clearing old MySQL backups"

	find ${mysqlBackupsDir}/* -type d -mtime +${mysqlDaysCount} | xargs rm -rf

	if [ "$mysqlUseAws" == "yes" ];
	then

	loging "Syncing with AWS"

	syncWithAWS ${mysqlBackupsDir} mysql

	fi

fi

# PostgreSQL бекап
if [ "$posrgresqlMakeBackups" == "yes" ];
	then

	posrgresqlBackup 

	loging "Clearing old posrgreSQL backups"

	find ${posrgresqlBackupsDir}/* -type d -mtime +${posrgresqlDaysCount} | xargs rm -rf

	if [ "$posrgresqlUseAws" == "yes" ];
	then

	loging "Syncing with AWS"

	syncWithAWS sync ${posrgresqlBackupsDir} posrgresql

	fi

fi

# Проверка наличия ошибок выполнения
if [ -s ${scriptDir}/runTimeErrors ]  
then  

	loging "Have errors! Reporting..."

    cat ${scriptDir}/runTimeErrors | tee -a ${scriptDir}/logs | mail -s "ERROR backuping on ${serverName}" ${mainReportMail}

    rm ${scriptDir}/runTimeErrors

fi  

loging "Finish working"

exit