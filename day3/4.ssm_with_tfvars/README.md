# SSM Parameter Store — Terraform Workshop

This module creates AWS Systems Manager (SSM) Parameter Store parameters using Terraform.
It demonstrates the difference between plain `String` parameters and encrypted `SecureString`
parameters using the default AWS-managed SSM KMS key.

---

## What This Creates

| Resource | SSM Path | Type | Encrypted |
|---|---|---|---|
| App Name | `/workshop/app/name` | `String` | No |
| DB Password | `/workshop/app/db_password` | `SecureString` | Yes (alias/aws/ssm) |
| API Key | `/workshop/app/api_key` | `SecureString` | Yes (alias/aws/ssm) |

---

## Concepts Covered

### String vs SecureString

| Type | Use for | Stored as | Visible in Console |
|---|---|---|---|
| `String` | Non-sensitive config (app name, URLs) | Plain text | Yes |
| `SecureString` | Secrets (passwords, tokens, keys) | KMS encrypted | Masked |

### Default AWS-Managed SSM Key (`alias/aws/ssm`)

- AWS automatically creates and manages this KMS key in every account
- No cost for the key itself (you pay only for API calls)
- No rotation or key policy management needed — AWS handles it
- Referenced in Terraform as `key_id = "alias/aws/ssm"`

### `sensitive = true` in Variables

When a Terraform variable is marked `sensitive = true`, Terraform masks the value
in all CLI output:

```
# What you see in terraform plan / apply:
var.db_password = (sensitive value)
var.api_key     = (sensitive value)
```

The value is still stored in state — this only masks it from terminal output.

---

## File Structure

```
ssm/
├── backend.tf          # S3 remote state configuration
├── providers.tf        # Terraform version + AWS provider
├── variables.tf        # Input variables (region, environment, secrets)
├── main.tf             # SSM parameter resources
├── outputs.tf          # Parameter names and ARNs (no secret values)
├── terraform.tfvars    # Variable values (do not commit secrets to git)
└── README.md           # This file
```

---

## Prerequisites

Before running any Terraform commands, ensure you have:

1. **Terraform installed** (>= 1.9, < 2.0)
   ```bash
   terraform version
   ```

2. **AWS CLI configured** with credentials
   ```bash
   aws configure
   # or
   aws sts get-caller-identity   # verify your identity
   ```

3. **S3 backend bucket exists** — the state bucket `ips-aws-workshop-2026` must
   already exist in `ca-central-1` before running `terraform init`

---

## Variables

| Variable | Type | Default | Sensitive | Description |
|---|---|---|---|---|
| `region` | `string` | `ca-central-1` | No | AWS region |
| `environment` | `string` | `dev` | No | Environment name for tags |
| `db_password` | `string` | — | **Yes** | DB password stored as SecureString |
| `api_key` | `string` | — | **Yes** | API key stored as SecureString |

---

## How to Provide Secret Values

There are three ways to pass the sensitive variables. Choose one:

### Option 1 — terraform.tfvars (workshop/dev only, never commit real secrets)

Edit `terraform.tfvars`:
```hcl
db_password = "SuperSecret123!"
api_key     = "abcdef-1234-workshop-key"
```

### Option 2 — Environment Variables (recommended for CI/CD)

```bash
export TF_VAR_db_password="SuperSecret123!"
export TF_VAR_api_key="abcdef-1234-workshop-key"
```

Terraform automatically reads variables prefixed with `TF_VAR_`.

### Option 3 — Inline `-var` flags

```bash
terraform apply \
  -var="db_password=SuperSecret123!" \
  -var="api_key=abcdef-1234-workshop-key"
```

---

## Deployment Commands

### Step 1 — Navigate to the folder

```bash
cd /Users/gopi-ips/Documents/TF/ssm
```

### Step 2 — Initialize Terraform

Downloads the AWS provider plugin and configures the S3 remote backend.

```bash
terraform init
```

