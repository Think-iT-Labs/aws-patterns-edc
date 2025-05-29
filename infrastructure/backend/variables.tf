variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "tfstate_bucket_name" {
  type        = string
  description = "Name of the S3 bucket to store Terraform state"
}
