###
# Lambda for listing the bucket
###
data "archive_file" "lambda-list" {
  type = "zip"
  source {
    content  = file("lambda/list/list.py")
    filename = "lambda.py"
  }
  output_path = "list.zip"
}

resource "aws_lambda_function" "list" {
  filename      = data.archive_file.lambda-list.output_path
  handler = "lambda.lambda_handler"
  role          = aws_iam_role.lambda-show-bucket.arn
  runtime       = "python3.8"
  function_name = "list-${random_string.bucket-name.result}"
  source_code_hash = data.archive_file.lambda-list.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.bucket.id
    }
  }
}

resource "aws_lambda_permission" "api-list" {
  function_name = aws_lambda_function.list.function_name
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/GET/*"
  principal = "apigateway.amazonaws.com"
  action = "lambda:InvokeFunction"
}

###
# Lambda for creating a form for upload
###

data "archive_file" "lambda-create" {
  type = "zip"
  source_dir = "lambda/create/"
  output_path = "create.zip"
}

resource "aws_lambda_function" "create" {
  filename = data.archive_file.lambda-create.output_path
  handler = "create.lambda_handler"
  role = aws_iam_role.lambda-post-bucket.arn
  runtime = "python3.8"
  function_name = "create-${random_string.bucket-name.result}"
  source_code_hash = data.archive_file.lambda-create.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.bucket.id
      REDIRECT = "https://99j7iqgrbl.execute-api.eu-central-1.amazonaws.com/prod" # Because of Terraform dependency cycle, we cannot refer to the API Gateway here
      # So we hardcode the value of the API Gateway URL after applying the infrastructure
      REDIS_HOST = aws_elasticache_cluster.elasticache.cache_nodes.0.address
    }
  }

  vpc_config {
    subnet_ids = [aws_subnet.lambda-elasticache.id]
    security_group_ids = [aws_security_group.lambda.id]
  }
}
resource "aws_lambda_permission" "api-create" {
  function_name = aws_lambda_function.create.function_name
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/POST/*"
  principal = "apigateway.amazonaws.com"
  action = "lambda:InvokeFunction"
}

resource "aws_security_group" "lambda" {
  name        = "LambdaSecurityGroup-${random_string.bucket-name.result}"
  description = "Security group for lambdas for photos bucket"
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

###
# Lambda for updating the tags in the object
###
data "archive_file" "lambda-update" {
  type = "zip"
  source_dir = "lambda/update/"
  output_path = "update.zip"
}
resource "aws_lambda_function" "update" {
  filename = data.archive_file.lambda-update.output_path
  handler = "update.lambda_handler"
  role = aws_iam_role.lambda-update-object.arn
  runtime = "python3.8"
  function_name = "update-${random_string.bucket-name.result}"
  source_code_hash = data.archive_file.lambda-update.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.bucket.id
      REDIS_HOST = aws_elasticache_cluster.elasticache.cache_nodes.0.address
    }
  }

  vpc_config {
    subnet_ids = [aws_subnet.lambda-elasticache.id]
    security_group_ids = [aws_security_group.lambda.id]
  }
}

resource "aws_lambda_permission" "s3-notification" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
  
}