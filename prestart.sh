#!/bin/bash

# 定义要添加的主机名和IP 到 /etc/hosts
entries=(
    "127.0.0.1       aospace-fileapi"
    "127.0.0.1       aospace-redis"
)
# 遍历数组并检查每个条目是否已经存在于 /etc/hosts 中
for entry in "${entries[@]}"; do
    if ! grep -qF "$entry" /etc/hosts; then
        echo "$entry" >> /etc/hosts
        echo "Added: $entry"
    else
        echo "Already exists: $entry"
    fi
done


# 启动 Redis
redis-server --requirepass placeholder_mysecretpassword --appendonly yes --appendfsync everysec --auto-aof-rewrite-percentage 100 --auto-aof-rewrite-min-size 100mb &

# 启动你的应用程序
# space-postgresql
mkdir /data
chown postgres:postgres /data
chmod 777 /data
su - postgres -c '
    env POSTGRES_PASSWORD=placeholder_mysecretpassword \
    POSTGRES_USER=postgres \
    POSTGRES_FILEDB=file \
    POSTGRES_MAILDB=mail \
    POSTGRES_GATEWAYDB=gateway \
    POSTGRES_ACCOUNTDB=account \
    PGDATA=/data \
    /usr/local/bin/docker-entrypoint.sh postgres
' &
sleep 10

# space-filepreview
# echo "starting space-filepreview..."
# python3 /workdir/main.py  &
# sleep 20

# space-agent
echo "starting space-agent... "
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf 

# 阻塞脚本，使其保持运行
tail -f /dev/null
