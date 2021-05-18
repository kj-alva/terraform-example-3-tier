data "aws_ami" "proxy_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [ var.proxy_version !=  null ? "${var.proxy_ami_name}-${var.proxy_version}*" : "${var.proxy_ami_name}*"]
  }
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [ var.app_version !=  null ? "${var.app_ami_name}-${var.app_version}*" : "${var.app_ami_name}*"]
  }
}

data "aws_route53_zone" "private_zone_id" {
  name         = var.domain_name
  private_zone = true
}

data "aws_route53_zone" "public_zone_id" {
  name         = var.domain_name
  private_zone = false
}