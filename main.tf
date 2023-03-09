provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.access_logging_bucket_name
}

resource "aws_s3_bucket_acl" "tcook_test_acl1" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "tcook_test" {
  bucket = var.tcook_example_bucket
}

resource "aws_s3_bucket_acl" "tcook_test_acl" {
  bucket = aws_s3_bucket.tcook_test.id
  acl    = var.acl_value
}

resource "aws_s3_bucket_versioning" "my_protected_bucket_versioning" {
  bucket = aws_s3_bucket.tcook_test.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "tcook_test" {
  bucket = aws_s3_bucket.tcook_test.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "example_lifecycle" {
  bucket = aws_s3_bucket.tcook_test.id
  rule {
    id = "exampl_rule"
    status = "Enabled"
    filter {
      prefix = "/logs"
    }
    expiration {
      days = 40
    }
    transition {
      days = 35
      storage_class = "STANDARD_IA"
    }
  }
  
}