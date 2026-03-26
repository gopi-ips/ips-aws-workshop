# SSM Parameters — Without tfvars

This example demonstrates AWS SSM Parameter Store using Terraform **without a `.tfvars` file**.

## How values are supplied

| Approach | How |
|---|---|
| Default in `variables.tf` | Used here for workshop simplicity |
| Environment variable | `export TF_VAR_db_password="secret"` |
| CLI flag | `terraform apply -var="db_password=secret"` |

## Comparison with `ssm_with_tfvars`

| | `ssm_with_tfvars` | `ssm_without_tfvars` |
|---|---|---|
| Values stored in | `terraform.tfvars` | `variables.tf` defaults |
| `.tfvars` file | Yes | No |
| Behavior | Identical | Identical |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Retrieve secrets after apply

```bash
aws ssm get-parameter --name "/workshop/app/db_password" --with-decryption
aws ssm get-parameter --name "/workshop/app/api_key" --with-decryption
```
