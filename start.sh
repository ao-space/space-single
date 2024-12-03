#!/bin/bash

if ps aux | grep "quarkus-run.jar" | grep -v "grep" > /dev/null
then
    echo "Process is running"
    exit 1
else
    echo "Process is not running"
fi

# space-gateway
echo "starting space-gateway... "

source /aospace/opt/tmp/aospace-gateway.env || true

export APP_BOX_PUBLIC_KEY_LOCATION=/aospace/etc/ao-space/box_key_pub.pem
export APP_BOX_PRIVATE_KEY_LOCATION=/aospace/etc/ao-space/box_key.pem
export APP_CLIENT_PUBLIC_KEY_LOCATION=/aospace/etc/ao-space/client_key_pub.pem
export APP_GATEWAY_FILE_SYSTEM_LOCATION=/eulixspace-data/symlink/
export APP_SHARED_INFO_FILE=/data/shared/shared_info.json
export APP_ACCOUNT_IMAGE_LOCATION=/aospace/opt/eulixspace/image/
export QUARKUS_DATASOURCE_USERNAME=postgres
export QUARKUS_DATASOURCE_PASSWORD=placeholder_mysecretpassword
export QUARKUS_DATASOURCE_JDBC_URL=jdbc:postgresql://localhost:5432/account
export QUARKUS_REDIS_HOSTS=redis://localhost:6379
export QUARKUS_REDIS_PASSWORD=placeholder_mysecretpassword
export APP_FILEAPI_URL=http://localhost:2001/space/v1/api
export APP_ACCOUNT_DATA_LOCATION=/aospace/opt/eulixspace/data/
export MAX_INVITE_MEMBER_COUNT=9
export APP_INTERNET_SERVICE_CONFIG=/aospace/etc/ao-space/internet_service_config.json

export APP_BOX_UUID=$(jq -r '.boxUuid' /aospace/etc/ao-space/box_info.json)
export APP_SECURITY_API_URL=http://localhost:9200/security/v1/api
export APP_BOX_KEYFINGERPRINT=$(openssl rsa -pubin -in /aospace/etc/ao-space/box_key_pub.pem -outform DER 2>/dev/null | openssl dgst -md5 -hex | awk '{print $2}')
export APP_BOX_DEPLOY_METHOD=DockerBox
export APP_PSPLATFORM_URL=https://ao.space
export APP_ACCOUNT_SYSTEM_AGENT_URL_DEVICE_INFO=http://localhost:5680/agent/v1/api/device/info
export APP_SYSTEM_AGENT_URL_DEVICE_INFO=http://localhost:5680/agent/v1/api/device/info
export APP_BOX_SUPPORT_SECURITY_CHIP=false
export APP_BOX_SUPPORT_EXTERNAL_DISK=false
export APP_BOX_BTID=$(jq -r '.btid' /aospace/etc/ao-space/box_info.json)
export APP_SSPLATFORM_URL=https://ao.space
export APP_APPSTORE_APPSIGN_URL=https://auth.apps.ao.space
export APP_APPSTORE_APPAPI_URL=https://api.apps.ao.space
export APP_BOX_VERSION=0.9.0
export APP_BOX_DEVICE_MODEL_NUMBER=-200
export APP_SYSTEM_AGENT_URL_BASE=http://localhost:5680/agent/v1/api
export APP_VERSION_TYPE=open_source

nohup java -jar -Dquarkus.http.host=0.0.0.0 /deployments/quarkus-run.jar 2>&1 &

# space-aofs
echo "starting aofs..."
export SQL_DATABASE=file
export SQL_HOST=localhost
export SQL_PORT=5432
export SQL_USER=postgres
export SQL_PASSWORD=placeholder_mysecretpassword
export REDIS_URL=localhost:6379
export REDIS_PASS=placeholder_mysecretpassword
export DATA_PATH=/data/
export NOTIFY_AMQP_URL="amqp://root:mysecretpassword@localhost:5672"
export NOTIFY_QUEUE_NAME=fileChangelogs
export NOTIFY_AMQP_ENABLE="on"
export HEAD_IMAGE_PATH=/headimage/
export PUBLIC_SHARED_INFO_FILE=shared_info.json
export GIN_MODE=release
export SENTRY_DSN=https://99fb77b329b64e10833741dc4835a94f@sentry.eulix.xyz/14
export SENTRY_RELEASE=eulixspace-fileapi@1.0.3
export SENTRY_ENVIRONMENT=release
export DISK_INFO_FILE_NAME="disk_info.json"
export DISK_PART_FOLDER_PREFIX="ao_part_"
export APP_BOX_DEPLOY_METHOD=DockerBox # agent 以 docker方式 运行在 PC 上
export ACCOUNT_URL=http://localhost:8080
export RADICALE=http://root:root@localhost:5232/root/
ln -s /aospace/etc/ao-space/meta/shared/  /shared
nohup /usr/bin/space-aofs 2>&1 &

# space-web
echo "starting space-web..."
export REDIS_HOST=localhost
export REDIS_PORT=6379
export REDIS_PASSWORD="placeholder_mysecretpassword"
export APP_RUN_NETWORK_MODE=host
export CONFIG_WEBURL==$(yq -e '.platform.webbase.url' /aospace/etc/ao-space/system-agent.yml)
nohup /docker-entrypoint.sh 2>&1 &

# space-media-vod
# echo "starting space-media-vod..."
# /usr/local/nginx/sbin/nginx
