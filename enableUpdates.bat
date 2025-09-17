@echo off
chcp 1251 >nul

:: �������� ���� ��������������
net session >nul 2>&1 || (
    echo ��������� ���� �� ����� ��������������.
    pause
    exit /b
)

:: ��������� ������ Windows Update
echo ��������� ������ Windows Update...
sc config wuauserv start= auto
sc query wuauserv | find "RUNNING" >nul || sc start wuauserv

:: WaaSMedicSvc � ���������� (���������� ������, �� ������� ���������)

:: ��������� ������ Update Orchestrator
echo ��������� ������ Update Orchestrator...
sc config UsoSvc start= auto
sc query UsoSvc | find "RUNNING" >nul || sc start UsoSvc

:: �������������� �������� ������� ��� �������������� ����������
echo �������������� �������� ������� ��� �������������� ����������...
for %%a in (NoAutoUpdate AUOptions NoAutoRebootWithLoggedOnUsers UseWUServer) do (
    reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "%%a" >nul 2>&1 && (
        reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "%%a" /f
    )
)

:: ��������� ���������� � ����� ��������� �����������
echo ����� �������� ��������� �����������...
set Key="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost"
reg add %Key% /v WiFi /t REG_DWORD /d 1 /f >nul 2>&1
if errorlevel 1 (
    echo ��������� ���� ������� � �������...
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

:: �������� ������� � ������������ ����� ��� ���������� ����������
echo �������� ������� � ������������ ����� ��� ���������� ����������...
schtasks /query /tn "BlockWindowsUpdate" >nul 2>&1 && (
    schtasks /delete /tn "BlockWindowsUpdate" /f
) || echo ������� "BlockWindowsUpdate" �� �������.

:: �������������� �������� ���������� �� ���������
echo �������������� �������� ���������� �� ���������...
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
echo ���������� Windows ������� �������������!
pause
