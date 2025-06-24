# OrangeJudgeDeploy

這個repo提供了一鍵安裝&更新的腳本，讓你可以輕鬆的在你的伺服器上部署OrangeJudge。

需先安裝好docker和docker-compose。

install.py會把docker-compose.yml和OrangeJudgeLangs的資料夾下載到當前目錄，並且把一些參數設好。

然後可以用security tools來設定https等內容

或是呼叫OrangeJudgeLangs中的腳本來安裝語言

最後可以直接開啟伺服器