# S3 Without Module — Terraform Workshop

This example creates an S3 bucket by defining all AWS resources **directly** in `main.tf`,
without any module abstraction. It is the simplest way to get started with Terraform and S3.

---

## What This Creates

| Resource | Purpose |
|---|---|
| `aws_s3_bucket` | The S3 bucket itself |
| `aws_s3_bucket_versioning` | Enables versioning to keep history of object changes |
| `aws_s3_bucket_server_side_encryption_configuration` | Encrypts all objects at rest with AES-256 |
| `aws_s3_bucket_public_access_block` | Blocks all public access to the bucket |

---

## Concepts Covered

### Direct Resource Usage

All four AWS resources are written directly in `main.tf`. This is the most straightforward
approach — you can see exactly what is being created without any indirection.

### S3 Bucket Best Practices Applied

| Setting | Value | Why |
|---|---|---|
| Versioning | `Enabled` | Recover deleted or overwritten objects |
| Encryption | `AES256` | Objects encrypted at rest using AWS-managed keys |
| Block Public ACLs | `true` | Prevents public ACL grants on objects |
| Block Public Policy | `true` | Prevents public bucket policies |
| Ignore Public ACLs | `true` | Ignores any existing public ACLs |
| Restrict Public Buckets | `true` | Disables public access even if policy allows it |

### Why Four Separate Resources?

Since AWS provider v4+, S3 sub-settings (versioning, encryption, public access block)
are managed as **separate Terraform resources** rather than nested blocks inside
`aws_s3_bucket`. This matches how AWS manages them internally.

---

## File Structure

```
s3_without_module/
├── backend.tf      # S3 remote state configuration
├── providers.tf    # Terraform version + AWS provider
├── variables.tf    # Input variables (region, bucket_name, environment)
├── main.tf         # All S3 resources defined directly
├── outputs.tf      # Bucket id, arn, region, domain name, versioning status
└── README.md       # This file
```

---

## Prerequisites

1. **Terraform installed** (>= 1.9, < 2.0)
   ```bash
   terraform version
   ```

2. **AWS CLI configured**
   ```bash
   aws sts get-caller-identity
   ```

3. **S3 backend bucket exists** — `ips-aws-workshop-2026` must exist in `ca-central-1`
   ```bash
   aws s3 mb s3://ips-aws-workshop-2026 --region ca-central-1
   ```

---

## Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `ca-central-1` | AWS region to deploy into |
| `bucket_name` | `string` | `my-workshop-bucket-12345` | Name of the S3 bucket |
| `environment` | `string` | `dev` | Environment tag value |

> **Note:** S3 bucket names are globally unique across all AWS accounts.
> Change `bucket_name` if the default is already taken.

---

## Outputs

| Output | Description |
|---|---|
| `bucket_id` | The bucket name (same as ID in S3) |
| `bucket_arn` | Full ARN — used when granting IAM permissions |
| `bucket_region` | Region the bucket was created in |
| `bucket_domain_name` | Full domain name for S3 access |
| `versioning_status` | Confirms versioning is `Enabled` |

---

## Deployment Commands

### Step 1 — Navigate to the folder

```bash
cd /Users/gopi-ips/Documents/TF/s3_without_module
```

### Step 2 — Initialize Terraform

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

### Step 3 — Validate

```bash
terraform validate
```

Expected output:
```
Success! The configuration is valid.
```

### Step 4 — Plan

```bash
terraform plan
```

Expected output (truncated):
```
Terraform will perform the following actions:

  # aws_s3_bucket.workshop will be created
  + resource "aws_s3_bucket" "workshop" {
      + bucket = "my-workshop-bucket-12345"
    }

  # aws_s3_bucket_versioning.workshop will be created
  + resource "aws_s3_bucket_versioning" "workshop" {
      + versioning_configuration {
          + status = "Enabled"
        }
    }

  # aws_s3_bucket_server_side_encryption_configuration.workshop will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "workshop" {
      + rule {
          + apply_server_side_encryption_by_default {
              + sse_algorithm = "AES256"
            }
        }
    }

  # aws_s3_bucket_public_access_block.workshop will be created
  + resource "aws_s3_bucket_public_access_block" "workshop" {
      + block_public_acls       = true
      + block_public_policy     = true
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

Plan: 4 to add, 0 to change, 0 to destroy.
```

