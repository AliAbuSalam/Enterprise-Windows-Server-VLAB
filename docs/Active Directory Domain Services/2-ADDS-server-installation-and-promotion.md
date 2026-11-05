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
	"forestMode": "Win2026",
	"domainMode": "Win2026"
}
```
# 3. Procedure
