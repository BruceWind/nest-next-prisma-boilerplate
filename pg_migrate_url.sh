#!/bin/bash


# Before running the script, you need to install PostgreSQL 16 client tools. On Ubuntu, you can do this with:
#    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
#    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#    sudo apt-get update
#    sudo apt-get install sshpass postgresql-client-16



# 设置变量
SOURCE_URL="postgresql://"
DEST_URL="postgresql://user:password@192.168.50.152:5432/investment?schema=public"

# 从URL中提取信息
get_info_from_url() {
    local url=$1
    local regex="postgresql://([^:]+):([^@]+)@([^:]+):([^/]+)/([^?]+)"
    if [[ $url =~ $regex ]]; then
        echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]} ${BASH_REMATCH[4]} ${BASH_REMATCH[5]}"
    else
        echo "Invalid URL format"
        exit 1
    fi
}

SOURCE_INFO=($(get_info_from_url "$SOURCE_URL"))
DEST_INFO=($(get_info_from_url "$DEST_URL"))

# 检查目标数据库是否存在
echo "检查目标数据库是否存在..."
if PGPASSWORD=${DEST_INFO[1]} psql -h ${DEST_INFO[2]} -U ${DEST_INFO[0]} -p ${DEST_INFO[3]} -lqt | cut -d \| -f 1 | grep -qw ${DEST_INFO[4]}; then
    echo "数据库已存在，跳过创建步骤"
else
    echo "创建目标数据库..."
    PGPASSWORD=${DEST_INFO[1]} createdb -h ${DEST_INFO[2]} -U ${DEST_INFO[0]} -p ${DEST_INFO[3]} ${DEST_INFO[4]}
    if [ $? -ne 0 ]; then
        echo "创建数据库失败"
        exit 1
    fi
    echo "数据库创建成功"
fi

# 清理目标数据库中的现有表
echo "清理目标数据库中的现有表..."
PGPASSWORD=${DEST_INFO[1]} psql -h ${DEST_INFO[2]} -U ${DEST_INFO[0]} -p ${DEST_INFO[3]} -d ${DEST_INFO[4]} <<EOF
DO \$\$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END \$\$;
EOF

if [ $? -ne 0 ]; then
    echo "清理数据库失败"
    exit 1
fi

echo "数据库已清理"

# 直接从源数据库导出并导入到目标数据库
echo "开始数据迁移..."
PGPASSWORD=${SOURCE_INFO[1]} pg_dump -h ${SOURCE_INFO[2]} -U ${SOURCE_INFO[0]} -p ${SOURCE_INFO[3]} -d ${SOURCE_INFO[4]} --no-owner --no-acl | PGPASSWORD=${DEST_INFO[1]} psql -h ${DEST_INFO[2]} -U ${DEST_INFO[0]} -p ${DEST_INFO[3]} -d ${DEST_INFO[4]}

if [ $? -ne 0 ]; then
    echo "数据迁移可能有部分错误，但已完成"
else
    echo "数据迁移成功,且无错误"
