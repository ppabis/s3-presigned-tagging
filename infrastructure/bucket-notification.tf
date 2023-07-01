resource "aws_s3_bucket_notification" "photos-uploaded" {
    bucket = aws_s3_bucket.bucket.id
    lambda_function {
        lambda_function_arn = aws_lambda_function.update.arn
        events = ["s3:ObjectCreated:*"]
    }
}

resource "aws_route_table" "elasticache-lambda" {
    vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id = data.aws_vpc.default.id
    service_name = "com.amazonaws.eu-central-1.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids = [aws_route_table.elasticache-lambda.id]
}

resource "aws_route_table_association" "elasticache-lambda" {
    subnet_id = aws_subnet.lambda-elasticache.id
    route_table_id = aws_route_table.elasticache-lambda.id 
}