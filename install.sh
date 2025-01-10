#!/bin/bash

if ! command -v docker &> /dev/null
then
    echo "Docker 沒有安裝，正在安裝 Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker 已經安裝！"
fi

if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose 沒有安裝，正在安裝 Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose 已經安裝！"
fi

echo "Docker 版本：$(docker --version)"
echo "Docker Compose 版本：$(docker-compose --version)"

echo "正在下載 docker-compose.yml..."
rm -f docker-compose.yml
wget https://raw.githubusercontent.com/LittleOrange666/OrangeJudge/refs/heads/main/docker-compose.yml
docker-compose up -d