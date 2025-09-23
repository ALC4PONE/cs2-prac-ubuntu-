#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/server"
SERVICE_NAME="cs2-prac"

echo "=== CS2 PracTools Ubuntu Installer (Lite) ==="

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget file tar gzip bzip2 xz-utils unzip screen

sudo mkdir -p /opt/steamcmd
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sudo tar -xz -C /opt/steamcmd
sudo chmod +x /opt/steamcmd/steamcmd.sh

if [[ ! -f "$SERVER_DIR/game/bin/linuxsteamrt64/cs2" ]]; then
    echo "=== Докачиваем CS2 dedicated ==="
    /opt/steamcmd/steamcmd.sh +force_install_dir "$SERVER_DIR" +login anonymous +app_update 730 validate +quit
fi

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