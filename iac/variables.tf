variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "marascofsc.com"
}

variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone ID"
  type        = string
  default     = "Z3V8DKVBIPM86F"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for website content"
  type        = string
  default     = "marascofsc-website-2025"
}