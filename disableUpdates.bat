﻿@echo off
chcp 1251 >nul

:: ��������� ������ ����������
echo ��������� ������ Windows Update...
sc stop wuauserv
sc config wuauserv start= disabled

:: ��������� ������ WaaSMedicSvc
sc stop WaaSMedicSvc
sc config WaaSMedicSvc start= disabled

:: ��������� ������ Update Orchestrator
sc stop UsoSvc
sc config UsoSvc start= disabled

:: ���������� �������������� ���������� ����� ������
echo ��������� ������� ��� ���������� �������������� ����������...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d 1 /f

:: ���������� ���������� ����� �������� ����������� (Wi-Fi ��� Ethernet)
echo ��������� ��������� �����������...
netsh interface set interface name="Wi-Fi" cost=2
netsh interface set interface name="Ethernet" cost=2

:: ���������� ���������� ����� ����������� �������
echo �������� ������� � ������������ ��� ���������� ������ ����������...
schtasks /create /tn "BlockWindowsUpdate" /tr "net stop wuauserv & sc config wuauserv start=disabled" /sc onstart /ru System

:: ��������� �������� ���������� ��� ���������� ����������� � �������� Microsoft
echo ��������� �������� ���������� ����� ������...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "UpdateServiceUrlAlternate" /t REG_SZ /d "server.wsus" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUServer" /t REG_SZ /d "server.wsus" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUStatusServer" /t REG_SZ /d "server.wsus" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "UseWUServer" /t REG_DWORD /d 1 /f

echo ���������� Windows ������� ���������!
pause
