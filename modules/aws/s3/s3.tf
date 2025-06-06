resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags = {
    Environment = "DevOpsTest"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

variable "bucket_name" {
  type = string
}


