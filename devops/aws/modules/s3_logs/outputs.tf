output "bucket_arn" {
  description = "ARN of the S3 logs bucket"
  value       = aws_s3_bucket.logs.arn
}

output "bucket_id" {
  description = "Name of the S3 logs bucket"
  value       = aws_s3_bucket.logs.id
}
