output "bucket_id" {
  description = "The name/ID of the S3 bucket"
  value       = aws_s3_bucket.workshop.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.workshop.arn
}

output "bucket_region" {
  description = "AWS region where the bucket is created"
  value       = aws_s3_bucket.workshop.region
}

output "bucket_domain_name" {
  description = "Bucket domain name"
  value       = aws_s3_bucket.workshop.bucket_domain_name
}

output "versioning_status" {
  description = "Versioning status of the bucket"
  value       = aws_s3_bucket_versioning.workshop.versioning_configuration[0].status
}