Expected output:
```
Initializing the backend...
Successfully configured the backend "s3"!

Initializing provider plugins...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### Step 3 — Validate configuration

Checks syntax and internal consistency without making any AWS calls.

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 4 — Plan

Shows exactly what Terraform will create, change, or destroy — no changes made yet.

```bash
terraform plan
```

Expected output (truncated):
```
Terraform will perform the following actions:

  # aws_ssm_parameter.app_name will be created
  + resource "aws_ssm_parameter" "app_name" {
      + name  = "/workshop/app/name"
      + type  = "String"
      + value = "MyWorkshopApp"
    }

  # aws_ssm_parameter.db_password will be created
  + resource "aws_ssm_parameter" "db_password" {
      + name   = "/workshop/app/db_password"
      + type   = "SecureString"
      + value  = (sensitive value)       <-- masked because sensitive = true
      + key_id = "alias/aws/ssm"
    }

  # aws_ssm_parameter.api_key will be created
  + resource "aws_ssm_parameter" "api_key" {
      + name   = "/workshop/app/api_key"
      + type   = "SecureString"
      + value  = (sensitive value)       <-- masked because sensitive = true
      + key_id = "alias/aws/ssm"
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```

### Step 5 — Apply

Creates the resources in AWS. Terraform will ask for confirmation.

```bash
terraform apply
```

To skip the confirmation prompt:

```bash
terraform apply -auto-approve
```

Expected output:
```
aws_ssm_parameter.app_name: Creating...
aws_ssm_parameter.db_password: Creating...
aws_ssm_parameter.api_key: Creating...
aws_ssm_parameter.app_name: Creation complete after 1s
aws_ssm_parameter.db_password: Creation complete after 1s
aws_ssm_parameter.api_key: Creation complete after 1s

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

app_name_parameter_arn    = "arn:aws:ssm:ca-central-1:123456789012:parameter/workshop/app/name"
app_name_parameter_name   = "/workshop/app/name"
api_key_parameter_arn     = "arn:aws:ssm:ca-central-1:123456789012:parameter/workshop/app/api_key"
api_key_parameter_name    = "/workshop/app/api_key"
db_password_parameter_arn = "arn:aws:ssm:ca-central-1:123456789012:parameter/workshop/app/db_password"
db_password_parameter_name = "/workshop/app/db_password"
```

---

## Verify in AWS After Apply

### List all parameters under the workshop path

```bash
aws ssm get-parameters-by-path \
  --path "/workshop/app" \
  --region ca-central-1
```

### Read a plain String parameter

```bash
aws ssm get-parameter \
  --name "/workshop/app/name" \
  --region ca-central-1
```

### Read an encrypted SecureString (decrypted)

```bash
aws ssm get-parameter \
  --name "/workshop/app/db_password" \
  --with-decryption \
  --region ca-central-1
```

Without `--with-decryption`, the value is returned as a cipher blob and is unreadable.

### Read multiple parameters at once

```bash
aws ssm get-parameters \
  --names "/workshop/app/db_password" "/workshop/app/api_key" \
  --with-decryption \
  --region ca-central-1
```

### View outputs from Terraform state

```bash
terraform output
```

---

## Show Remote State

Because this uses an S3 backend, the state file is stored remotely.
To view what Terraform is tracking:

```bash
terraform state list
```

Expected:
```
aws_ssm_parameter.api_key
aws_ssm_parameter.app_name
aws_ssm_parameter.db_password
```

```bash
terraform state show aws_ssm_parameter.db_password
```

---

## Destroy (Clean Up)

Removes all resources created by this configuration from AWS.

```bash
terraform destroy
```

To skip the confirmation prompt:

```bash
terraform destroy -auto-approve
```

Expected output:
```
aws_ssm_parameter.api_key: Destroying...
aws_ssm_parameter.db_password: Destroying...
aws_ssm_parameter.app_name: Destroying...

Destroy complete! Resources: 3 destroyed.
```

---

## Common Errors and Fixes

### Error: Backend bucket does not exist

```
Error: Failed to get existing workspaces: S3 bucket "ips-aws-workshop-2026" does not exist.
```

**Fix:** Create the S3 bucket first:
```bash
aws s3 mb s3://ips-aws-workshop-2026 --region ca-central-1
```

---

### Error: No value for required variable

```
Error: No value for required variable
  on variables.tf line 13: var.db_password
```

**Fix:** Provide the value via `terraform.tfvars`, `-var` flag, or `TF_VAR_` env var.

---

### Error: Parameter already exists

```
Error: putting SSM Parameter: ParameterAlreadyExists
```

**Fix:** Either import the existing parameter into state or delete it manually:
```bash
aws ssm delete-parameter --name "/workshop/app/db_password" --region ca-central-1
```

---

### Error: Access Denied on KMS

```
Error: AccessDeniedException: User is not authorized to use key alias/aws/ssm
```

**Fix:** Ensure your IAM user/role has the following permissions:
- `ssm:PutParameter`
- `kms:GenerateDataKey`
- `kms:Decrypt`

---

## Security Notes

- **Never commit real secrets** in `terraform.tfvars` to version control
- Add `terraform.tfvars` to `.gitignore` if it contains real values
- The Terraform state file in S3 **contains secret values in plain text** — ensure the S3 bucket has encryption and restricted access
- Use `sensitive = true` on all secret variables to prevent accidental terminal exposure
- In production, use AWS Secrets Manager for rotating secrets instead of SSM SecureString
