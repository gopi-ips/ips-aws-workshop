# Plain string parameter (not sensitive)
resource "aws_ssm_parameter" "app_name" {
  name  = "/workshop/app/name"
  type  = "String"
  value = "MyWorkshopApp"

  tags = {
    Environment = var.environment
  }
}

# Encrypted SecureString using the default AWS-managed SSM key (alias/aws/ssm)
resource "aws_ssm_parameter" "db_password" {
  name        = "/workshop/app/db_password"
  description = "Database password for the workshop app"
  type        = "SecureString"
  value       = var.db_password

  # Uses the default AWS-managed key for SSM — no cost, no key management needed
  key_id = "alias/aws/ssm"

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "api_key" {
  name        = "/workshop/app/api_key"
  description = "API key for external service"
  type        = "SecureString"
  value       = var.api_key

  key_id = "alias/aws/ssm"

  tags = {
    Environment = var.environment
  }
}
