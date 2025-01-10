# OrangeJudgeDeploy

這個repo提供了許多一鍵安裝&更新的腳本，讓你可以輕鬆的在你的伺服器上部署OrangeJudge。

install.sh/install.ps1 會順便把docker和docker-compose裝好。

only_install.sh/only_install.ps1 只會安裝OrangeJudge，不會檢查docker和docker-compose。

install_rootless.sh 會在嘗試安裝docker時，嘗試使用rootless的方式安裝docker。

此處都使用[OrangeJudge](https://github.com/LittleOrange666/OrangeJudge)根目錄的docker-compose.yml，如果你想要使用自己的docker-compose.yml，請自行修改腳本。