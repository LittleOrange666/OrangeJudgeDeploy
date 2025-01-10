#!/bin/bash

echo "正在下載 docker-compose.yml..."
rm -f docker-compose.yml
wget https://raw.githubusercontent.com/LittleOrange666/OrangeJudge/refs/heads/main/docker-compose.yml

echo "正在啟動..."
docker-compose up -d