# 1. Prerequisites
* **Operating System:** A fresh installation of Windows Server 2022. *note: tested exclusively on windows server 2022. steps may vary on legacy version*
* **Network Connection:** A virtual Ethernet adapter connected to isolated network.
* **Account Privileges:** Local Administrator Rights.

# 2. Configuration & Customization
The Scripts being used on this documentation relies on a configuration file.
By default, this documentation assumes the baseline values as follow:

```json
{
  "Hostname": "DC01",
  "IPAddress": "192.168.50.10",
  "PrefixLength": 24,
  "defaultGateway": "192.168.50.1"
}
```
The values above will also be used on subsequent documentations unless stated otherwise.

# 3. Procedure

## Automated Staging Workflow
The staging script [`initial-staging.ps1`](../scripts/1-initial-server-staging/initial-staging.ps1) reads the config file [`initial-staging-config.json`](../scripts/1-initial-server-staging/initial-staging-config.json) stored in the same folder and performs the following actions:
1. Checks whether the script is being executed with admin privileges.
2. Checks the device running the script has an Ethernet connection.
3. Checks whether the device has different hostname to the one listed in the config file. If so, rename the device to a name listed on the config file.
4. Checks for current IP Address, prefix length, and default gateway and change them if there's any need to change according to the config file.
5. Set DNS Server setting to itself using standard IPv4 loopback address
6. Restart the device to apply changes for the new device's name
7. If any Errors occur in the middle of the script, a custom error handler is going to handle it and terminate the script.

## Steps
1. Open PowerShell and run it as administrator.
2. Navigate to the script directory:
```
cd "C:\path\to\your\scripts\1-initial-server-staging"
```
3. Run the script [`initial-staging.ps1`](../scripts/1-initial-server-staging/initial-staging.ps1) for initial staging of AD DS Server:
```powershell
.\initial-staging.ps1
```
if the script execution is blocked by execution policy, run the following:
``` powershell
powershell.exe -ExecutionPolicy Bypass -File .\initial-staging.ps1
```
4. Wait for the script to complete.
5. Press Enter when prompted.
6. Wait for the device while it's restarting to apply changes made by the script.

# 4. Known Issues & Troubleshooting

## 1. Script Execution Blocked by Unsigned Policy
* **Symptom:** Running ['.\initial-staging.ps1'] directly from a hypervisor shared folders returns an error stating that the script cannot be loaded because it is not digitally signed.
* **Root Cause:** Running a script directly from a hypervisor is considered running the script remotely. Which under RemoteSigned execution policy is restricted if the script isn't signed.
* **Resolution:** Either copy the script from the hypervisor shared locations to the VM's local storage before running, or bypass the execution policy altogether before running the script by using: 
```powershell
powershell.exe -ExecutionPolicy Bypass -File "\\VBoxSvr\location\of\the\shared\folders\initial-staging.ps1"
```