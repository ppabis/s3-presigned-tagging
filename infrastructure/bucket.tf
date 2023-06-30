resource "random_string" "bucket-name" {
    length = 8
    lower = true
    upper = false
    numeric = false
    special = false
}

resource "aws_s3_bucket" "bucket" {
  bucket = "photos-${random_string.bucket-name.result}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket-public" {
  bucket = aws_s3_bucket.bucket.id
  block_public_policy = false
}

resource "aws_s3_bucket_website_configuration" "bucket-website" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "allow-all-origins" {
  bucket = aws_s3_bucket.bucket.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 600
  }
}

data "aws_iam_policy_document" "bucket-policy" {
  depends_on = [ aws_s3_bucket_public_access_block.bucket-public ]
  statement {
    actions = [ "s3:GetObject" ]
    resources = [ "${aws_s3_bucket.bucket.arn}/*" ]
    principals {
      type = "*"
      identifiers = [ "*" ]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket-policy.json
}