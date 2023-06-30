resource "aws_iam_policy" "list-bucket" {
  name        = "ListPhotosBucket"
  description = "Allows to read object metadata and list objects in the photos bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.bucket.arn}"
        ]
      },
      {
        Sid    = "GetObject"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:GetObjectAttributes"
        ]
        Resource = [
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}