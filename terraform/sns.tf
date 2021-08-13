resource "aws_sns_topic" "bucket_changes" {
  name = "sns-${var.service_name}"
}

resource "aws_sns_topic_policy" "this" {
  arn = aws_sns_topic.bucket_changes.arn

  policy = data.aws_iam_policy_document.sns_policy.json
}

data "aws_iam_policy_document" "sns_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Receive",
      "SNS:Publish",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.id # current AWS account
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.bucket_changes.arn
    ]

    sid = "__default_statement_ID"
  }
}

data "aws_caller_identity" "current" {}