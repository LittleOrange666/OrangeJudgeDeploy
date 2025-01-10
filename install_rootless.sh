#!/bin/bash

if ! command -v docker &> /dev/null
then
    echo "Docker 沒有安裝，正在安裝 Docker..."
    curl -fsSL https://get.docker.com/rootless | sh
    systemctl --user daemon-reload
    systemctl --user restart docker
else
    echo "Docker 已經安裝！"
fi

if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose 沒有安裝，正在安裝 Docker Compose..."
    curl -SL https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m) -o ~/bin/docker-compose
    chmod +x ~/bin/docker-compose
else
    echo "Docker Compose 已經安裝！"
fi

echo "Docker 版本：$(docker --version)"
echo "Docker Compose 版本：$(docker-compose --version)"

export PATH=$HOME/bin:$PATH
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

echo "正在下載 docker-compose.yml..."
rm -f docker-compose.yml
wget https://raw.githubusercontent.com/LittleOrange666/OrangeJudge/refs/heads/main/docker-compose.yml

echo "正在啟動..."
docker-compose up -d