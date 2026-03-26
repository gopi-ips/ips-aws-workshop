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
