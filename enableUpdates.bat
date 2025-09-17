@echo off
chcp 1251 >nul

:: Проверка прав администратора
net session >nul 2>&1 || (
    echo Запустите файл от имени администратора.
    pause
    exit /b
)

:: Включение службы Windows Update
echo Включение службы Windows Update...
sc config wuauserv start= auto
sc query wuauserv | find "RUNNING" >nul || sc start wuauserv

:: WaaSMedicSvc — пропускаем (защищённая служба, не требует настройки)

:: Включение службы Update Orchestrator
echo Включение службы Update Orchestrator...
sc config UsoSvc start= auto
sc query UsoSvc | find "RUNNING" >nul || sc start UsoSvc

:: Восстановление настроек реестра для автоматических обновлений
echo Восстановление настроек реестра для автоматических обновлений...
for %%a in (NoAutoUpdate AUOptions NoAutoRebootWithLoggedOnUsers UseWUServer) do (
    reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "%%a" >nul 2>&1 && (
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "%%a" /f
    )
)

:: Изменение разрешений и сброс лимитного подключения
echo Сброс настроек лимитного подключения...
set Key="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost"
reg add %Key% /v WiFi /t REG_DWORD /d 1 /f >nul 2>&1
if errorlevel 1 (
    echo Изменение прав доступа к реестру...
    regini.exe "%temp%\regini.txt" >nul 2>&1
    (
        echo HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost [1 5 7 11 17]
    ) > "%temp%\regini.txt"
    regini.exe "%temp%\regini.txt"
    del "%temp%\regini.txt"
    reg delete %Key% /v WiFi /f
    reg delete %Key% /v Ethernet /f
) else (
    reg delete %Key% /v WiFi /f
    reg delete %Key% /v Ethernet /f
)

:: Удаление задания в планировщике задач для блокировки обновлений
echo Удаление задания в планировщике задач для блокировки обновлений...
schtasks /query /tn "BlockWindowsUpdate" >nul 2>&1 && (
    schtasks /delete /tn "BlockWindowsUpdate" /f
) || echo Задание "BlockWindowsUpdate" не найдено.

:: Восстановление серверов обновлений по умолчанию
echo Восстановление серверов обновлений по умолчанию...
for %%b in (
    "DoNotConnectToWindowsUpdateInternetLocations"
    "UpdateServiceUrlAlternate"
    "WUServer"
    "WUStatusServer"
) do (
    reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v %%b >nul 2>&1 && (
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v %%b /f
    )
)

echo.
echo Обновления Windows успешно восстановлены!
pause
