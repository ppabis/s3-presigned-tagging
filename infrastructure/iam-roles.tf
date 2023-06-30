resource "aws_iam_role" "lambda-show-bucket" {
  name = "lambda-show-bucket"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = ""
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-show-bucket" {
  role = aws_iam_role.lambda-show-bucket.name
  policy_arn = aws_iam_policy.list-bucket.arn
}