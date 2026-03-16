# Module 3 — AWS SSM Run Command

[← Parameter Store](02-parameter-store.md) | [Back to Workshop Home](../README.md) | [Next: Session Manager →](04-session-manager.md)

---

Run Command lets you remotely execute scripts or shell commands on managed EC2 instances (and on-premises servers) — no SSH, no RDP, no open inbound security group ports required.

## How It Works

```
Your Terminal / Console
        |
        v (HTTPS outbound from SSM Agent — no inbound ports needed)
   AWS Systems Manager API
        |
        v
   SSM Agent (running on EC2 — polls SSM over HTTPS port 443)
        |
        v
   Command executes on instance as the ssm-user / SYSTEM account
        |
        v
   Output  →  Console  |  CloudWatch Logs  |  S3 Bucket
```

---

## Prerequisites

Before Run Command will work, every target EC2 instance needs:

1. **SSM Agent installed and running**
   - Pre-installed on: Ubuntu 20.04+, Ubuntu 22.04+, Windows Server 2016+
   - Check agent status: `sudo systemctl status amazon-ssm-agent`

2. **An IAM instance profile** with the `AmazonSSMManagedInstanceCore` managed policy attached.

3. **Network connectivity to SSM endpoints** — either via public internet or VPC endpoints for `ssm`, `ssmmessages`, and `ec2messages`.

Instances that satisfy all three appear in **Fleet Manager** as "Online".

---

### Attach SSM Policy to an Instance Role (CLI)

```bash
# Step 1 — Create an IAM role with EC2 as the trusted principal
aws iam create-role \
  --role-name WorkshopEC2Role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }' \
  --profile workshop

# Step 2 — Attach the AWS managed SSM policy
aws iam attach-role-policy \
  --role-name WorkshopEC2Role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore \
  --profile workshop

# Step 3 — Create an instance profile (the container EC2 uses to hold a role)
aws iam create-instance-profile \
  --instance-profile-name WorkshopEC2Profile \
  --profile workshop

# Step 4 — Link the role into the instance profile
aws iam add-role-to-instance-profile \
  --instance-profile-name WorkshopEC2Profile \
  --role-name WorkshopEC2Role \
  --profile workshop
```

---

## Console (GUI) Steps

### Run a Command on One or More Instances (GUI)

1. Open **AWS Systems Manager** → click **Run Command** in the left sidebar.
2. Click **Run command** (orange button).
3. In the **Command document** search box, type `AWS-RunShellScript` and select it.
4. Under **Command parameters**, enter your commands in the **Commands** box:
   ```
   echo "Hello from $(hostname)"
   uptime
   df -h
   free -m
   ```
5. Under **Targets**, choose one of:
   - **Choose instances manually** → tick your instance(s) from the list.
   - **Specify instance tags** → add tag filter, e.g., Key: `Environment`, Value: `workshop`.
   - **Choose a resource group** → select a pre-defined resource group.
6. Under **Output options**:
   - Enable **Write command output to an S3 bucket** (optional).
   - Enable **CloudWatch output** → enter a log group name, e.g., `/ssm/run-command`.
7. Leave **SNS notifications** and **Rate control** at defaults for now.
8. Click **Run**.

**Viewing results:**
- The results table appears with one row per targeted instance.
- Click any **Instance ID** to see the full **stdout** and **stderr** for that invocation.
- Status values: `Pending` → `InProgress` → `Success` / `Failed` / `TimedOut`.

---

## CLI Steps

### Send a Command to One Instance (CLI)

```bash
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=instanceids,Values=i-0abcd1234efgh5678" \
  --parameters '{"commands":["echo Hello from $(hostname)","uptime","df -h"]}' \
  --comment "Workshop test command" \
  --profile workshop
```

The response includes a `CommandId` — save it for status checks:

```bash
COMMAND_ID="abc12345-1234-1234-1234-abc123456789"
```

---

### Target Multiple Instances by Tag (CLI)

```bash
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=tag:Environment,Values=workshop" \
  --parameters '{"commands":["apt-get update -y && apt-get upgrade -y"]}' \
  --timeout-seconds 600 \
  --profile workshop
```

