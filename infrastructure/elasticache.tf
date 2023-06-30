resource "aws_elasticache_cluster" "elasticache" {
  availability_zone    = "eu-central-1a"
  cluster_id           = "redis-${random_string.bucket-name.result}"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.elasticache-subnet-group.name
  security_group_ids   = [aws_security_group.elasticache.id]
}

resource "aws_elasticache_subnet_group" "elasticache-subnet-group" {
  name       = "elasticache-subnet-group-${random_string.bucket-name.result}"
  subnet_ids = [aws_subnet.lambda-elasticache.id]
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_subnet" "lambda-elasticache" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = cidrsubnet(data.aws_vpc.default.cidr_block, 4, 8)
  availability_zone = "eu-central-1a"
  tags = {
    "Name" = "lambda-elasticache-${random_string.bucket-name.result}"
  }
}

resource "aws_security_group" "elasticache" {
  name        = "ElastiCacheSecurityGroup-${random_string.bucket-name.result}"
  description = "Security group for ElastiCache for photos bucket"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}