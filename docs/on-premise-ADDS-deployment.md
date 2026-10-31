# 1. Prerequisites
* **Operating System:** A fresh installation of Windows Server 2022. *note: tested exclusively on windows server 2022. steps may vary on legacy version*
* **Network Connection:** A virtual Ethernet adapter connected to isolated network.
* **Account Privileges:** Local Administrator Rights.

# 2. Configuration & Customization
The Scripts being used on this documentation relies on a configuration file. (Will add later).
By default, this documentation assumes the baseline values as follow:

```json
{
  "Hostname": "DC01",
  "IPAddress": "192.168.50.10",
  "PrefixLength": 24,
  "defaultGateway": "192.168.50.1",
  "DNSServer": "127.0.0.1"
}
```
The values above will also be used on subsequent documentations unless stated otherwise.

# 3. Procedure

## Automated Staging Workflow
The staging script (will add later)