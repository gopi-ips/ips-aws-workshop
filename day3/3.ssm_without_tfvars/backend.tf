terraform {
  required_version = ">= 1.9, < 2.0"

  backend "s3" {
    bucket       = "ips-aws-workshop-2026"
    key          = "workshop/ssm-no-tfvars/terraform.tfstate"
    region       = "ca-central-1"
    use_lockfile = true
  }
}
