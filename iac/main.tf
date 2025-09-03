terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "marascofsc.com"
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "MarascoFSC"
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}

# Separate provider for us-east-1 (required for ACM certificates for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  
  default_tags {
    tags = {
      Project     = "MarascoFSC"
      Environment = "production"
      ManagedBy   = "Terraform"
    }
  }
}