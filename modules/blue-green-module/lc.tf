#######################
# Launch configuration
#######################
resource "aws_launch_configuration" "this" {
  count = var.create_lc ? 1 : 0

  name_prefix                 = "{var.cluster_name}-"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.arn

  security_groups             = aws_security_group.app_sg.id
  
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data
  enable_monitoring           = var.enable_monitoring
  spot_price                  = var.spot_price
  placement_tenancy           = var.spot_price == "" ? var.placement_tenancy : ""
  ebs_optimized               = var.ebs_optimized

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      no_device             = lookup(ebs_block_device.value, "no_device", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      virtual_name = ephemeral_block_device.value.virtual_name
    }
  }

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}