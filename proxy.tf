module "proxy_server" {
    source = "./modules/blue-green-module"

    cluster_name = "${var.env}-proxy"
    domain_name = var.domain_name
    alb_internal_flag = false
    
    zone_id = data.aws_route53_zone.public_zone_id.zone_id
    subnet_ids = module.vpc.public_subnets
    vpc_id = module.vpc.vpc_id

    app_listener_port = var.proxy_app_port
    target_port = var.proxy_app_port

    target_groups = [{
      backend_protocol     = "HTTPS"
      backend_port         = var.proxy_app_port
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/health"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTPS"
        matcher             = "200-399"
      }
    }]

    https_listeners = [{
            port               = var.proxy_app_port,
            protocol           = "HTTPS",
        }
    ]

    tags = {
        Environment = var.env
        Application = "${var.env}-proxy"
    }

    image_id = data.aws_ami.proxy_ami.id
    key_name = "ec2-key-pair"

    ### Reference https://github.com/tellisnz/terraform-aws/blob/master/terraform/web-asg.tf
    user_data = <<-EOF
              #!/bin/bash
              # install git/nginx
              yum install -y git gettext nginx
              echo "NETWORKING=yes" >/etc/sysconfig/network
              
              # install node
              curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
              . /.nvm/nvm.sh
              nvm install 6.11.5
              # setup sample app client
              git clone https://github.com/tellisnz/terraform-aws.git
              cd terraform-aws/sample-web-app/client
              npm install -g @angular/cli@1.1.0
              npm install
              export HOME=/root
              ng build
              rm /usr/share/nginx/html/*
              cp dist/* /usr/share/nginx/html/
              chown -R nginx:nginx /usr/share/nginx/html
              
              # configure and start nginx
              export APP_ELB="${module.elb_app.this_elb_dns_name}" APP_PORT="${var.app_port}" WEB_PORT="${var.web_port}"
              envsubst '$${APP_PORT} $${APP_ELB} $${WEB_PORT}' < nginx.conf.template > /etc/nginx/nginx.conf
              service nginx start
              EOF
 
}