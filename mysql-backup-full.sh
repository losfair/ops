#!/bin/bash

mysqldump --flush-logs --delete-master-logs --single-transaction --all-databases | zstd | \
  sudo -u infra-backup aws s3 cp - s3://infra-backup.s3.univalent.net/apphost/mysql/base/$(date -u +%Y-%m-%d_%H-%M-%S)-base.zstd
