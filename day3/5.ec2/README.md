# EC2 with User Data — Terraform Workshop

This example launches an Amazon Linux 2023 EC2 instance that automatically installs
and starts an Apache web server via a **user data** script. It also demonstrates
**Terraform locals** to keep configuration clean and avoid repetition.

---

## What This Creates

| Resource | Purpose |
|---|---|
| `data.aws_ami` | Looks up the latest Amazon Linux 2023 AMI automatically |
| `aws_security_group` | Allows HTTP (port 80) and SSH (port 22) inbound traffic |
| `aws_instance` | The EC2 instance running Amazon Linux 2023 |

---

## Concepts Covered

### data Sources

A `data` block reads existing information from AWS without creating anything.
Here it fetches the latest Amazon Linux 2023 AMI ID at plan time:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [local.ami_name_filter]   # "al2023-ami-*-x86_64"
  }
}
```

This means you never need to hardcode an AMI ID — Terraform always picks the latest.

### Locals

`locals.tf` defines computed values that are referenced throughout the configuration.
Think of locals as **constants inside your Terraform code**.

| Local | Value | Used for |
|---|---|---|
| `name_prefix` | `"workshop-dev"` | Prefix for all resource names |
| `common_tags` | Map of Project/Environment/ManagedBy | Applied to all resources via `merge()` |
| `ami_name_filter` | `"al2023-ami-*-x86_64"` | AMI lookup filter |
| `user_data` | Bash script | EC2 bootstrap script |

### `merge()` for Tags

Instead of repeating the same tags on every resource, locals uses `merge()`:

```hcl
# Define once in locals
common_tags = {
  Project     = var.project
  Environment = var.environment
  ManagedBy   = "Terraform"
}

# Merge with resource-specific tags on each resource
tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-ec2"
})
```

This results in: `Project`, `Environment`, `ManagedBy`, and `Name` tags on the resource.

### User Data

User data is a shell script that runs **once** when the EC2 instance first boots.
It is stored in `locals.tf` to keep `main.tf` clean:

```bash
#!/bin/bash
yum update -y
yum install -y httpd        # Install Apache web server
systemctl start httpd       # Start Apache
systemctl enable httpd      # Start Apache on every reboot
echo "<h1>Hello from Terraform Workshop!</h1>" > /var/www/html/index.html
```

After the instance boots (~2 minutes), opening `http://<public_ip>` shows the webpage.

---

## File Structure

```
ec2/
├── backend.tf      # S3 remote state configuration
├── providers.tf    # Terraform version + AWS provider
├── variables.tf    # Input variables (region, environment, instance_type, project)
├── locals.tf       # Computed locals: name_prefix, common_tags, ami filter, user_data
├── main.tf         # data source, security group, EC2 instance
├── outputs.tf      # instance_id, IPs, ami details, sg_id, website_url
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

3. **S3 backend bucket exists** in `ca-central-1`
   ```bash
   aws s3 mb s3://ips-aws-workshop-2026 --region ca-central-1
   ```

---

## Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `ca-central-1` | AWS region to deploy into |
| `environment` | `string` | `dev` | Environment name (used in tags and name prefix) |
| `instance_type` | `string` | `t2.micro` | EC2 instance type |
| `project` | `string` | `workshop` | Project name (used in tags and name prefix) |

---

## Outputs

| Output | Description |
|---|---|
| `instance_id` | EC2 instance ID (e.g. `i-0abc123...`) |
| `instance_public_ip` | Public IP to SSH or browse to |
| `instance_private_ip` | Private IP within the VPC |
| `instance_type` | Instance type that was launched |
| `ami_id` | AMI ID that was resolved and used |
| `ami_name` | AMI name (e.g. `al2023-ami-2023.x.x-kernel-x86_64`) |
| `security_group_id` | ID of the security group attached |
| `website_url` | `http://<public_ip>` — open in browser after instance is ready |

---

## Deployment Commands

### Step 1 — Navigate to the folder

