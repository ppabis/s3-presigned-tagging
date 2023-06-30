This is a companion repository to a blog post.

It includes the infrastructure in Terraform:

* placeholders for Lambda functions
* IAM roles and policies
* ElastiCache Redis cluster
* S3 bucket for uploads

Before deploying, remember to install Lambda dependencies in:
`infrastructure/lambda/create/`