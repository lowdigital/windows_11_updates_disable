@echo off
chcp 1251 >nul
title ��������� ���������� Windows 11
echo.
echo ========================================
echo   ��������� ���������� Windows 11
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
:: ��������� ����������� �����
sc config "wuauserv" start=auto >nul 2>&1
sc config "UsoSvc" start=auto >nul 2>&1
sc config "WaaSMedicSvc" start=manual >nul 2>&1

echo [2/4] ������ �����...
:: ������ �����
sc start "wuauserv" >nul 2>&1
sc start "UsoSvc" >nul 2>&1

echo [3/4] ������� �������� �������...
:: �������� ������� ���������� ����������
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /f >nul 2>&1

:: ��������� ���������� ���������
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" /v "DontSearchWindowsUpdate" /f >nul 2>&1

echo [4/4] �������������� �������� �����������...
:: �������� �������� ��������� �����������
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "Ethernet" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "WiFi" /f >nul 2>&1

echo.
echo =======================================
echo   ���������� Windows ������� ��������!
echo =======================================
echo.
echo ����������: ������� ������������� ������
echo �������� ���������� � ��������� �����.
echo.
pause 