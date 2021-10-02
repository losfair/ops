#!/bin/bash

set -euo pipefail

datadir="/data01/rmfakecloud/data"
workdir="/data01/backups/rmfakecloud"

now="$(date -u +%Y-%m-%d_%H-%M-%S)"
outname="$now-$(openssl rand -hex 8).tar.zstd"
mkdir -p "$workdir/"

cd "$datadir"
tar c . | zstd > "$workdir/$outname"
ls -lash "$workdir/$outname"
sudo -u infra-backup aws s3 cp "$workdir/$outname" "s3://infra-backup.s3.univalent.net/apphost/rmfakecloud/$outname"
rm "$workdir/$outname"
echo "rmfakecloud data backup completed"
