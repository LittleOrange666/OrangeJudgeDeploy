import os
import secrets
import shutil
import urllib.request

import yaml


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
        upd("judge_server","JUDGE_TOKEN", judge_token)
        upd("judge_backend","JUDGE_TOKEN", judge_token)
        db_password = secrets.token_urlsafe(21)
        upd("judge_postgres","POSTGRES_PASSWORD", db_password)
        upd("judge_backend","POSTGRES_PASSWORD", db_password)
        flask_secret_key = secrets.token_urlsafe(21)
        upd("judge_backend","FLASK_SECRET_KEY", flask_secret_key)
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
        for i, lang in enumerate(langs):
            print(f"{i + 3}. install {lang}")
        choice = input("Enter your choice: ")
        if choice == "1":
            break
        elif choice == "2":
            os.system("docker-compose up -d")
            print("Judge server started")
        elif choice.isdigit() and 3 <= int(choice) <= len(langs) + 2:
            lang = langs[int(choice) - 3]
            os.system(f"python3 OrangeJudgeLangs/{lang}.py")
        else:
            print("Invalid choice, please try again")


if __name__ == "__main__":
    main()
