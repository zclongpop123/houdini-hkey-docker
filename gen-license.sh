#!/bin/bash
CONTAINER="${1:?请提供容器名称或ID}"
SESICTRL="/usr/lib/sesi/sesictrl"
KEYGEN="./keygen"
VER="22.0"

dexec() { docker exec -i "$CONTAINER" "$@"; }

server_info=$(dexec "$SESICTRL" print-server | awk '$1 == "SERVER" { print $2, $3; exit }')
read -r SRV_NAME SRV_CODE <<< "$server_info"
echo "[INFO] SERVER: $SRV_NAME $SRV_CODE"

licenses=$("$KEYGEN" "$SRV_NAME" "$SRV_CODE" "$VER")
while IFS= read -r line; do
    [ -z "${line//[[:space:]]/}" ] && continue
    dexec "$SESICTRL" install "$line" < /dev/null \
        || { echo "[WARN] 安装失败: $line"; fail=1; }
done <<< "$licenses"
