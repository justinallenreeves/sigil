resource "aws_s3_bucket" "foundry_assets" {
  bucket = "${var.s3_bucket_prefix}.foundry.assets"
  tags   = {}
}
