variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ca-central-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# In real projects, pass secrets via environment variables instead of hardcoding:
#   export TF_VAR_db_password="your-secret-password"
#   export TF_VAR_api_key="your-api-key"
variable "db_password" {
  description = "Database password - stored as SecureString in SSM"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API key for external service - stored as SecureString in SSM"
  type        = string
  sensitive   = true
}
