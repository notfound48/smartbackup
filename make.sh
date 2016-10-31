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

	rm -f ${scriptDir}/tmpFilesExclude

	if [ "$filesUseRO" == "yes" ];
		then

		loging "Syncing Read-Only content"

		if [ ! -s ${scriptDir}/filesRO ]
			then

			loging "No content to synchronize. Maybe have not filesRO or empty?"

			else

			mkdir -p ${filesBackupsDir}/readOnly/

			while read item; do

    			(rsync -avzul ${filesTargetDir}/${item} ${filesBackupsDir}/readOnly/ ) 2>> ${scriptDir}/runTimeErrors

    			echo "${item}/*" >> ${scriptDir}/tmpFilesExclude

			done < <( egrep -v '^ *(#|$)' < "${scriptDir}/filesRO")

		fi

	fi

	if [ ! -s ${scriptDir}/filesList ]
		then

			loging "No content to backuping. Maybe have not filesList or empty?"

		else

		if [ -s ${scriptDir}/filesExclude ];
			then

			cat ${scriptDir}/filesExclude >> ${scriptDir}/tmpFilesExclude

		fi

		if [ ! -f ${filesBackupsDir}/meta/${nowMonth}/full ];
			then

			loging "Making full month backup ${nowMonth}"

			mkdir -p ${filesBackupsDir}/meta/${nowMonth}
			mkdir -p ${filesBackupsDir}/archives/${nowMonth}

			tarBackup ${nowMonth}/full

		fi

		loging "Making incremental regular backup ${nowMonth}/${nowDay}"

		cp ${filesBackupsDir}/meta/${nowMonth}/full ${filesBackupsDir}/meta/${nowMonth}/${nowDay}

		tarBackup ${nowMonth}/${nowDay}

		loging "Clearing old files backups"

		find ${filesBackupsDir}/archives/* -type d -mtime +$[$filesMonthsCount*31] | xargs rm -rf
		find ${filesBackupsDir}/meta/* -type d -mtime +$[$filesMonthsCount*31] | xargs rm -rf

		# Синхронизация с AWS
		if [ "$filesUseAws" == "yes" ];
			then

			loging "Syncing with AWS"

			syncWithAWS ${filesBackupsDir} files

		fi
	fi

	rm -f ${scriptDir}/tmpFilesExclude

fi

# MySQL бекап
if [ "$mysqlMakeBackups" == "yes" ];
	then

	mysqlBackup

	loging "Clearing old MySQL backups"

	find ${mysqlBackupsDir}/* -type f -mtime +${mysqlDaysCount} | xargs rm -rf

	if [ "$mysqlUseAws" == "yes" ];
	then

	loging "Syncing with AWS"

	syncWithAWS ${mysqlBackupsDir} mysql

	fi

fi

# PostgreSQL бекап
if [ "$posrgresqlMakeBackups" == "yes" ];
	then

	if [ ! -s ${scriptDir}/pgDbList ]
		then

		loging "No BDs to backuping. Maybe have not pgDbList or empty?"

		else

		posrgresqlBackup

		loging "Clearing old posrgreSQL backups"

		find ${posrgresqlBackupsDir}/* -type f -mtime +${posrgresqlDaysCount} | xargs rm -rf

		if [ "$posrgresqlUseAws" == "yes" ];
			then

			loging "Syncing with AWS"

			syncWithAWS ${posrgresqlBackupsDir} posrgresql

		fi

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
