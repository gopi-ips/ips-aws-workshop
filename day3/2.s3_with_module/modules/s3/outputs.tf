output "bucket_name" {
  description = "The name/ID of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_region" {
  description = "AWS region where the bucket is created"
  value       = aws_s3_bucket.this.region
}

output "bucket_domain_name" {
  description = "Bucket domain name"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "versioning_status" {
  description = "Versioning status of the bucket"
  value       = aws_s3_bucket_versioning.this.versioning_configuration[0].status
}
