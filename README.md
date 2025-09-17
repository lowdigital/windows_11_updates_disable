# Windows 11 Updates Switch

A collection of powerful batch scripts to easily enable or disable Windows 11 automatic updates with comprehensive system modifications.

## 📋 Overview

This project provides two main utilities:
- **`disable_updates.bat`** - Completely disables Windows 11 automatic updates
- **`enable_updates.bat`** - Re-enables Windows 11 automatic updates

These scripts perform deep system modifications including service management, registry tweaks, network profile adjustments, and security policy changes to provide complete control over Windows Update behavior.

## ⚡ Features

### Disable Updates (`disable_updates.bat`)
- **Service Management**: Stops and disables Windows Update services
  - Windows Update Service (`wuauserv`)
  - Update Orchestrator Service (`UsoSvc`)
  - Windows Update Medic Service (`WaaSMedicSvc`)
  - Delivery Optimization Service (`DoSvc`)

- **Registry Modifications**: 
  - Disables automatic updates via Group Policy
  - Blocks automatic reboots
  - Prevents driver updates through Windows Update
  - Configures Microsoft Store auto-update settings

- **Network Configuration**: 
  - Sets network connections as metered to prevent automatic downloads
  - Applies default metered connection policies

- **Additional Security**:
  - Minimizes telemetry data collection
  - Applies comprehensive Group Policy restrictions
  - Clears Windows Update cache

### Enable Updates (`enable_updates.bat`)
- **Service Restoration**: Enables and starts all Windows Update services
- **Registry Cleanup**: Removes all blocking registry entries
- **Network Restoration**: Restores normal (non-metered) network profiles
- **Policy Reversal**: Removes Group Policy restrictions
- **Update Initiation**: Triggers automatic update search

## 🚀 Usage

### Prerequisites
- Windows 11 operating system
- Administrator privileges required
- PowerShell execution policy allowing script execution

### Installation & Usage

1. **Download the scripts** to your local machine
2. **Right-click** on the desired script file
3. Select **"Run as administrator"**
4. Follow the on-screen instructions

#### To Disable Updates:
```bash
# Right-click and select "Run as administrator"
disable_updates.bat
```

#### To Enable Updates:
```bash
# Right-click and select "Run as administrator"  
enable_updates.bat
```

## ⚠️ Important Warnings

### Before Using These Scripts:

1. **Administrator Rights**: Both scripts require administrator privileges to modify system services and registry
2. **System Backup**: Create a system restore point before running these scripts
3. **Security Risk**: Disabling updates may leave your system vulnerable to security threats
4. **Manual Updates**: When updates are disabled, you should periodically check for critical security updates manually
5. **System Restart**: A system reboot is recommended after running either script for full effect

### What These Scripts Modify:

- **Windows Services**: Stops/starts and enables/disables system services
- **Windows Registry**: Modifies Group Policy and system configuration entries
- **Network Profiles**: Changes connection metering settings
- **System Cache**: Clears Windows Update download cache
- **Telemetry Settings**: Adjusts data collection policies

## 🛠️ Technical Details

### Modified Services:
- `wuauserv` - Windows Update Service
- `UsoSvc` - Update Orchestrator Service  
- `WaaSMedicSvc` - Windows Update Medic Service
- `DoSvc` - Delivery Optimization Service

### Registry Keys Modified:
- `HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU`
- `HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata`
- `HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching`
- `HKLM\SOFTWARE\Policies\Microsoft\WindowsStore`
- `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost`

### PowerShell Commands Used:
- Network profile management via `Get-NetConnectionProfile`
- Windows Update API interaction for update detection

## 🔧 Troubleshooting

### Common Issues:

1. **"Access Denied" Error**: Ensure you're running as administrator
2. **Scripts Don't Work**: Check if PowerShell execution policy allows script execution
3. **Updates Still Installing**: Restart your computer after running the disable script
4. **Can't Re-enable**: Run the enable script as administrator and restart

### Manual Verification:

After running scripts, you can verify changes in:
- **Services**: `services.msc` - Check Windows Update service status
- **Group Policy**: `gpedit.msc` - Computer Configuration → Windows Update
- **Network Settings**: Settings → Network → Properties → Metered connection

## 🔄 Reverting Changes

The `enable_updates.bat` script is designed to completely reverse all changes made by `disable_updates.bat`. If you encounter any issues, you can:

1. Run `enable_updates.bat` as administrator
2. Restart your computer
3. Manually check Windows Update in Settings
4. Create a system restore point and restore to a previous state if needed

## 🎯 Use Cases

- **Testing Environments**: Prevent unwanted updates during system testing
- **Production Systems**: Control update timing for critical systems
- **Bandwidth Management**: Prevent automatic downloads on metered connections
- **Legacy Application Compatibility**: Avoid updates that might break older software
- **Maintenance Windows**: Schedule updates during planned maintenance periods

## 📝 Notes

- Scripts include comprehensive error checking and user feedback
- UTF-8 encoding ensures proper display of international characters
- Detailed progress indicators show exactly what changes are being made
- Both scripts are fully reversible - no permanent system damage

## License

This project is licensed under the MIT License.

## Author

Follow updates on my Telegram channel: **[low digital](https://t.me/low_digital)**

---

**⚠️ Use at your own risk. Always create a system backup before making system modifications.**
