resource "aws_lb" "this" {
  name               = "${var.cluster_name}-alb"
  internal           = var.alb_internal_flag
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "${var.cluster_name}-alb-logs"
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-alb"
    },
  )
}