# S3 With Module — Terraform Workshop

This example creates the **same S3 bucket** as `s3_without_module` but wraps all the
resource logic inside a **reusable Terraform module** (`./modules/s3`). The root
configuration simply calls the module and passes variables — the module handles the rest.

---

## What This Creates

Same AWS resources as `s3_without_module`, but created through the module:

| Resource | Purpose |
|---|---|
| `aws_s3_bucket` | The S3 bucket itself |
| `aws_s3_bucket_versioning` | Enables versioning |
| `aws_s3_bucket_server_side_encryption_configuration` | AES-256 encryption at rest |
| `aws_s3_bucket_public_access_block` | Blocks all public access |

---

## Concepts Covered

### What Is a Terraform Module?

A module is a **folder containing `.tf` files** that groups related resources together.
Instead of copy-pasting the same S3 resources every time, you call the module and pass
different inputs.

```
# Without module — resources defined directly
resource "aws_s3_bucket" "workshop" { ... }
resource "aws_s3_bucket_versioning" "workshop" { ... }

# With module — one clean call
module "s3_bucket" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  environment = var.environment
}
```

### Module Input/Output Flow

```
root/variables.tf  →  root/main.tf (module call)
                              ↓
                    modules/s3/variables.tf  (receives inputs)
                    modules/s3/main.tf       (creates resources)
                    modules/s3/outputs.tf    (returns values)
                              ↓
                    root/outputs.tf          (exposes module outputs)
```

### Local Module vs Registry Module

This workshop uses a **local module** (`source = "./modules/s3"`).
In production teams often use the public Terraform Registry:
```hcl
# Registry module (not used here — shown for reference)
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"
}
```

---

## File Structure

```
s3_with_module/
├── backend.tf              # S3 remote state configuration
├── providers.tf            # Terraform version + AWS provider
├── variables.tf            # Root input variables
├── main.tf                 # Module call — passes vars into module
├── outputs.tf              # Proxies module outputs to root
├── README.md               # This file
└── modules/
    └── s3/
        ├── main.tf         # All S3 resource definitions (the actual logic)
        ├── variables.tf    # Module input variables
        └── outputs.tf      # Module output values
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

### Root Variables (`variables.tf`)

| Variable | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `ca-central-1` | AWS region |
| `bucket_name` | `string` | `my-workshop-module-bucket-12345` | S3 bucket name |
| `environment` | `string` | `dev` | Environment tag value |

### Module Variables (`modules/s3/variables.tf`)

| Variable | Type | Description |
|---|---|---|
| `bucket_name` | `string` | Passed in from root — sets the bucket name |
| `environment` | `string` | Passed in from root — used in tags |

---

## Outputs

### Root Outputs (`outputs.tf`) — proxied from module

| Output | Description |
|---|---|
| `bucket_id` | Bucket name/ID |
| `bucket_arn` | Full bucket ARN |
| `bucket_region` | Region where bucket was created |
| `bucket_domain_name` | S3 domain name |
| `versioning_status` | Confirms versioning is `Enabled` |

### Module Outputs (`modules/s3/outputs.tf`) — consumed by root

Same values — the root `outputs.tf` references them as `module.s3_bucket.<output_name>`.

---

## Deployment Commands

### Step 1 — Navigate to the folder

```bash
cd /Users/gopi-ips/Documents/TF/s3_with_module
```

### Step 2 — Initialize Terraform

`terraform init` downloads the AWS provider **and** processes the local module source.

```bash
terraform init
```

Expected output:
```
Initializing the backend...
Successfully configured the backend "s3"!

Initializing modules...
- s3_bucket in modules/s3

Initializing provider plugins...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

