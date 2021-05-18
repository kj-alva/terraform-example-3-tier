resource "aws_s3_bucket" "lb_logs" {
    bucket        = "${var.cluster_name}-alb-logs"
    policy        = data.aws_iam_policy_document.cluster_alb_log_bucket_policy.json
    force_destroy = true

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-alb-logs"
    },
  )

  lifecycle_rule {
    id      = "log-expiration"
    enabled = "true"

    expiration {
      days = "7"
    }
  }
}

data "aws_iam_policy_document" "cluster_alb_log_bucket_policy" {
  statement {
    sid     = "AllowToPutLoadBalancerLogsToS3Bucket"
    actions = ["s3:PutObject"]

    resources = [
      "arn:aws:s3:::${var.cluster_name}-alb-logs/${var.cluster_name}-alb-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
    }
  }

  statement {
    sid     = "AWSLogDeliveryWrite"
    actions = ["s3:PutObject"]

    resources = [
      "arn:aws:s3:::${var.cluster_name}-alb-logs/${var.cluster_name}--alb-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid     = "AWSLogDeliveryAclCheck"
    actions = ["s3:GetBucketAcl"]

    resources = [
      "arn:aws:s3:::${var.cluster_name}-alb-logs",
    ]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

data "aws_elb_service_account" "main" {}

data "aws_caller_identity" "current" {}