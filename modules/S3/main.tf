# S3 Bucket for Frontend
resource "aws_s3_bucket" "test-vg-frontend_bucket" {
  bucket = "test-vg-frontend_bucket"
  acl    = "private"  # Adjust based on your access requirements

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = "your-log-bucket"
    target_prefix = "s3-logs/"
  }

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = 365
    }
  }

  tags = {
    Name = "FrontendBucket"
  }
}