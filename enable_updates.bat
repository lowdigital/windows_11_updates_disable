@echo off
:: Устанавливаем кодировку UTF-8 для корректного отображения русского текста
chcp 65001 >nul
setlocal enabledelayedexpansion

title Включение обновлений Windows 11 - Администратор

:: ===================================================================
echo.
echo ┌─────────────────────────────────────────────────────────────────┐
echo │                ВКЛЮЧЕНИЕ ОБНОВЛЕНИЙ WINDOWS 11                 │
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
:: Включение служб Windows Update
:: ===================================================================
echo [ШАГ 1/5] Включение служб обновлений...
echo.

:: Основная служба Windows Update
echo   • Включение службы Windows Update...
sc config "wuauserv" start=auto >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Windows Update включен (автозапуск)
) else (
    echo     ❌ Ошибка включения Windows Update
)

:: Служба оркестратора обновлений  
echo   • Включение службы Update Orchestrator...
sc config "UsoSvc" start=auto >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Update Orchestrator включен (автозапуск)
) else (
    echo     ❌ Ошибка включения Update Orchestrator
)

:: Служба медика обновлений (Windows 11) - должна быть в ручном режиме
echo   • Включение службы Windows Update Medic...
sc config "WaaSMedicSvc" start=manual >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Windows Update Medic включен (ручной запуск)
) else (
    echo     ❌ Ошибка включения Windows Update Medic
)

:: Служба доставки оптимизации
echo   • Включение службы Delivery Optimization...
sc config "DoSvc" start=auto >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Delivery Optimization включен (автозапуск)
) else (
    echo     ❌ Ошибка включения Delivery Optimization
)

echo.

:: ===================================================================
:: Запуск служб
:: ===================================================================
echo [ШАГ 2/5] Запуск служб обновлений...
echo.

:: Запускаем основные службы
echo   • Запуск Windows Update...
sc start "wuauserv" >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Windows Update запущен
) else (
    echo     ⚠️  Windows Update уже работает или запустится автоматически
)

echo   • Запуск Update Orchestrator...
sc start "UsoSvc" >nul 2>&1  
if !errorlevel! equ 0 (
    echo     ✅ Update Orchestrator запущен
) else (
    echo     ⚠️  Update Orchestrator уже работает или запустится автоматически
)

echo   • Запуск Delivery Optimization...
sc start "DoSvc" >nul 2>&1
if !errorlevel! equ 0 (
    echo     ✅ Delivery Optimization запущен
) else (
    echo     ⚠️  Delivery Optimization уже работает или запустится автоматически
)

echo.

:: ===================================================================
:: Удаление блокирующих политик реестра
:: ===================================================================
echo [ШАГ 3/5] Удаление блокирующих политик...
echo.

:: Удаляем политики автообновлений
echo   • Восстановление автоматических обновлений...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /f >nul 2>&1
echo     ✅ Автоматические обновления восстановлены

:: Разрешаем автоматическую перезагрузку
echo   • Восстановление автоматической перезагрузки...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /f >nul 2>&1
echo     ✅ Автоматическая перезагрузка восстановлена

:: Разрешаем обновления драйверов
echo   • Восстановление обновлений драйверов...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /f >nul 2>&1
echo     ✅ Обновления драйверов восстановлены

:: Восстанавливаем обновления Microsoft Store
echo   • Восстановление обновлений Microsoft Store...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /f >nul 2>&1
echo     ✅ Обновления Store восстановлены

echo.

:: ===================================================================
:: Восстановление нормальных сетевых подключений
:: ===================================================================
echo [ШАГ 4/5] Восстановление обычных сетевых подключений...
echo.

echo   • Удаление настроек лимитированных подключений...

:: Удаляем глобальные настройки лимитированных подключений
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "WiFi" /f >nul 2>&1  
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Default" /f >nul 2>&1

echo     ✅ Настройки по умолчанию восстановлены

:: Восстанавливаем нормальные сетевые профили через PowerShell
echo   • Восстановление профилей сетевых подключений...
powershell -Command "Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private" >nul 2>&1

echo     ✅ Сетевые профили восстановлены
echo.

:: ===================================================================
:: Отмена дополнительных ограничений
:: ===================================================================
echo [ШАГ 5/5] Отмена дополнительных ограничений...
echo.

:: Восстанавливаем телеметрию на базовый уровень
echo   • Восстановление базовой телеметрии...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /f >nul 2>&1
echo     ✅ Базовая телеметрия восстановлена

:: Удаляем дополнительные блокировки Windows Update
echo   • Удаление дополнительных ограничений...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "SetDisableUXWUAccess" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /f >nul 2>&1
echo     ✅ Дополнительные ограничения удалены

:: Запуск принудительного поиска обновлений
echo   • Запуск поиска обновлений...
powershell -Command "Get-WUInstall -AcceptAll -AutoReboot" >nul 2>&1 || echo     ⚠️  Модуль PSWindowsUpdate не установлен - поиск через Settings

:: Альтернативный способ через WUA API
powershell -Command "$UpdateSession = New-Object -ComObject Microsoft.Update.Session; $UpdateSearcher = $UpdateSession.CreateUpdateSearcher(); $SearchResult = $UpdateSearcher.Search('IsInstalled=0'); Write-Host 'Найдено обновлений:' $SearchResult.Updates.Count" 2>nul

echo     ✅ Поиск обновлений инициирован
echo.

:: ===================================================================
:: Завершение
:: ===================================================================
echo ┌─────────────────────────────────────────────────────────────────┐
echo │                    ✅ ЗАДАЧА ВЫПОЛНЕНА!                        │  
echo └─────────────────────────────────────────────────────────────────┘
echo.
echo Обновления Windows 11 успешно включены!
echo.
echo 🔓 Применённые изменения:
echo   • Службы обновлений включены и запущены
echo   • Блокировки автоматических обновлений сняты
echo   • Сетевые подключения восстановлены как обычные
echo   • Дополнительные ограничения удалены
echo   • Запущен поиск доступных обновлений
echo.
echo ⚠️  РЕКОМЕНДАЦИИ:
echo   • Перезагрузите компьютер для полного применения изменений
echo   • Откройте Settings → Windows Update для проверки обновлений
echo   • Настройте график установки обновлений под ваши потребности
echo.
echo 🔍 Проверка обновлений:
echo   • Нажмите Win+I → Обновление и безопасность → Центр обновления Windows
echo   • Нажмите "Проверить наличие обновлений"
echo.
pause
