#!/bin/bash

# Выясняем путь до скрипта
scriptDir=$(dirname $(readlink -e $0))

# Подключаем настройки
source "${scriptDir}/config"

# Подключаем функции
source "${scriptDir}/functions.sh"

loging "Start working"

loging "Start backup files"

nowMonth=`date +%m`
nowDay=`date +%d`

if [ ! -f ${filesBackupsDir}/meta/${nowMonth}/full ];
	then

	loging "Making full month backup ${nowMonth}"

	mkdir -p ${filesBackupsDir}/meta/${nowMonth}
	mkdir -p ${filesBackupsDir}/archives/${nowMonth}

	rm -f ${filesBackupsDir}/meta/${nowMonth}/full

	tarBackup ${nowMonth}/full

fi

loging "Making incremental regular backup ${nowMonth}/${nowDay}"

cp ${filesBackupsDir}/meta/${nowMonth}/full ${filesBackupsDir}/meta/${nowMonth}/${nowDay}

tarBackup ${nowMonth}/${nowDay}

loging "Clearing old files backups"

find ${filesBackupsDir}/archives -type d -mtime +$[$filesMonthsCount*31] | xargs rm -rf
find ${filesBackupsDir}/meta -type d -mtime +$[$filesMonthsCount*31] | xargs rm -rf

if [ "$filesUseAws" == "yes" ];
	then

	loging "Syncing with AWS"

	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync ${filesBackupsDir}/ s3://${awsBucketName}/files/

fi

# MySQL бекап
if [ "$mysqlMakeBackups" == "yes" ];
	then

	mysqlBackup 

	loging "Clearing old MySQL backups"

	find ${mysqlBackupsDir} -type d -mtime +$[$filesMonthsCount*31] | xargs rm -rf

	if [ "$mysqlUseAws" == "yes" ];
	then

	loging "Syncing with AWS"

	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync ${mysqlBackupsDir}/ s3://${awsBucketName}/mysql/

	fi

fi

loging "Finish working"