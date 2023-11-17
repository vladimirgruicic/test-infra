# main.tf

provider "aws" {
  region = "your_aws_region"
}

# S3 Bucket for Frontend
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "my-frontend-bucket"
  acl    = "public-read"  # Set ACL as needed

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = "FrontendBucket"
  }
}
