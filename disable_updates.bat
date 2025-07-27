@echo off
chcp 1251 >nul
title ���������� ���������� Windows 11
echo.
echo ========================================
echo   ���������� ���������� Windows 11
echo ========================================
echo.

:: �������� ���� ��������������
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ������: ��������� �� ����� ��������������!
    echo.
    pause
    exit /b 1
)

echo [1/4] ��������� ����� ����������...
:: ��������� �������� �����
sc stop "wuauserv" >nul 2>&1
sc stop "UsoSvc" >nul 2>&1
sc stop "WaaSMedicSvc" >nul 2>&1

echo [2/4] ���������� �����...
:: ���������� ����������� �����
sc config "wuauserv" start=disabled >nul 2>&1
sc config "UsoSvc" start=disabled >nul 2>&1
sc config "WaaSMedicSvc" start=disabled >nul 2>&1

echo [3/4] ��������� �������...
:: �������� ������ ������� ���� �� ����������
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f >nul 2>&1

:: ���������� �������������� ����������
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 1 /f >nul 2>&1

:: ���������� ������������ ��� ��������������
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 1 /f >nul 2>&1

:: ���������� ���������� ��������� ����� Windows Update
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /t REG_DWORD /d 1 /f >nul 2>&1

echo [4/4] ���������� �������� ��������� �����������...
:: ��������� ��������� ����������� ��� ���� �����������
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "WiFi" /t REG_DWORD /d 2 /f >nul 2>&1

echo.
echo =======================================
echo   ���������� Windows ������� ���������!
echo =======================================
echo.
echo ����������: ��� ������� ���������� ��������
echo ������������� ������������� ���������.
echo.
pause 