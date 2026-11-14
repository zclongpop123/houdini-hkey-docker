#!/bin/bash
LICENSE_FILE="/usr/lib/sesi/licenses"
SESICTRL="/usr/lib/sesi/sesictrl"
KEYGEN="./keygen"
VER="22.0"

server_info=$("$SESICTRL" print-server | awk '$1 == "SERVER" { print $2, $3; exit }')
read -r SRV_NAME SRV_CODE <<< "$server_info"

licenses=$("$KEYGEN" "$SRV_NAME" "$SRV_CODE" "$VER")
while IFS= read -r line; do
    [ -z "${line//[[:space:]]/}" ] && continue
    printf '%s\n' "$line" | "$SESICTRL" install "$line" \
        || { echo "[WARN] 安装失败: $line"; fail=1; }
done <<< "$licenses"
