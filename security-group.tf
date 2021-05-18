resource "aws_security_group" "rds" {
  name = format("%s-rds-sg", var.env)

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [ module.vpc.private_subnets_cidr_blocks ]
  }

  tags = {
    Group = var.env
  }

}

resource "aws_security_group_rule" "app_rds_egress" {
  type                      = "egress"
  to_port                   = var.db_port
  protocol                  = "tcp"
  from_port                 = var.db_port
  security_group_id         = module.app_server.app_sg_id
  source_security_group_id  = aws_security_group.rds.id
}


resource "aws_security_group_rule" "rds_app_ingress" {
  type                      = "ingress"
  to_port                   = var.db_port
  protocol                  = "tcp"
  from_port                 = var.db_port
  security_group_id         = aws_security_group.rds.id
  source_security_group_id  = module.app_server.app_sg_id
}

resource "aws_security_group_rule" "proxy_app_egress" {
  type                      = "egress"
  to_port                   = var.app_port
  protocol                  = "tcp"
  from_port                 = var.app_port
  security_group_id         = module.app_server.lb_sg_id
  source_security_group_id  = module.app_server.app_sg_id
}


resource "aws_security_group_rule" "app_proxy_ingress" {
  type                      = "ingress"
  to_port                   = var.app_port
  protocol                  = "tcp"
  from_port                 = var.app_port
  security_group_id         = aws_security_group.app_sg.id
  source_security_group_id  = aws_security_group.lb_sg.id
}