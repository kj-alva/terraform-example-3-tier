module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name  = var.domain_name
  zone_id      = var.zone_id

  subject_alternative_names = [
    "*.${var.domain_name}",
    "${var.cluster_name}.${var.domain_name}"
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-acm"
    },
  )
}