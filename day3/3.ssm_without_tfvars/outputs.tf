output "app_name_parameter_name" {
  description = "SSM parameter path for app name"
  value       = aws_ssm_parameter.app_name.name
}

output "app_name_parameter_arn" {
  description = "SSM parameter ARN for app name"
  value       = aws_ssm_parameter.app_name.arn
}

output "db_password_parameter_name" {
  description = "SSM parameter path for DB password (value is encrypted in AWS)"
  value       = aws_ssm_parameter.db_password.name
}

output "db_password_parameter_arn" {
  description = "SSM parameter ARN for DB password"
  value       = aws_ssm_parameter.db_password.arn
}

output "api_key_parameter_name" {
  description = "SSM parameter path for API key (value is encrypted in AWS)"
  value       = aws_ssm_parameter.api_key.name
}

output "api_key_parameter_arn" {
  description = "SSM parameter ARN for API key"
  value       = aws_ssm_parameter.api_key.arn
}

# NOTE: Secret values are intentionally NOT outputted here.
# Retrieve them via CLI: aws ssm get-parameter --name "/workshop/app/db_password" --with-decryption
