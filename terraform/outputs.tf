output "website" {
    value = aws_s3_bucket.bucket.website_endpoint
}

output "sns_topic" {
    value = aws_sns_topic.bucket_changes.name
}