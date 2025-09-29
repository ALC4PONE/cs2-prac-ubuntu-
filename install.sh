#!/bin/bash
# cs2-prac-ubuntu/install.sh (авторизованный, безопасный)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"
SERVICE_NAME="cs2-prac"

# 1. Читаем логин/пароль из окружения (если есть)
STEAM_LOGIN="${STEAM_LOGIN:-}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"

# 2. Если нет – спрашиваем
if [[ -z "$STEAM_LOGIN" ]]; then
    read -p "🔐 Steam логин: " STEAM_LOGIN
fi
if [[ -z "$STEAM_PASSWORD" ]]; then
    read -sp "🔐 Steam пароль: " STEAM_PASSWORD
    echo
fi

# 3. Запрашиваем Guard-код
read -p "🔐 Steam Guard-код: " GUARD_CODE

# 4. Устанавливаем зависимости
sudo apt update && sudo apt install -y curl wget file tar gzip bzip2 xz-utils unzip screen
sudo mkdir -p /opt/steamcmd
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sudo tar -xz -C /opt/steamcmd
sudo chmod +x /opt/steamcmd/steamcmd.sh

# 5. Докачиваем CS2 (авторизованно)
echo "=== Докачиваем CS2 dedicated (авторизованно) ==="
/opt/steamcmd/steamcmd.sh +force_install_dir "$SERVER_DIR" +login "$STEAM_LOGIN" "$STEAM_PASSWORD" "$GUARD_CODE" +app_update 730 validate +quit

# 6. Создаём пользователя и systemd
sudo useradd -m -s /bin/bash cs2-prac || true
sudo chown -R cs2-prac:cs2-prac "$SCRIPT_DIR"

sudo tee /etc/systemd/system/cs2-prac-server.service > /dev/null <<EOF
[Unit]
Description=CS2 PracTools Server (Lite)
After=network.target

[Service]
Type=simple
User=cs2-prac
WorkingDirectory=$SERVER_DIR/game/bin/linuxsteamrt64
ExecStart=$SERVER_DIR/game/bin/linuxsteamrt64/cs2 -dedicated -console -usercon +game_type 0 +game_mode 1 +map de_dust2 +exec server.cfg
Restart=on-failure
RestartSec=10
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cs2-prac-server.service

echo "=== Готово! ==="
echo "Запуск:          sudo systemctl start cs2-prac-server"
echo "Логи:            sudo journalctl -u cs2-prac-server -f"
echo "Команды в игре:  F4, F5-F8, !rec_start, !addpos, !goto"
