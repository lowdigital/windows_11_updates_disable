@echo off
chcp 1251 >nul
title Включение обновлений Windows 11
echo.
echo ========================================
echo   Включение обновлений Windows 11
echo ========================================
echo.

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ОШИБКА: Запустите от имени администратора!
    echo.
    pause
    exit /b 1
)

echo [1/4] Включение служб обновлений...
:: Включение автозапуска служб
sc config "wuauserv" start=auto >nul 2>&1
sc config "UsoSvc" start=auto >nul 2>&1
sc config "WaaSMedicSvc" start=manual >nul 2>&1

echo [2/4] Запуск служб...
:: Запуск служб
sc start "wuauserv" >nul 2>&1
sc start "UsoSvc" >nul 2>&1

echo [3/4] Очистка настроек реестра...
:: Удаление политик отключения обновлений
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /f >nul 2>&1

:: Включение обновлений драйверов
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /f >nul 2>&1

echo [4/4] Восстановление обычного подключения...
:: Удаление настроек лимитного подключения
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "WiFi" /f >nul 2>&1

echo.
echo =======================================
echo   Обновления Windows успешно включены!
echo =======================================
echo.
echo Примечание: Система автоматически начнет
echo проверку обновлений в ближайшее время.
echo.
pause 