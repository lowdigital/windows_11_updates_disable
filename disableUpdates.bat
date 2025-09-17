@echo off
chcp 1251 >nul

:: Остановка службы обновлений
echo Остановка службы Windows Update...
sc stop wuauserv
sc config wuauserv start= disabled

:: Остановка службы WaaSMedicSvc
sc stop WaaSMedicSvc
sc config WaaSMedicSvc start= disabled

:: Остановка службы Update Orchestrator
sc stop UsoSvc
sc config UsoSvc start= disabled

:: Отключение автоматических обновлений через реестр
echo Изменение реестра для отключения автоматических обновлений...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 1 /f

:: Блокировка обновлений через лимитное подключение (Wi-Fi или Ethernet)
echo Установка лимитного подключения...
netsh interface set interface name="Wi-Fi" cost=2
netsh interface set interface name="Ethernet" cost=2

:: Блокировка обновлений через планировщик заданий
echo Создание задания в планировщике для блокировки службы обновлений...
schtasks /create /tn "BlockWindowsUpdate" /tr "net stop wuauserv & sc config wuauserv start=disabled" /sc onstart /ru System

:: Настройка серверов обновлений для блокировки подключения к серверам Microsoft
echo Настройка серверов обновлений через реестр...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "UpdateServiceUrlAlternate" /t REG_SZ /d "server.wsus" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUServer" /t REG_SZ /d "server.wsus" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUStatusServer" /t REG_SZ /d "server.wsus" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "UseWUServer" /t REG_DWORD /d 1 /f

echo Обновления Windows успешно отключены!
pause
