#!/bin/bash

set -e

# Function to update environment variables in docker-compose.yml
update_env() {
  local service=$1
  local key=$2
  local value=$3
  if ! grep -q "environment:" <<< "${info}"; then
    info=$(echo "${info}" | yq eval ".services.${service}.environment = []" -)
  fi
  if echo "${info}" | yq eval ".services.${service}.environment[] | select(. == \"${key}=*\")" - &>/dev/null; then
    info=$(echo "${info}" | yq eval "(.services.${service}.environment[] | select(. == \"${key}=*\") ) |= \"${key}=${value}\"" -)
  else
    info=$(echo "${info}" | yq eval ".services.${service}.environment += [\"${key}=${value}\"]" -)
  fi
}

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
  echo "Downloading docker-compose.yml..."
  dc_url="https://raw.githubusercontent.com/LittleOrange666/OrangeJudge/refs/heads/main/docker-compose.yml"
  if ! curl -f -o docker-compose.yml "${dc_url}"; then
    echo "Failed to download docker-compose.yml"
    exit 1
  fi

  info=$(cat docker-compose.yml)

  # Generate secrets
  judge_token=$(openssl rand -base64 33 | tr -d '\n')
  db_password=$(openssl rand -base64 21 | tr -d '\n')
  flask_secret_key=$(openssl rand -base64 21 | tr -d '\n')

  # Update environment variables
  update_env "judge_server" "JUDGE_TOKEN" "${judge_token}"
  update_env "judge_backend" "JUDGE_TOKEN" "${judge_token}"
  update_env "judge_postgres" "POSTGRES_PASSWORD" "${db_password}"
  update_env "judge_backend" "POSTGRES_PASSWORD" "${db_password}"
  update_env "judge_backend" "FLASK_SECRET_KEY" "${flask_secret_key}"

  # Save updated docker-compose.yml
  echo "${info}" | yq eval - > docker-compose.yml
  echo "Downloaded and updated docker-compose.yml successfully"
else
  echo "docker-compose.yml already exists, skipping download"
fi

# Clone OrangeJudgeLangs repository if not exists
if [ ! -d "OrangeJudgeLangs" ]; then
  echo "Cloning OrangeJudgeLangs repository..."
  if ! git clone https://github.com/LittleOrange666/OrangeJudgeLangs.git; then
    echo "Failed to clone OrangeJudgeLangs repository"
    exit 1
  fi
  cp -r OrangeJudgeLangs/langs ./langs
  echo "Cloned OrangeJudgeLangs repository successfully"
fi

# List available languages
langs=($(ls OrangeJudgeLangs | grep -E '\.py$' | grep -v 'tools.py' | sed 's/\.py$//'))

# Menu loop
while true; do
  echo "Choose an operation:"
  echo "1. Quit"
  echo "2. Start judge"
  for i in "${!langs[@]}"; do
    echo "$((i + 3)). Install ${langs[i]}"
  done

  read -p "Enter your choice: " choice
  if [ "$choice" == "1" ]; then
    break
  elif [ "$choice" == "2" ]; then
    docker-compose up -d
    echo "Judge server started"
  elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 3 ] && [ "$choice" -le $((${#langs[@]} + 2)) ]; then
    lang=${langs[$((choice - 3))]}
    python3 "OrangeJudgeLangs/${lang}.py"
  else
    echo "Invalid choice, please try again"
  fi
done