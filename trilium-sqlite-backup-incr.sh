#!/bin/bash

set -euo pipefail

appdir="/opt/trilium"
workdir="/opt/trilium-backup"
last_successful_base="$(ls "$workdir/base/" | tail -n 1)"

if [ -z "$last_successful_base" ]; then
  echo "No base backup - nothing to do."
  exit 0
fi

echo "Generating patch from base backup $last_successful_base"

now="$(date -u +%Y-%m-%d_%H-%M-%S)"

mkdir -p /tmp/trilium-incr

# Create temporary file for storing the dump
tmpname="$(mktemp -p /tmp/trilium-incr)"

# Dump & diff
sqlite3 "$appdir/data/document.db" .dump > "$tmpname"
incr_name="$now-$(openssl rand -hex 8).patch.zstd"
diff -u "$workdir/base/$last_successful_base" "$tmpname" | \
  zstd | \
  sudo -u infra-backup aws s3 cp - "s3://infra-backup.s3.univalent.net/apphost/trilium/incr/${last_successful_base}_$incr_name"
rm "$tmpname"
echo "trilium-sqlite-backup-incr completed"
