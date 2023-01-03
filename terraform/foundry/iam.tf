data "aws_iam_policy_document" "foundry_s3_access" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.foundry_assets.bucket}",
    ]

    #condition {
    #  test     = "StringLike"
    #  variable = "s3:prefix"
    #  values = [
    #    "*",
    #    "/*"
    #  ]
    #}
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.foundry_assets.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.foundry_assets.bucket}/*",
    ]
  }
}

resource "aws_iam_policy" "foundry_s3_access" {
  policy = data.aws_iam_policy_document.foundry_s3_access.json
}

#data "aws_iam_policy_document" "foundry_s3_access" {
#  statement {
#    actions   = ["s3:ListAllMyBuckets"]
#    resources = ["arn:aws:s3:::*"]
#  }
#  statement {
#    actions   = ["s3:*"]
#    resources = [aws_s3_bucket.foundry_assets.arn]
#  }
#}
#

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "foundry_s3_access" {
  name               = "foundry-s3-access"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "foundry_s3_access" {
  name       = "foundry-s3-access"
  policy_arn = aws_iam_policy.foundry_s3_access.arn
  roles      = [aws_iam_role.foundry_s3_access.name]
}
