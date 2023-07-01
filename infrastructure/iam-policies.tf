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

resource "aws_iam_policy" "generate-post" {
  name        = "GenerateUploadPost"
  description = "Allows to generate post presigned links for the photos bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GeneratePost"
        Effect = "Allow"
        Action = [
          "s3:GeneratePresignedPost",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "update-tagging" {
  name = "UpdateObjectTagging"
  description = "Allows to update object tags in the photos bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "UpdateTagging"
        Effect = "Allow"
        Action = [
          "s3:PutObjectTagging"
        ]
        Resource = [
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}