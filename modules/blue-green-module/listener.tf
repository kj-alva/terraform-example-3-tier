resource "aws_lb_listener" "frontend_https" {

  load_balancer_arn = aws_lb.this.arn

  port            = var.https_listeners["port"]
  protocol        = lookup(var.https_listeners, "protocol", "HTTPS")
  certificate_arn = module.acm.this_acm_certificate_arn
  ssl_policy      = lookup(var.https_listeners, "ssl_policy", var.listener_ssl_policy_default)

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.main_blue.*.id[0]
        weight = lookup(var.https_listeners[0], "blue_weight")
      }

      target_group {
        arn    = aws_lb_target_group.main_blue.*.id[1]
        weight = lookup(var.https_listeners[1], "green_weight")
      }

      stickiness {
        enabled  = true
        duration = 600
      }
    }
  }
}