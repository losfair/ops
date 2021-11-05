#!/bin/bash

set -euxo pipefail

sqlite3 -readonly "$1" << EOF
.headers on
.mode csv
select * from wpbl where expiry >= datetime() order by length(rangestart), rangestart asc;
EOF
