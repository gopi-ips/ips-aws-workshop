# Module 2 — AWS SSM Parameter Store

[← IAM Identity Center](01-iam-identity-center.md) | [Back to Workshop Home](../README.md) | [Next: Run Command →](03-run-command.md)

---

Parameter Store provides secure, hierarchical storage for configuration data and secrets. It integrates natively with IAM, CloudFormation, Lambda, EC2 User Data, and other AWS services.

## Key Concepts

### Parameter Types

| Type | Use Case | Encryption |
|---|---|---|
| `String` | Plain text values — hostnames, config keys, feature flags | No |
| `StringList` | Comma-separated values — IP allow-lists, tag lists | No |
| `SecureString` | Passwords, API keys, certificates, secrets | Yes (AWS KMS) |

### Parameter Tiers

| Tier | Max Size | Cost | Advanced Features |
|---|---|---|---|
| Standard | 4 KB | Free | No |
| Advanced | 8 KB | $0.05/parameter/month | Expiry policies, EventBridge notifications, larger values |

### Naming Best Practice

Use forward-slash hierarchies to namespace parameters by environment and service:

```
/workshop/app/db-host
/workshop/app/db-password
/workshop/app/api-key
/production/app/db-host
/production/app/db-password
```

This lets you fetch an entire namespace in one API call using `get-parameters-by-path`.

---

## Console (GUI) Steps

### Create a Parameter (GUI)

1. Open **AWS Systems Manager** from the console.
2. In the left sidebar, click **Parameter Store**.
3. Click **Create parameter**.
4. Fill in the fields:

   | Field | Value |
   |---|---|
   | Name | `/workshop/app/db-host` |
   | Description | Database hostname |
   | Tier | Standard |
   | Type | String |
   | Value | `mydb.cluster.us-east-1.rds.amazonaws.com` |

5. Click **Create parameter**.

**For a SecureString:**
- Set **Type** to `SecureString`.
- Under **KMS key source**, choose:
  - **My current account** → select `alias/aws/ssm` (default free key), or a custom CMK.
- Enter the secret value — it is encrypted at rest and in transit.
- Click **Create parameter**.

---

### View / Edit a Parameter (GUI)

1. In **Parameter Store**, click the parameter name.
2. The detail page shows the **Name**, **Type**, **Version**, and **Last Modified** timestamp.
3. For `String` parameters, the **Value** is shown directly.
4. For `SecureString`, click **Show** to decrypt and display the value (requires `kms:Decrypt` permission).
5. To edit, click **Edit**, change the value, and click **Save changes**.

---

### Delete a Parameter (GUI)

1. In **Parameter Store**, select the checkbox next to the parameter.
2. Click **Delete**, then confirm in the dialog.

---

### View Version History (GUI)

1. Open the parameter detail page.
2. Click the **History** tab.
3. Each row shows a version number, timestamp, and the value at that version.

---

## CLI Steps

> All commands below use `--profile workshop`. Set `export AWS_PROFILE=workshop` to avoid repeating it.

### Create Parameters (CLI)

```bash
# String parameter
aws ssm put-parameter \
  --name "/workshop/app/db-host" \
  --value "mydb.cluster.us-east-1.rds.amazonaws.com" \
  --type String \
  --description "Database hostname" \
  --profile workshop

# SecureString — encrypted with the default SSM KMS key
aws ssm put-parameter \
  --name "/workshop/app/db-password" \
  --value "MyS3cr3tP@ssword!" \
  --type SecureString \
  --description "Database password" \
  --profile workshop

# SecureString with a custom KMS CMK
aws ssm put-parameter \
  --name "/workshop/app/api-key" \
  --value "sk-live-abcdef123456" \
  --type SecureString \
  --key-id "alias/workshop-key" \
  --profile workshop

# StringList
aws ssm put-parameter \
  --name "/workshop/app/allowed-ips" \
  --value "10.0.0.1,10.0.0.2,10.0.0.3" \
  --type StringList \
  --profile workshop
```

---

### Overwrite / Update a Parameter (CLI)

```bash
aws ssm put-parameter \
  --name "/workshop/app/db-host" \
  --value "mydb-v2.cluster.us-east-1.rds.amazonaws.com" \
  --type String \
  --overwrite \
  --profile workshop
```

> Every `--overwrite` creates a new version. The version number increments automatically. Old versions are retained in history.

---

### Get a Single Parameter (CLI)

```bash
# Full API response for a String parameter
aws ssm get-parameter \
  --name "/workshop/app/db-host" \
  --profile workshop

# SecureString — requires --with-decryption to see the plaintext value
aws ssm get-parameter \
  --name "/workshop/app/db-password" \
  --with-decryption \
  --profile workshop

# Extract just the value — useful inside shell scripts
DB_HOST=$(aws ssm get-parameter \
  --name "/workshop/app/db-host" \
  --query "Parameter.Value" \
  --output text \
  --profile workshop)

echo "Database: $DB_HOST"
```

---

### Get Multiple Parameters by Path (CLI)

```bash
# Get all parameters under /workshop/app/
aws ssm get-parameters-by-path \
  --path "/workshop/app/" \
  --recursive \
  --with-decryption \
  --profile workshop

# Load all parameters as environment variables in one shot
eval $(aws ssm get-parameters-by-path \
  --path "/workshop/app/" \
  --recursive \
  --with-decryption \
  --query "Parameters[*].[Name,Value]" \
  --output text \
  --profile workshop \
  | awk '{gsub("/workshop/app/", ""); gsub("-", "_"); print toupper($1)"="$2}')

echo "DB_HOST=$DB_HOST"
echo "DB_PASSWORD=$DB_PASSWORD"
```

---

### List / Describe Parameters (CLI)

```bash
# List all parameters — returns metadata only, not values
aws ssm describe-parameters \
  --profile workshop

# Filter by path prefix
aws ssm describe-parameters \
  --parameter-filters "Key=Path,Option=Recursive,Values=/workshop" \
  --profile workshop

# Filter by type
aws ssm describe-parameters \
  --parameter-filters "Key=Type,Values=SecureString" \
  --profile workshop
```

---

### Delete Parameters (CLI)

```bash
# Delete a single parameter
aws ssm delete-parameter \
  --name "/workshop/app/db-host" \
  --profile workshop

# Delete multiple parameters in one call (up to 10)
aws ssm delete-parameters \
  --names \
    "/workshop/app/db-host" \
    "/workshop/app/db-password" \
    "/workshop/app/api-key" \
  --profile workshop
```

---

### View Parameter History (CLI)

```bash
aws ssm get-parameter-history \
  --name "/workshop/app/db-host" \
  --with-decryption \
  --profile workshop
```

Each entry in the response contains the version number, last modified date, and value at that version.

---

### Tag a Parameter (CLI)

```bash
aws ssm add-tags-to-resource \
  --resource-type "Parameter" \
  --resource-id "/workshop/app/db-host" \
  --tags \
    "Key=Environment,Value=workshop" \
    "Key=Team,Value=platform" \
  --profile workshop
```

---

### Use Parameter Store in EC2 User Data

The EC2 instance's IAM role needs `ssm:GetParameter` (and `kms:Decrypt` for SecureString) on the parameter ARN.

```bash
#!/bin/bash
DB_HOST=$(aws ssm get-parameter \
  --name "/workshop/app/db-host" \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

DB_PASS=$(aws ssm get-parameter \
  --name "/workshop/app/db-password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

echo "Connecting to $DB_HOST"
```

---

[← IAM Identity Center](01-iam-identity-center.md) | [Back to Workshop Home](../README.md) | [Next: Run Command →](03-run-command.md)
