# F:\cs2-prac-server\scripts\download-maps.ps1
# Скачивает ВСЕ популярные тренировочные карты (кроме Dust2) через SteamCMD

$SteamCmdDir = "F:\steamcmd"
$ServerDir   = "F:\cs2-prac-server\server"
$WorkshopDir = "$ServerDir\game\csgo\maps\workshop"

# Создаём папку для карт
New-Item -ItemType Directory -Force -Path $WorkshopDir | Out-Null

# Список карт (ID из Workshop)
$maps = @(
    3074998547, # Training Mirage Guide
    3074998548, # Training Inferno Guide
    3074998546, # Training Dust2 Guide
    3075807032, # Nuke Utility
    3071538919, # 5E Prac Mirage Prefire
    3071538919  # DHL CT Defense Training (универсальный ID)
)

Write-Host "=== Качаем тренировочные карты ===" -ForegroundColor Green
foreach ($id in $maps) {
    Write-Host "  -> Workshop $id"
    & "$SteamCmdDir\steamcmd.exe" +force_install_dir $ServerDir +login anonymous +workshop_download_item 730 $id validate +quit
}

# Копируем .bsp в удобную папку
Get-ChildItem -Path "$ServerDir\steamapps\workshop\content\730" -Recurse -Filter *.bsp |
    Copy-Item -Destination $WorkshopDir -Force

# Добавляем карты в mapcycle.txt
$mapcycle = @(
    "de_dust2", "de_mirage", "de_inferno", "de_nuke", "de_overpass",
    "de_ancient", "de_vertigo", "de_anubis",
    "workshop\3074998547", "workshop\3074998548", "workshop\3074998546",
    "workshop\3075807032", "workshop\3071538919"
)
$mapcycle | Out-File "$ServerDir\game\csgo\mapcycle.txt" -Encoding UTF8

Write-Host "=== Готово! Карты лежат в $WorkshopDir ===" -ForegroundColor Green