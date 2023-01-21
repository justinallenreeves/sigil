locals {
  name = join(".", [var.prefix, var.name])
}
resource "aws_s3_bucket" "asset_bucket" {
  bucket = join(".", [var.prefix, var.name])
  tags   = var.tags
}
