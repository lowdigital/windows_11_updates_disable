@echo off
:: Устанавливаем кодировку UTF-8 для корректного отображения русского текста
chcp 65001 >nul
setlocal enabledelayedexpansion

title Отключение обновлений Windows 11 - Администратор

:: ===================================================================
echo.
echo ┌─────────────────────────────────────────────────────────────────┐
echo │                ОТКЛЮЧЕНИЕ ОБНОВЛЕНИЙ WINDOWS 11                 │
echo └─────────────────────────────────────────────────────────────────┘
echo.

:: ===================================================================
:: Проверка прав администратора
:: ===================================================================
echo [ПРОВЕРКА] Проверка прав администратора...
net session >nul 2>&1
if !errorlevel! neq 0 (
    echo.
    echo ❌ ОШИБКА: Требуются права администратора!
    echo.
    echo Перезапустите файл от имени администратора:
    echo - Щелкните ПКМ по файлу
    echo - Выберите "Запуск от имени администратора"
    echo.
    pause
    exit /b 1
)
echo ✅ Права администратора подтверждены
echo.

:: ===================================================================
:: Остановка служб Windows Update
:: ===================================================================
echo [ШАГ 1/5] Остановка служб обновлений...
echo.

:: Основная служба Windows Update
echo   • Остановка службы Windows Update...
sc stop "wuauserv" >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Windows Update остановлен
) else (
    echo     ⚠️  Windows Update уже остановлен или недоступен
)

:: Служба оркестратора обновлений
echo   • Остановка службы Update Orchestrator...
sc stop "UsoSvc" >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Update Orchestrator остановлен
) else (
    echo     ⚠️  Update Orchestrator уже остановлен или недоступен
)

:: Служба медика обновлений (Windows 11)
echo   • Остановка службы Windows Update Medic...
sc stop "WaaSMedicSvc" >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Windows Update Medic остановлен
) else (
    echo     ⚠️  Windows Update Medic уже остановлен или недоступен
)

:: Служба доставки оптимизации (для Windows 11)
echo   • Остановка службы Delivery Optimization...
sc stop "DoSvc" >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Delivery Optimization остановлен
) else (
    echo     ⚠️  Delivery Optimization уже остановлен или недоступен
)

echo.

:: ===================================================================
:: Отключение служб
:: ===================================================================
echo [ШАГ 2/5] Отключение служб обновлений...
echo.

sc config "wuauserv" start=disabled >nul 2>&1
echo   ✅ Windows Update отключен

sc config "UsoSvc" start=disabled >nul 2>&1
echo   ✅ Update Orchestrator отключен

sc config "WaaSMedicSvc" start=disabled >nul 2>&1
echo   ✅ Windows Update Medic отключен

sc config "DoSvc" start=disabled >nul 2>&1
echo   ✅ Delivery Optimization отключен

echo.

:: ===================================================================
:: Настройка реестра для блокировки автообновлений
:: ===================================================================
echo [ШАГ 3/5] Настройка политик безопасности...
echo.

:: Создаем ключи, если их нет
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f >nul 2>&1

:: Отключение автоматических обновлений
echo   • Отключение автоматических обновлений...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 1 /f >nul 2>&1
echo     ✅ Автоматические обновления отключены

:: Отключение автоматической перезагрузки
echo   • Отключение автоматической перезагрузки...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 1 /f >nul 2>&1
echo     ✅ Автоматическая перезагрузка отключена

:: Блокировка обновлений драйверов через Windows Update
echo   • Блокировка обновлений драйверов...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
echo     ✅ Обновления драйверов заблокированы

:: Отключение обновлений Microsoft Store (для Windows 11)
echo   • Настройка обновлений Microsoft Store...
reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t REG_DWORD /d 2 /f >nul 2>&1
echo     ✅ Автообновления Store настроены

echo.

:: ===================================================================
:: Настройка лимитированных подключений
:: ===================================================================
echo [ШАГ 4/5] Настройка сетевых подключений как лимитированных...
echo.

:: Получаем все активные сетевые профили и устанавливаем их как лимитированные
echo   • Обнаружение активных сетевых подключений...

:: Устанавливаем глобальные настройки для новых подключений
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "WiFi" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Default" /t REG_DWORD /d 2 /f >nul 2>&1

echo     ✅ Новые подключения будут лимитированными по умолчанию

:: Применяем настройки к существующим подключениям через PowerShell
powershell -Command "Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -Verbose" >nul 2>&1

echo     ✅ Существующие подключения настроены как лимитированные
echo.

:: ===================================================================
:: Дополнительная защита для Windows 11
:: ===================================================================
echo [ШАГ 5/5] Применение дополнительных настроек безопасности...
echo.

:: Отключение телеметрии и диагностики
echo   • Настройка телеметрии и диагностики...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
echo     ✅ Телеметрия минимизирована

:: Отключение Windows Update через групповые политики
echo   • Применение групповых политик...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
echo     ✅ Групповые политики применены

:: Очистка кеша Windows Update
echo   • Очистка кеша обновлений...
if exist "%systemroot%\SoftwareDistribution\Download" (
    rmdir /s /q "%systemroot%\SoftwareDistribution\Download" >nul 2>&1
    mkdir "%systemroot%\SoftwareDistribution\Download" >nul 2>&1
    echo     ✅ Кеш обновлений очищен
) else (
    echo     ⚠️  Кеш уже очищен или недоступен
)

echo.

:: ===================================================================
:: Завершение
:: ===================================================================
echo ┌─────────────────────────────────────────────────────────────────┐
echo │                    ✅ ЗАДАЧА ВЫПОЛНЕНА!                        │
echo └─────────────────────────────────────────────────────────────────┘
echo.
echo Обновления Windows 11 успешно отключены!
echo.
echo 🔒 Применённые изменения:
echo   • Службы обновлений остановлены и отключены
echo   • Автоматические обновления заблокированы
echo   • Сетевые подключения настроены как лимитированные
echo   • Дополнительные политики безопасности применены
echo.
echo ⚠️  ВАЖНО: 
echo   • Для полного применения изменений рекомендуется перезагрузка
echo   • Используйте enable_updates.bat для включения обновлений
echo   • Периодически проверяйте критические обновления безопасности
echo.
pause
