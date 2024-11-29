output "bucket_name" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_configuration[*].website_endpoint
}

