module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = format("%s-rds-db", var.env)

  engine               = "postgres"
  engine_version       = "11.10"
  family               = "postgres11" # DB parameter group
  major_engine_version = "11"   
  instance_class    = "db.t2.micro"
  allocated_storage = var.db_allocated_storage

  name = var.db_name
  username = data.aws_ssm_parameter.db_username.value
  ### Read sensitive information from ssm
  password = data.aws_ssm_parameter.db_password.value
  port     = var.db_port

  vpc_security_group_ids = [ aws_security_group.rds.id ]

  maintenance_window = var.db_maintenance_window
  backup_window      = var.db_backup_window

  # disable backups to create DB faster
  backup_retention_period = var.db_backup_retention_period

  subnet_ids = [ module.vpc.private_subnets ]

  tags = {
    Group = var.env
  }
}


data "aws_ssm_parameter" "db_password" {
  name = "/${var.env}/${var.ssm_db_password}"
}

data "aws_ssm_parameter" "db_username" {
  name = "/${var.env}/${var.db_username}"
}