```bash
cd /Users/gopi-ips/Documents/TF/ec2
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
data.aws_ami.amazon_linux: Reading...
data.aws_ami.amazon_linux: Read complete after 1s [id=ami-0abcd1234efgh5678]

Terraform will perform the following actions:

  # aws_security_group.ec2 will be created
  + resource "aws_security_group" "ec2" {
      + name = "workshop-dev-ec2-sg"
      + ingress {
          + from_port   = 80
          + to_port     = 80
          + protocol    = "tcp"
          + cidr_blocks = ["0.0.0.0/0"]
        }
      + ingress {
          + from_port   = 22
          + to_port     = 22
          + protocol    = "tcp"
          + cidr_blocks = ["0.0.0.0/0"]
        }
    }

  # aws_instance.ec2 will be created
  + resource "aws_instance" "ec2" {
      + ami           = "ami-0abcd1234efgh5678"
      + instance_type = "t2.micro"
      + user_data     = (known after apply)
      + tags = {
          + "Environment" = "dev"
          + "ManagedBy"   = "Terraform"
          + "Name"        = "workshop-dev-ec2"
          + "Project"     = "workshop"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

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
aws_security_group.ec2: Creating...
aws_security_group.ec2: Creation complete after 2s

aws_instance.ec2: Creating...
aws_instance.ec2: Still creating... [10s elapsed]
aws_instance.ec2: Still creating... [20s elapsed]
aws_instance.ec2: Creation complete after 32s

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

ami_id             = "ami-0abcd1234efgh5678"
ami_name           = "al2023-ami-2023.6.20250101.0-kernel-6.1-x86_64"
instance_id        = "i-0abc123def456789"
instance_private_ip = "172.31.10.5"
instance_public_ip = "35.183.x.x"
instance_type      = "t2.micro"
security_group_id  = "sg-0abc123def456789"
website_url        = "http://35.183.x.x"
```

---

## Verify in AWS After Apply

### Wait for user data to finish (~2 minutes after apply)

User data runs after the instance reaches the `running` state.
Wait about 2 minutes before testing the web server.

### Test the web server in your browser

```
http://<instance_public_ip>
```

Or via curl:
```bash
curl http://$(terraform output -raw instance_public_ip)
```

Expected response:
```html
<h1>Hello from Terraform Workshop! (dev)</h1>
```

### SSH into the instance (if you have a key pair)

```bash
ssh -i your-key.pem ec2-user@$(terraform output -raw instance_public_ip)
```

> Note: This example does not attach a key pair. Add `key_name = "your-key"` to
> `aws_instance.ec2` in `main.tf` if SSH access is needed.

### Check instance state via AWS CLI

```bash
aws ec2 describe-instances \
  --instance-ids $(terraform output -raw instance_id) \
  --region ca-central-1 \
  --query "Reservations[0].Instances[0].State.Name"
```

### Check user data logs on the instance (if SSH'd in)

```bash
sudo cat /var/log/cloud-init-output.log
```

### View Terraform state

```bash
terraform state list
```

Expected:
```
data.aws_ami.amazon_linux
aws_instance.ec2
aws_security_group.ec2
```

```bash
terraform state show aws_instance.ec2
```

### View outputs

```bash
terraform output
terraform output website_url
terraform output -raw instance_public_ip
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
aws_instance.ec2: Destroying...
aws_instance.ec2: Still destroying... [30s elapsed]
aws_instance.ec2: Destruction complete after 45s

aws_security_group.ec2: Destroying...
aws_security_group.ec2: Destruction complete after 1s

Destroy complete! Resources: 2 destroyed.
```

---

## Common Errors and Fixes

### Error: No AMI found matching filter

```
Error: Your query returned no results. Please change your search criteria and try again.
```

**Fix:** The AMI filter in `locals.tf` may not match AMIs in your region.
Check available AMIs:
```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" \
  --query "Images[0].Name" \
  --region ca-central-1
```

---

### Error: VPC not found / subnet required

```
Error: creating EC2 Instance: InvalidParameterValue: No default VPC found
```

**Fix:** Add a `subnet_id` to the `aws_instance` resource pointing to an existing subnet:
```hcl
subnet_id = "subnet-xxxxxxxx"
```

---

### Website not loading after apply

The web server takes ~2 minutes to install via user data after the instance starts.
Wait and retry. If still failing:
- Check the security group allows port 80 from your IP
- SSH in and run: `sudo systemctl status httpd`
- Check: `sudo cat /var/log/cloud-init-output.log`

---

### Error: Security group already exists

```
Error: creating Security Group: InvalidGroup.Duplicate
```

**Fix:** Import the existing security group into state or delete it manually:
```bash
aws ec2 delete-security-group --group-name workshop-dev-ec2-sg --region ca-central-1
```

---

## Security Notes

- SSH is open to `0.0.0.0/0` for workshop convenience — in production restrict to your IP
- This instance has no IAM role — add `iam_instance_profile` if the app needs AWS API access
- No key pair is attached — add `key_name` to enable SSH with a PEM key
- Public IP is ephemeral — use an Elastic IP if you need a stable address
