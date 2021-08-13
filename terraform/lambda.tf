locals {
  lambda_function_name = "lambda-${var.alerting_service_name}"
}

resource "aws_lambda_function" "this" {
  function_name = local.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "nodejs12.x"
  handler       = "on_bucket_change.handler"
  filename      = "index.zip"
  source_code_hash = filebase64sha256("index.zip")

  lifecycle {
    ignore_changes = [source_code_hash, layers]
  }

  environment {
    variables = {
      sns_topic_arn = aws_sns_topic.bucket_changes.arn
    } 
  }

  depends_on = [
    aws_iam_role_policy_attachment.basic,
    aws_cloudwatch_log_group.example,
  ]
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 14
}
resource "aws_iam_role" "iam_for_lambda" {
  name = "role-${local.lambda_function_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "basic" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "sns" {
  name = "policy-${var.alerting_service_name}-sns"
  policy = data.aws_iam_policy_document.allow_sns.json
}

data "aws_iam_policy_document" "allow_sns" {
  statement {
    sid = "AllowSNSPublish"
    actions = ["sns:Publish"]

    resources = [
      aws_sns_topic.bucket_changes.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "attach_sns" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.sns.arn
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3BucketChange"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.bucket.arn
}