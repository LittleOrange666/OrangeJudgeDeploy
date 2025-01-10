Write-Host "正在下載 docker-compose.yml..."
Remove-Item -Path "docker-compose.yml" -Force -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/LittleOrange666/OrangeJudge/refs/heads/main/docker-compose.yml" -OutFile "docker-compose.yml"

Write-Host "正在啟動..."
docker-compose up -d