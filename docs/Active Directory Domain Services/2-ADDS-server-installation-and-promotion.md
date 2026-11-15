# 1. Prerequisites
* **Operating System**: Windows Server 2022.
* **Completed Phase 1 Staging State:**
	- **Hostname:** Updated to 'DC-01' (or the target hostname specified in 'initial-staging-config.json').
	- **Network Configuration:** Configured with a static IPv4 address and default gateway according to your network settings (default lab baseline: '192.168.50.10/24').
	- **DNS Client:** Configured with IPv4 loopback ('172.0.0.1').
* **Administrative Privileges:** Logged in with local administrative account.

# 2. Configuration & Customization
The script being used on this chapter uses the value below as its default:

```json
{
	"domainName": "corp.local",
	"domainNetBIOSName": "CORP",
	"forestMode": "WinThreshold",
	"domainMode": "WinThreshold"
}
```

# 3. Procedure

## Automated Server Installation Workflow
The script for automating installation of the ADDS [`server-installation.ps1`](../../scripts/2-server-installation/) reads the config file [`server-installation-config.json`](../../scripts/2-server-installation/server-installation-config.json) stored in the same folder and performs the following action:
1. Checks for Admin Privileges at the start of the script.
2. Checks Whether ADDS Feature is able to be installed on the device. Install said feature if it is able to be installed, stop the script if it is not able to be installed, and skip the installation if it is already installed on the device.
3. Checks whether the device can be promoted to be a Domain Controller of the new AD Forest. Skip the installation of ADDS Forest altogether if the device is already a Domain Controller, and throw an error to exit the script if the device is either not able to act as a Domain Controller or already a member of another AD Domain.
4. Install the ADDS Forest according to the configuration file and promote the device to the primary Domain Controller of the new AD Domain.
5. Restart the device once the script is finished.

## Steps
1. Before running the script, make sure that the config file is in the same folder as the script. Change the values in the config file to suit your needs.
2. Open PowerShell with admin privileges and navigate to the script directory:
```powershell
cd "C:\Path\to\your\script\2-server-installation"
```
3. Run the script [`server-installation.ps1`](../../scripts/2-server-installation/server-installation.ps1) for installing AD Forest:
```powershell
.\server-installation.ps1
```
**Note:** If the script is blocked by execution policy, refer to the [Known issues & Troubleshooting](./1-ADDS-server-staging.md#4-known-issues--troubleshooting) in [`1-ADDS-server-staging`](1-ADDS-server-staging.md).
4. A new password for the new AD Domain will be prompted later in the script. Enter and confirm a SafeModeAdministratorPassword.
5. Wait for the script to finish and press enter when prompted to restart the device.

# 4. Known Issues & Troubleshooting

## 1. Crypthography Algorithm Compatibility Warning
* **Symptoms:** While running the script, a warning will appear:
```text
WARNING: Windows Server 2022 domain controllers have a default for the security setting named "Allow cryptography algorithms compatible with Windows NT 4.0" that prevents weaker cryptography algorithms when establishing security channel sessions.
```
* **Root Cause:** During Domain Controller promotion, Windows will show the warning above informing that a setting called "Allow cryptography algorithm compatible with Windows NT 4.0" exist. This is a standard warning that shows on every Domain Controller promotion on Windows Server 2008 R2 and above.
* **Resolution:** Safe to ignore. The setting is turned off by default. Turning on the setting may compromise the security of the Domain.

## 2. DNS Delegation Warning During Domain Creation
* **Symptoms:** While running the script, a warning will appear:
```text
WARNING: A delegation for this DNS Server cannot be created because the authoritative parent zone cannot be found or it does not run windows DNS server. If your are integrating with an existing DNS infrastructure, you should manually create a delegation to this DNS server in the parent zone to ensure reliable name resolution from outside the domain "yourdomainname.local". Otherwise, no action is required.
```
* **Root Cause:** During DNS server installation, Windows will check for the parent zone of the new AD Domain to create a delegation record for the new DNS. Windows will give the warning above if it cannot create the new delegation record for multiple reasons, such as:
	- cannot find the parent zone for the newly created AD Domain.
	- cannot create a delegation record because the parent zone isn't hosted on a Windows DNS.
* **Resolution:** Safe to ignore. Since the newly created AD Domain is isolated from any other AD Domain, there wouldn't be any parent zone for the Domain.
