resource "aws_security_group" "lb_sg" {
    name        = "${var.cluster_name}-alb-sg"
    description = "Allow TLS inbound traffic"
    vpc_id      = var.vpc_id
    
    tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-alb-sg"
    },
  )
}

resource "aws_security_group" "app_sg" {
    name        = "${var.cluster_name}-app-sg"
    description = "Allow TLS inbound traffic"
    vpc_id      = var.vpc_id
    
    tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-app-sg"
    },
  )
}

resource "aws_security_group_rule" "alb_tg_egress" {
  type                      = "egress"
  to_port                   = lookup(var.target_groups[0], "backend_port", null)
  protocol                  = "tcp"
  from_port                 = lookup(var.target_groups[0], "backend_port", null)
  security_group_id         = aws_security_group.app_sg.id
  source_security_group_id  = aws_security_group.lb_sg.id
}


resource "aws_security_group_rule" "tg_alb_ingress" {
  type                      = "ingress"
  to_port                   = lookup(var.target_groups[0], "backend_port", null)
  protocol                  = "tcp"
  from_port                 = lookup(var.target_groups[0], "backend_port", null)
  security_group_id         = aws_security_group.app_sg.id
  source_security_group_id  = aws_security_group.lb_sg.id
}