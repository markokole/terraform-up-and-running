provider "aws" {
  region = "us-aws-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "markokole-terraform-state" # name must be globally unique

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
