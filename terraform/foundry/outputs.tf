output "aws_s3_buckets" {
  value = [aws_s3_bucket.foundry_assets.bucket]
}
