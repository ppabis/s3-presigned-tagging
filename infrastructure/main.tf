terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    random = {
        source  = "hashicorp/random"
        version = ">= 1.0"
    }

    archive = {
        source  = "hashicorp/archive"
        version = ">= 2.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}