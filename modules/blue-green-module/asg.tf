####################
# Autoscaling group
####################
resource "aws_autoscaling_group" "this" {
  count = var.create_asg ? 1 : 0

  name_prefix = "${join(
    "-",
    compact(
      [
        var.cluster_name,
        var.recreate_asg_when_lc_changes ? element(concat(random_pet.asg_name.*.id, [""]), 0) : "",
      ],
    ),
  )}-"
  launch_configuration = var.create_lc ? element(concat(aws_launch_configuration.this.*.name, [""]), 0) : var.launch_configuration
  vpc_zone_identifier  = var.subnet_ids
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity

  load_balancers            = var.load_balancers
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  min_elb_capacity          = var.min_elb_capacity
  wait_for_elb_capacity     = var.wait_for_elb_capacity

  target_group_arns         = aws_lb_target_group.main_blue.*.id

  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group           = var.placement_group
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = var.metrics_granularity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = var.cluster_name
        "propagate_at_launch" = true
      },
    ],
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "asg_name" {
  count = var.recreate_asg_when_lc_changes ? 1 : 0

  separator = "-"
  length    = 2

  keepers = {
    # Generate a new pet name each time we switch launch configuration
    lc_name = var.create_lc ? element(concat(aws_launch_configuration.this.*.name, [""]), 0) : var.launch_configuration
  }
}
