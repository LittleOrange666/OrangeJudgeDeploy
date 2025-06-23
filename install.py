import os
import secrets
import shutil
import urllib.request

import yaml
from scipy.signal import wiener


def security_tools():
    while True:
        print("Choose a operation:")
        print("1. Go back")
        print("2. Remove exposed ports")
        print("3. Add cloudflare proxy (need tunnel token)")
        choice = input("Enter your choice: ")
        with open("docker-compose.yml", encoding="utf8") as f:
            info = yaml.load(f, Loader=yaml.FullLoader)
        if choice == "1":
            pass
        elif choice == "2":
            if not os.path.exists("docker-compose.yml"):
                print("docker-compose.yml not found.")
                break
            for service in info["services"]:
                if "judge_backend" != service and "ports" in info["services"][service]:
                    del info["services"][service]["ports"]
            print("Removed exposed ports from all services except judge_backend")
        elif choice == "3":
            token = input("Enter your cloudflare tunnel token: ")
            template = {
                "image": "cloudflare/cloudflared:latest",
                "restart": "unless-stopped",
                "command": "tunnel --url http://judge_backend:8080 --no-autoupdate run",
                "environment": [
                    f"TUNNEL_TOKEN={token}"
                ],
                "depends_on": {
                    "judge_backend": {
                        "condition": "service_healthy"
                    }
                }
            }
            info["services"]["cloudflare"] = template
            print("Added cloudflare proxy service to docker-compose.yml")
        else:
            print("Invalid choice, please try again")
            continue
        with open("docker-compose.yml", "w", encoding="utf8") as f:
            yaml.dump(info, f)
        break


def main():
    if not os.path.exists("docker-compose.yml"):
        dc_url = "https://raw.githubusercontent.com/LittleOrange666/OrangeJudge/refs/heads/main/docker-compose.yml"
        try:
            with urllib.request.urlopen(dc_url) as response:
                if response.status != 200:
                    print("Failed to download docker-compose.yml")
                    return
                dc_text = response.read().decode("utf-8")
                info = yaml.load(dc_text, Loader=yaml.FullLoader)
        except Exception as e:
            print(f"Error occurred: {e}")
            return

        def upd(s, k, v):
            if "environment" not in info["services"][s]:
                info["services"][s]["environment"] = []
            l = info["services"][s]["environment"]
            for i in range(len(l)):
                if l[i].startswith(k + "="):
                    l[i] = k + "=" + v
                    return
            l.append(k + "=" + v)

        judge_token = secrets.token_urlsafe(33)
        upd("judge_server", "JUDGE_TOKEN", judge_token)
        upd("judge_backend", "JUDGE_TOKEN", judge_token)
        db_password = secrets.token_urlsafe(21)
        upd("judge_mariadb", "MYSQL_PASSWORD", db_password)
        upd("judge_mariadb", "MYSQL_ROOT_PASSWORD", secrets.token_urlsafe(21))
        upd("judge_backend", "MYSQL_PASSWORD", db_password)
        flask_secret_key = secrets.token_urlsafe(21)
        upd("judge_backend", "FLASK_SECRET_KEY", flask_secret_key)
        with open("docker-compose.yml", "w", encoding="utf8") as f:
            yaml.dump(info, f)
        print("Download docker-compose.yml successfully")
    else:
        print("docker-compose.yml already exists, skipping download")
    if not os.path.exists("OrangeJudgeLangs"):
        os.system("git clone https://github.com/LittleOrange666/OrangeJudgeLangs.git")
        if not os.path.exists("OrangeJudgeLangs"):
            print("Failed to clone OrangeJudgeLangs repository")
            return
        shutil.copytree("OrangeJudgeLangs/langs", "./langs", dirs_exist_ok=True)
        print("Clone OrangeJudgeLangs repository successfully")
    langs = [f[:-3] for f in os.listdir("OrangeJudgeLangs") if f.endswith(".py") and f != "tools.py"]
    while True:
        print("Choose a operation:")
        print("1. Quit")
        print("2. start judge")
        print("3. security tools")
        for i, lang in enumerate(langs):
            print(f"{i + 4}. install {lang}")
        choice = input("Enter your choice: ")
        if choice == "1":
            break
        elif choice == "2":
            os.system("docker-compose up -d")
            print("Judge server started")
        elif choice == "3":
            security_tools()
        elif choice.isdigit() and 4 <= int(choice) <= len(langs) + 3:
            lang = langs[int(choice) - 4]
            os.system(f"python3 OrangeJudgeLangs/{lang}.py")
        else:
            print("Invalid choice, please try again")


if __name__ == "__main__":
    main()
