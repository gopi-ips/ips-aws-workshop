terraform {
  required_version = ">= 1.9, < 2.0"

  backend "s3" {
    bucket       = "ips-aws-workshop-2026"
    key          = "workshop/s3-without-module/terraform.tfstate"
    region       = "ca-central-1"
    use_lockfile = true
  }
}
