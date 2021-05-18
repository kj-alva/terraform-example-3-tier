module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${format("%s-vpc", var.env)}"
  azs = data.aws_availability_zones.available.names
  cidr = var.vpc_cidr

  public_subnets = var.vpc_public_subnets
  private_subnets = var.vpc_private_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az

  tags = {
    Environment = "${var.env}"
  } 
}