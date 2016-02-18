#!/bin/bash

# Выясняем путь до скрипта
scriptDir=$(dirname $(readlink -e $0))

# Подключаем настройки
source "${scriptDir}/config"

# Подключаем функции
source "${scriptDir}/functions.sh"

echo "It's just test mail! Don't worry!" | mail -s "ERROR backuping on ${serverName}" ${mainReportMail}

exit