terraform {
  required_version = "~> 1.7"

  backend "s3" {
    bucket         = "tfstate-bucket"
    key            = "stage-1/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tfstate-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.22"
    }
  }
}

provider "aws" {
  region     = "eu-central-1"
  profile = "tf-lab"
}
