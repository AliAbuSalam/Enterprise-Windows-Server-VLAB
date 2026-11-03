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
1. Checks the device running the script has an Ethernet connection.
2. Rename the device to a name listed on the config file.
3. Sets a new IP Address, its prefix length, and the default gateway for the device according to the config file.
4. Set DNS Server setting to itself using standard IPv4 loopback address
5. Restart the device to apply changes for the new device's name

## Steps
1. Open PowerShell and run it as administrator.
2. Navigate to the script directory:
```
cd "C:\path\to\your\scripts\1-initial-server-staging"
```
3. Run the script [`initial-staging.ps1`](../scripts/1-initial-server-staging/initial-staging.ps1) for initial staging of AD DS Server:
```
.\initial-staging.ps1
```
4. Wait for the script to complete.
5. Press Enter when prompted.
6. Wait for the device while it's restarting to apply changes made by the script.