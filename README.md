# Скрипт резервного копирования

## Основные возможности

* Ежемесячная полная копия и каждый день инкрементная копия от месячной
* Возможность указывать количество месяцев хранения
* Архивирование дампов MySQL
* Архивирование дампов PostgreSQL
* Возможность хранения в AWS S3
* Оповещение о неудачных бекапах на e-mail

## Подготовка к установке
```
sudo apt-get update && apt-get install git s3cmd rsync

git clone https://github.com/notfound48/amazonBackup.git

```

## Установка s3cmd
```
git clone https://github.com/s3tools/s3cmd.git
cd s3cmd/
python setup.py install

s3cmd --configure

mv ~/.s3cfg /path/to/script/root
```