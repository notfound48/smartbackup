#!/bin/bash

# Выясняем путь до скрипта
scriptDir=$(dirname $(readlink -e $0))

# Подключаем настройки
source "${scriptDir}/config"

# Подключаем функции
source "${scriptDir}/functions.sh"

loging "Start working"

loging "Start backup files"

# Месячный бекап
[ `date +%d` = $filesMonthDay ] && tarBackupMonth

# Недельный инкрементный бекап
[ `date +%u` = 1 ] && tarBackupWeek || tarBackupDay

# MySQL бекап
[ "$mysqlMakeBackups" == "yes" ] && mysqlBackup

loging "Finish working"