> Notice `Initializing modules... - s3_bucket in modules/s3` — this confirms the
> local module was found and loaded.

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

  # module.s3_bucket.aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" {
      + bucket = "my-workshop-module-bucket-12345"
    }

  # module.s3_bucket.aws_s3_bucket_versioning.this will be created
  + resource "aws_s3_bucket_versioning" "this" {
      + versioning_configuration {
          + status = "Enabled"
        }
    }

  # module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.this will be created
  # module.s3_bucket.aws_s3_bucket_public_access_block.this will be created

Plan: 4 to add, 0 to change, 0 to destroy.
```

> Notice resources are prefixed with `module.s3_bucket.` — this is how Terraform
> namespaces module resources in the state.

### Step 5 — Apply

```bash
terraform apply
```

Or without confirmation:

```bash
terraform apply -auto-approve
```

Expected output:
```
module.s3_bucket.aws_s3_bucket.this: Creating...
module.s3_bucket.aws_s3_bucket.this: Creation complete after 2s

module.s3_bucket.aws_s3_bucket_versioning.this: Creating...
module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.this: Creating...
module.s3_bucket.aws_s3_bucket_public_access_block.this: Creating...
module.s3_bucket.aws_s3_bucket_versioning.this: Creation complete after 1s
module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.this: Creation complete after 1s
module.s3_bucket.aws_s3_bucket_public_access_block.this: Creation complete after 1s

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn         = "arn:aws:s3:::my-workshop-module-bucket-12345"
bucket_domain_name = "my-workshop-module-bucket-12345.s3.amazonaws.com"
bucket_id          = "my-workshop-module-bucket-12345"
bucket_region      = "ca-central-1"
versioning_status  = "Enabled"
```

---

## Verify in AWS After Apply

### Check bucket exists

```bash
aws s3 ls | grep my-workshop-module-bucket
```

### Check versioning

```bash
aws s3api get-bucket-versioning \
  --bucket my-workshop-module-bucket-12345 \
  --region ca-central-1
```

### Check encryption

```bash
aws s3api get-bucket-encryption \
  --bucket my-workshop-module-bucket-12345 \
  --region ca-central-1
```

### Check public access block

```bash
aws s3api get-public-access-block \
  --bucket my-workshop-module-bucket-12345 \
  --region ca-central-1
```

### View Terraform outputs

```bash
terraform output
```

### View state — notice module prefix

```bash
terraform state list
```

Expected:
```
module.s3_bucket.aws_s3_bucket.this
module.s3_bucket.aws_s3_bucket_public_access_block.this
module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.this
module.s3_bucket.aws_s3_bucket_versioning.this
```

```bash
terraform state show module.s3_bucket.aws_s3_bucket.this
```

---

## Destroy (Clean Up)

```bash
terraform destroy -auto-approve
```

---

## Common Errors and Fixes

### Error: Module not found

```
Error: Module not installed
  Use "terraform init" to install this module
```

**Fix:** Always run `terraform init` before `plan` or `apply`, especially after
adding or changing a module source.

---

### Error: Bucket name already exists

```
Error: creating Amazon S3 Bucket: BucketAlreadyExists
```

**Fix:** S3 bucket names must be globally unique. Change the default in `variables.tf`
or override at apply time:
```bash
terraform apply -var="bucket_name=my-unique-name-99999"
```

---

### Error: Bucket is not empty on destroy

```
Error: deleting Amazon S3 Bucket: BucketNotEmpty
```

**Fix:** Empty the bucket first:
```bash
aws s3 rm s3://my-workshop-module-bucket-12345 --recursive
terraform destroy -auto-approve
```

---

## Key Difference: With vs Without Module

| | `s3_without_module` | `s3_with_module` |
|---|---|---|
| Resource definition | Directly in `main.tf` | Inside `modules/s3/main.tf` |
| State path | `aws_s3_bucket.workshop` | `module.s3_bucket.aws_s3_bucket.this` |
| Reusability | Single use | Call module multiple times with different inputs |
| Outputs | Direct resource reference | Proxied through module outputs |
| `terraform init` | Downloads provider only | Downloads provider + initializes module |
