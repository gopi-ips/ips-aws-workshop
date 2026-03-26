variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ca-central-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-workshop-bucket-12345"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
