if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker 沒有安裝，正在安裝 Docker..."

    Invoke-WebRequest -Uri https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe -OutFile "DockerInstaller.exe"
    Start-Process -FilePath "DockerInstaller.exe" -ArgumentList "install" -Wait
    Write-Host "Docker 安裝完成。"
} else {
    Write-Host "Docker 已經安裝！"
}

if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose 沒有安裝，正在安裝 Docker Compose..."

    $version = Invoke-RestMethod -Uri "https://api.github.com/repos/docker/compose/releases/latest" | Select-Object -ExpandProperty tag_name
    $url = "https://github.com/docker/compose/releases/download/$version/docker-compose-Windows-x86_64.exe"
    Invoke-WebRequest -Uri $url -OutFile "C:\Program Files\Docker\docker-compose.exe"

    Write-Host "Docker Compose 安裝完成。"
} else {
    Write-Host "Docker Compose 已經安裝！"
}

Write-Host "Docker 版本：$(docker --version)"
Write-Host "Docker Compose 版本：$(docker-compose --version)"

Write-Host "正在下載 docker-compose.yml..."
Remove-Item -Path "docker-compose.yml" -Force -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/LittleOrange666/OrangeJudge/refs/heads/main/docker-compose.yml" -OutFile "docker-compose.yml"

Write-Host "正在啟動..."
docker-compose up -d