---

### Check Command Status (CLI)

```bash
# Summary status for the whole command (across all targeted instances)
aws ssm list-commands \
  --command-id "$COMMAND_ID" \
  --profile workshop

# Per-instance status with exit code details
aws ssm list-command-invocations \
  --command-id "$COMMAND_ID" \
  --details \
  --profile workshop
```

---

### Get Command Output (CLI)

```bash
aws ssm get-command-invocation \
  --command-id "$COMMAND_ID" \
  --instance-id "i-0abcd1234efgh5678" \
  --profile workshop
```

Key fields in the response:

| Field | Description |
|---|---|
| `Status` | `Success`, `Failed`, `TimedOut`, `Cancelled` |
| `ResponseCode` | Exit code from the command (0 = success) |
| `StandardOutputContent` | The stdout of your command |
| `StandardErrorContent` | The stderr of your command |

---

### Run PowerShell on Windows Instances (CLI)

```bash
aws ssm send-command \
  --document-name "AWS-RunPowerShellScript" \
  --targets "Key=instanceids,Values=i-0windows1234" \
  --parameters '{
    "commands": [
      "Get-ComputerInfo | Select-Object WindowsProductName, TotalPhysicalMemory",
      "Get-Service | Where-Object {$_.Status -eq \"Running\"} | Select-Object Name"
    ]
  }' \
  --profile workshop
```

---

### Install a Package on Ubuntu Instances (CLI)

```bash
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=tag:Environment,Values=workshop" \
  --parameters '{
    "commands": [
      "apt-get update -y",
      "apt-get install -y nginx",
      "systemctl enable nginx",
      "systemctl start nginx",
      "systemctl status nginx --no-pager"
    ]
  }' \
  --timeout-seconds 300 \
  --profile workshop
```

---

### Run a Script Stored in S3 (CLI)

```bash
# Step 1 — Upload the script to S3
aws s3 cp setup.sh s3://my-workshop-bucket/scripts/setup.sh --profile workshop

# Step 2 — Use AWS-RunRemoteScript to pull and execute it
aws ssm send-command \
  --document-name "AWS-RunRemoteScript" \
  --targets "Key=tag:Environment,Values=workshop" \
  --parameters '{
    "sourceType": ["S3"],
    "sourceInfo": ["{\"path\":\"https://s3.amazonaws.com/my-workshop-bucket/scripts/setup.sh\"}"],
    "commandLine": ["bash setup.sh"]
  }' \
  --profile workshop
```

> The instance role needs `s3:GetObject` permission on the bucket.

---

### Send Output to S3 and CloudWatch Logs (CLI)

```bash
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=tag:Environment,Values=workshop" \
  --parameters '{"commands":["cat /etc/os-release","uptime"]}' \
  --output-s3-bucket-name "my-workshop-bucket" \
  --output-s3-key-prefix "run-command-output/" \
  --cloud-watch-output-config '{
    "CloudWatchOutputEnabled": true,
    "CloudWatchLogGroupName": "/ssm/run-command"
  }' \
  --profile workshop
```

---

### Cancel a Running Command (CLI)

```bash
aws ssm cancel-command \
  --command-id "$COMMAND_ID" \
  --profile workshop

# Cancel only on specific instances
aws ssm cancel-command \
  --command-id "$COMMAND_ID" \
  --instance-ids "i-0abcd1234efgh5678" "i-0efgh5678abcd1234" \
  --profile workshop
```

---

## Rate Control

For large fleets, use rate control to avoid overwhelming instances:

```bash
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --targets "Key=tag:Environment,Values=workshop" \
  --parameters '{"commands":["apt-get update -y && apt-get upgrade -y"]}' \
  --max-concurrency "25%"  \
  --max-errors "10%"       \
  --profile workshop
```

| Parameter | Description |
|---|---|
| `--max-concurrency` | Max instances running the command at once (count or %) |
| `--max-errors` | Stop sending to new instances after this many failures |

---

[← Parameter Store](02-parameter-store.md) | [Back to Workshop Home](../README.md) | [Next: Session Manager →](04-session-manager.md)
