resource "aws_route53_record" "cluster_alb" {

  name = var.cluster_name

  zone_id = var.zone_id
  type    = "CNAME"
  ttl     = "5"

  records        = [ aws_lb.this.dns_name ]
}