### Step 5 — Apply

```bash
terraform apply
```

Or skip the confirmation prompt:

```bash
terraform apply -auto-approve
```

Expected output:
```
aws_s3_bucket.workshop: Creating...
aws_s3_bucket.workshop: Creation complete after 2s

aws_s3_bucket_versioning.workshop: Creating...
aws_s3_bucket_server_side_encryption_configuration.workshop: Creating...
aws_s3_bucket_public_access_block.workshop: Creating...
aws_s3_bucket_versioning.workshop: Creation complete after 1s
aws_s3_bucket_server_side_encryption_configuration.workshop: Creation complete after 1s
aws_s3_bucket_public_access_block.workshop: Creation complete after 1s

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn         = "arn:aws:s3:::my-workshop-bucket-12345"
bucket_domain_name = "my-workshop-bucket-12345.s3.amazonaws.com"
bucket_id          = "my-workshop-bucket-12345"
bucket_region      = "ca-central-1"
versioning_status  = "Enabled"
```

---

## Verify in AWS After Apply

### Check bucket exists

```bash
aws s3 ls | grep my-workshop-bucket-12345
```

### Check versioning is enabled

```bash
aws s3api get-bucket-versioning \
  --bucket my-workshop-bucket-12345 \
  --region ca-central-1
```

Expected:
```json
{
    "Status": "Enabled"
}
```

### Check encryption is configured

```bash
aws s3api get-bucket-encryption \
  --bucket my-workshop-bucket-12345 \
  --region ca-central-1
```

### Check public access is blocked

```bash
aws s3api get-public-access-block \
  --bucket my-workshop-bucket-12345 \
  --region ca-central-1
```

### View Terraform outputs

```bash
terraform output
```

### View remote state

```bash
terraform state list
```

Expected:
```
aws_s3_bucket.workshop
aws_s3_bucket_public_access_block.workshop
aws_s3_bucket_server_side_encryption_configuration.workshop
aws_s3_bucket_versioning.workshop
```

---

## Destroy (Clean Up)

```bash
terraform destroy
```

Or without confirmation:

```bash
terraform destroy -auto-approve
```

Expected:
```
aws_s3_bucket_versioning.workshop: Destroying...
aws_s3_bucket_public_access_block.workshop: Destroying...
aws_s3_bucket_server_side_encryption_configuration.workshop: Destroying...
aws_s3_bucket.workshop: Destroying...

Destroy complete! Resources: 4 destroyed.
```

---

## Common Errors and Fixes

### Error: Bucket name already exists

```
Error: creating Amazon S3 Bucket: BucketAlreadyExists
```

**Fix:** S3 bucket names are globally unique. Change `bucket_name` in `variables.tf`
or pass a different value:
```bash
terraform apply -var="bucket_name=my-unique-bucket-name-99999"
```

---

### Error: Bucket is not empty on destroy

```
Error: deleting Amazon S3 Bucket: BucketNotEmpty
```

**Fix:** Empty the bucket first, then destroy:
```bash
aws s3 rm s3://my-workshop-bucket-12345 --recursive
terraform destroy -auto-approve
```

---

### Error: Backend bucket does not exist

```
Error: Failed to get existing workspaces: S3 bucket "ips-aws-workshop-2026" does not exist.
```

**Fix:** Create the backend bucket first:
```bash
aws s3 mb s3://ips-aws-workshop-2026 --region ca-central-1
```

---

## S3 Without Module vs With Module

| Aspect | Without Module | With Module |
|---|---|---|
| Code location | All in `main.tf` | Root calls `modules/s3/` |
| Reusability | Single use | Can be called multiple times |
| Visibility | Everything is visible | Logic is abstracted |
| Best for | Learning, one-off buckets | Repeatable patterns |
