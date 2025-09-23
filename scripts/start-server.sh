#!/bin/bash
# cs2-prac-ubuntu/scripts/start-server.sh
# Р—Р°РїСѓСЃРєР°РµС‚ CS2 dedicated СЃРµСЂРІРµСЂ (screen РёР»Рё foreground)

SERVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/server"
CS2_EXE="$SERVER_DIR/game/bin/linuxsteamrt64/cs2"

if [[ ! -f "$CS2_EXE" ]]; then
    echo "вќЊ РЎРµСЂРІРµСЂ РЅРµ РЅР°Р№РґРµРЅ. РЎРЅР°С‡Р°Р»Р° Р·Р°РїСѓСЃС‚Рё: ./install.sh"
    exit 1
fi

echo "=== Р—Р°РїСѓСЃРєР°РµРј CS2 PracTools Server ==="
cd "$SERVER_DIR/game/bin/linuxsteamrt64"

# Р—Р°РїСѓСЃРє РІ screen (СѓРґРѕР±РЅРѕ РґР»СЏ С„РѕРЅР°)
exec cs2 -dedicated -console -usercon +game_type 0 +game_mode 1 +map de_dust2 +exec server.cfg
