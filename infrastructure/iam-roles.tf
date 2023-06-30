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

data "aws_iam_policy" "lambda-logs" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-show-bucket" {
  role = aws_iam_role.lambda-show-bucket.name
  policy_arn = aws_iam_policy.list-bucket.arn
}

resource "aws_iam_role_policy_attachment" "lambda-basic-execution" {
  role = aws_iam_role.lambda-show-bucket.name
  policy_arn = data.aws_iam_policy.lambda-logs.arn
}

resource "aws_iam_role" "lambda-post-bucket" {
  name = "lambda-post-bucket"
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

resource "aws_iam_role_policy_attachment" "lambda-post-bucket" {
  role = aws_iam_role.lambda-post-bucket.name
  policy_arn = aws_iam_policy.generate-post.arn
}

resource "aws_iam_role_policy_attachment" "lambda-create-basic-execution" {
  role = aws_iam_role.lambda-post-bucket.name
  policy_arn = data.aws_iam_policy.lambda-logs.arn
}