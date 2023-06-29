resource "random_string" "bucket-name" {
    length = 8
    lower = true
    upper = false
    numeric = false
    special = false
}

resource "aws_s3_bucket" "bucket" {
  bucket = "photos-${random_string.bucket-name.result}"
}