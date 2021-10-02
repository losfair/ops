#!/bin/bash

set -euo pipefail

appdir="/opt/trilium"
workdir="/opt/trilium-backup"

now="$(date -u +%Y-%m-%d_%H-%M-%S)"
outname="$now-$(openssl rand -hex 8).sql"

mkdir -p "$workdir/base/"

sqlite3 "$appdir/data/document.db" .dump > "$workdir/base/$outname"
zstd < "$workdir/base/$outname" | sudo -u infra-backup aws s3 cp - "s3://infra-backup.s3.univalent.net/apphost/trilium/base/$outname.zstd"
echo "trilium-sqlite-backup-base completed"
