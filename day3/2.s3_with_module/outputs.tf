output "bucket_id" {
  description = "The name/ID of the S3 bucket"
  value       = module.s3_bucket.bucket_name
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

output "bucket_region" {
  description = "AWS region where the bucket is created"
  value       = module.s3_bucket.bucket_region
}

output "bucket_domain_name" {
  description = "Bucket domain name"
  value       = module.s3_bucket.bucket_domain_name
}

output "versioning_status" {
  description = "Versioning status of the bucket"
  value       = module.s3_bucket.versioning_status
}
