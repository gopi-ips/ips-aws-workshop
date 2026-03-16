# Module 5 — AWS SSM State Manager

[← Session Manager](04-session-manager.md) | [Back to Workshop Home](../README.md) | [Next: Cleanup →](06-cleanup.md)

---

State Manager ensures your EC2 instances **continuously** maintain a defined configuration. It uses **Associations** that automatically re-apply configuration on a schedule — so drift is corrected without manual intervention.

## Key Concepts

| Concept | Description |
|---|---|
| **Association** | Binds a document + targets + schedule + parameters |
| **Document** | The desired-state definition (AWS-managed or custom) |
| **Schedule** | `rate()` or `cron()` expression |
| **Target** | Instances matched by ID, tag, or resource group |

### Schedule Expression Examples

| Expression | Meaning |
|---|---|
| `rate(30 minutes)` | Every 30 minutes |
| `rate(1 hour)` | Every hour |
| `rate(7 days)` | Every 7 days |
| `cron(0 2 ? * SUN *)` | Every Sunday at 2:00 AM UTC |
| `cron(0 4 1 * ? *)` | First day of every month at 4:00 AM UTC |

---

## Console (GUI) Steps

### Create an Association

1. Open **Systems Manager → State Manager**.
2. Click **Create association**.
3. **Name**: `workshop-keep-ssm-agent-updated`
4. **Document**: search and select `AWS-UpdateSSMAgent`
5. **Parameters**: leave `version` as `Latest`
6. **Targets**: choose **Specify instance tags** → Key: `Environment`, Value: `workshop`
7. **Schedule**: select **Rate schedule** → Value: `14`, Unit: `Days`
8. Click **Create association**.

---

### Manually Trigger an Association

1. Select the association checkbox.
2. Click **Apply association now** → confirm.

---

### View Execution History

1. Click the association name.
2. Click the **Execution history** tab.
3. Click any **Execution ID** to see per-instance results.

---

### Edit an Association

1. Select the association → click **Edit**.
2. Change the schedule, targets, or parameters.
3. Click **Save changes**.

---

### Delete an Association

1. Select the association checkbox → click **Delete** → confirm.

---

## CLI Steps

> Run `export AWS_PROFILE=workshop` once to avoid adding `--profile workshop` to every command.

### Create an Association — Keep SSM Agent Updated

```bash
aws ssm create-association \
  --name "AWS-UpdateSSMAgent" \
  --association-name "workshop-keep-ssm-agent-updated" \
  --targets "Key=tag:Environment,Values=workshop" \
  --schedule-expression "rate(14 days)" \
  --profile workshop
```

---

### Create an Association — Install CloudWatch Agent

```bash
aws ssm create-association \
  --name "AWS-RunShellScript" \
  --association-name "workshop-install-cloudwatch-agent" \
  --targets "Key=tag:Environment,Values=workshop" \
  --parameters '{
    "commands": [
      "apt-get update -y",
      "apt-get install -y amazon-cloudwatch-agent",
      "systemctl enable amazon-cloudwatch-agent",
      "systemctl start amazon-cloudwatch-agent"
    ]
  }' \
  --schedule-expression "rate(30 days)" \
  --profile workshop
```

---

### Create an Association — Monthly Patching

```bash
aws ssm create-association \
  --name "AWS-RunPatchBaseline" \
  --association-name "workshop-monthly-patching" \
  --targets "Key=tag:PatchGroup,Values=workshop" \
  --parameters '{"Operation":["Install"]}' \
  --schedule-expression "cron(0 2 ? * SUN *)" \
  --max-concurrency "20%" \
  --max-errors "10%" \
  --profile workshop
```

---

### List Associations

```bash
aws ssm list-associations --profile workshop
```

---

### Get Association Details

```bash
ASSOC_ID="aabbccdd-1234-5678-abcd-1234567890ab"

aws ssm describe-association \
  --association-id "$ASSOC_ID" \
  --profile workshop
```

---

### Manually Trigger an Association

```bash
aws ssm start-associations-once \
  --association-ids "$ASSOC_ID" \
  --profile workshop
```

---

### View Execution History

```bash
# All past executions
aws ssm describe-association-executions \
  --association-id "$ASSOC_ID" \
  --profile workshop

# Per-instance results for a specific execution
EXECUTION_ID="exec-0abc123def456789"

aws ssm describe-association-execution-targets \
  --association-id "$ASSOC_ID" \
  --execution-id "$EXECUTION_ID" \
  --profile workshop
```

---

### Update an Association

```bash
# Change the schedule
aws ssm update-association \
  --association-id "$ASSOC_ID" \
  --schedule-expression "rate(7 days)" \
  --profile workshop

# Change targets
aws ssm update-association \
  --association-id "$ASSOC_ID" \
  --targets "Key=tag:Environment,Values=production" \
  --profile workshop
```

---

### Delete an Association

```bash
aws ssm delete-association \
  --association-name "workshop-keep-ssm-agent-updated" \
  --profile workshop
```

---

### Create a Custom Document and Associate It

```bash
# Step 1 — Write the document
cat > enforce-motd.json << 'EOF'
{
  "schemaVersion": "2.2",
  "description": "Enforce /etc/motd on all managed instances",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "setMotd",
      "inputs": {
        "runCommand": [
          "echo 'Managed workshop instance. Unauthorized access is prohibited.' > /etc/motd"
        ]
      }
    }
  ]
}
EOF

# Step 2 — Register the document
aws ssm create-document \
  --name "Workshop-EnforceMotd" \
  --document-type "Command" \
  --document-format "JSON" \
  --content file://enforce-motd.json \
  --profile workshop

# Step 3 — Create the association (runs every hour)
aws ssm create-association \
  --name "Workshop-EnforceMotd" \
  --association-name "workshop-enforce-motd" \
  --targets "Key=tag:Environment,Values=workshop" \
  --schedule-expression "rate(1 hour)" \
  --profile workshop
```

---

[← Run Command](03-run-command.md) | [Back to Workshop Home](../README.md) | [Next: Cleanup →](05-cleanup.md)
