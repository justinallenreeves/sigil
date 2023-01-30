resource "aws_s3_bucket" "foundry_assets" {
  bucket = join(".", [var.prefix, var.name])
}

data "aws_iam_policy_document" "read_foundry_assets" {
  statement {
    sid       = "PublicReadGetObject"
    actions   = ["s3:GetObject"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.foundry_assets.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "read_foundry_assets" {
  bucket = aws_s3_bucket.foundry_assets.id
  policy = data.aws_iam_policy_document.read_foundry_assets.json
}


resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.foundry_assets.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }

}