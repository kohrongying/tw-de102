locals {
  bucket_name = "s3-${var.service_name}.rongying.co"
}
resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
  acl    = "public-read"
  policy = data.template_file.bucket_policy.rendered

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://${local.bucket_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

data "template_file" "bucket_policy" {
  template = file("bucket_policy.json.tpl")

  vars = {
    bucket = local.bucket_name
  }
}

resource "aws_s3_bucket_notification" "bucket_notif" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}