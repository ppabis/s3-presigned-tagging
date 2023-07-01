This is a companion repository to a blog post available here:
https://pabis.eu/blog/2023-07-01-Tag-S3-Objects-Uploaded-Presigned-URL.html

It includes the infrastructure in Terraform:

* placeholders for Lambda functions
* IAM roles and policies
* ElastiCache Redis cluster
* S3 bucket for uploads

Before deploying, remember to install Lambda dependencies in:
`infrastructure/lambda/create/` and `infrastructure/lambda/update/`