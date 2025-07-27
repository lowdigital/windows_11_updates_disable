@echo off
chcp 1251 >nul
title Отключение обновлений Windows 11
echo.
echo ========================================
echo   Отключение обновлений Windows 11
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

echo [1/4] Остановка служб обновлений...
:: Остановка основных служб
sc stop "wuauserv" >nul 2>&1
sc stop "UsoSvc" >nul 2>&1
sc stop "WaaSMedicSvc" >nul 2>&1

echo [2/4] Отключение служб...
:: Отключение автозапуска служб
sc config "wuauserv" start=disabled >nul 2>&1
sc config "UsoSvc" start=disabled >nul 2>&1
sc config "WaaSMedicSvc" start=disabled >nul 2>&1

echo [3/4] Настройка реестра...
:: Создание ключей политик если не существуют
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f >nul 2>&1

:: Отключение автоматических обновлений
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 1 /f >nul 2>&1

:: Отключение перезагрузки без предупреждения
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 1 /f >nul 2>&1

:: Отключение обновлений драйверов через Windows Update
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /t REG_DWORD /d 1 /f >nul 2>&1

echo [4/4] Применение настроек лимитного подключения...
:: Установка лимитного подключения для всех интерфейсов
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "WiFi" /t REG_DWORD /d 2 /f >nul 2>&1

echo.
echo =======================================
echo   Обновления Windows успешно отключены!
echo =======================================
echo.
echo Примечание: Для полного применения настроек
echo рекомендуется перезагрузить компьютер.
echo.
pause 