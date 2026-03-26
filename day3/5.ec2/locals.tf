locals {
  # Computed resource name prefix — avoids repeating "${var.project}-${var.environment}" everywhere
  name_prefix = "${var.project}-${var.environment}"

  # Common tags applied to every resource — merge once, reference everywhere
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # AMI filter — centralised so you only update one place to switch OS
  ami_name_filter = "al2023-ami-2023.*-kernel-*-x86_64"

  # SSM parameter path for user data script
  userdata_ssm_path = "/${var.project}/${var.environment}/userdata"
}
