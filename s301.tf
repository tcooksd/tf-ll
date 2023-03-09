provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket"
  versioning {
    enabled = true
  }
  # Example bucket policy restricting access to specific IP addresses
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          "${aws_s3_bucket.example.arn}",
          "${aws_s3_bucket.example.arn}/*"
        ]
        Condition = {
          IpAddress : {
            "aws:SourceIp": ["10.0.0.0/8", "192.168.0.0/16"]
          }
        }
      }
    ]
  })
  # Example access logging to separate bucket
  logging {
    target_bucket = "my-example-logging-bucket"
    target_prefix = "access-logs/"
  }
}


resource "aws_iam_policy" "bucket_policy" {
  name        = "example-bucket-policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          "${aws_s3_bucket.example.arn}",
          "${aws_s3_bucket.example.arn}/*"
        ]
        Condition = {
          IpAddress : {
            "aws:SourceIp": ["10.0.0.0/8", "192.168.0.0/16"]
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id
  policy = aws_iam_policy.bucket_policy.policy
}