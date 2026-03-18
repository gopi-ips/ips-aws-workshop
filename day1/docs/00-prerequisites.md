# Module 0 — Prerequisites

[← Back to Workshop Home](../README.md) | [Next: IAM Identity Center →](01-iam-identity-center.md)

---

Before starting any module, install and verify the tools below on your local machine.

## Required Tools

| Tool | Version | Purpose |
|---|---|---|
| AWS CLI | v2.x | All CLI commands in this workshop |
| Session Manager Plugin | Latest | SSM session support |
| An AWS Account | — | With IAM Identity Center enabled |
| jq *(optional)* | Latest | Prettify JSON output in terminal |

---

## Install AWS CLI v2

### macOS

```bash
brew install awscli
```

### Linux

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Windows (PowerShell — run as Administrator)

```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

### Verify

```bash
aws --version
# Expected: aws-cli/2.x.x Python/3.x.x ...
```

---

## Install Session Manager Plugin

The Session Manager Plugin is required for `aws ssm start-session` and for tunnelling through SSM.

### macOS

```bash
brew install --cask session-manager-plugin
```

### Linux (Ubuntu)

```bash
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
  -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

### Windows

Download and run the installer from the official AWS documentation page for Session Manager Plugin.

### Verify

```bash
session-manager-plugin
# Expected: The Session Manager plugin was installed successfully...
```

---

## Install jq (Optional)

`jq` makes it easy to parse and filter JSON output from AWS CLI commands.

```bash
# macOS
brew install jq

# Ubuntu
sudo apt-get install -y jq
```

---

## Checklist

Before moving on, confirm each item:

- [ ] `aws --version` returns version 2.x
- [ ] `session-manager-plugin` runs without error
- [ ] You have access to an AWS account where you can enable IAM Identity Center
- [ ] You have admin or power-user permissions in that account

---

[← Back to Workshop Home](../README.md) | [Next: IAM Identity Center →](01-iam-identity-center.md)
