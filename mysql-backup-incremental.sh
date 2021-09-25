#!/bin/bash

set -euxo pipefail

#path to directory with binary log files
binlogs_path=/var/log/mysql/
#path to backup storage directory
backup_folder=/var/backups/mysql/
output_name=$(date -u +%Y-%m-%d_%H-%M-%S).tar.zstd
output_file=$backup_folder/$output_name
#start writing to new binary log file
sudo mysql -E --execute='FLUSH BINARY LOGS;' mysql
#get list of binary log files
binlogs=$(sudo mysql -E --execute='SHOW BINARY LOGS;' mysql | grep Log_name | sed -e 's/Log_name://g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
#get list of binary log for backup (all but the last one)
binlogs_without_Last=`echo "${binlogs}" | head -n -1`
#get the last active binary log file (which you do not have to copy)
binlog_Last=`echo "${binlogs}" | tail -n -1`
#form full path to binary log files
binlogs_fullPath=`echo "${binlogs_without_Last}" | xargs -I % echo $binlogs_path%`
#compress binary logs into archive
echo "$binlogs_fullPath" | tar -c -T - | zstd | \
  sudo -u infra-backup aws s3 cp - s3://infra-backup.s3.univalent.net/apphost/mysql/incr/$output_name
#delete saved binary log files
echo $binlog_Last | xargs -I % sudo mysql -E --execute='PURGE BINARY LOGS TO "%";' mysql
