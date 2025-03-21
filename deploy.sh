#!/bin/bash

cd /opt/prom

echo "##### docker login"
echo "##### docker compose down"
docker compose down --remove-orphans --volumes --rmi all > /dev/null 2>&1

echo "##### docker system prune -a -f"
docker system prune -a -f > /dev/null 2>&1

# Git 초기화 및 pull
rm -rf * .git
git init --quiet
echo "##### git pull"
git pull -q "https://github.com/dings-things/msk-monitoring-docker-compose.git"

# docker-compose.yaml 내 version 제거 (Compose V2 대응)
sed -i "/version:/d" docker-compose.yaml

# 템플릿 렌더링 (envsubst 기반)
echo "##### make render"
make render

# docker-compose up
echo "##### docker compose up -d"
docker compose --env-file .env --progress quiet up -d

echo "##### docker compose ps"
docker compose ps
