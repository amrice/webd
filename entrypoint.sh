#!/bin/sh
# 启动 webd 前，确保 .player.htm 存在于数据目录
cp -n /opt/player/.player.htm /data/share/.player.htm 2>/dev/null
exec webd -w /data
