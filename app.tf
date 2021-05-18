module "app_server" {
    source = "./modules/blue-green-module"
    source = "git::https//github.com/kj-alva/terraform/modules"

    cluster_name = "${var.env}-ec2-app"
    domain_name = var.domain_name
    alb_internal_flag = true
    
    ### Hosted in private zone id
    zone_id = data.aws_route53_zone.private_zone_id.zone_id
    subnet_ids = module.vpc.private_subnets
    vpc_id = module.vpc.vpc_id

    app_listener_port = var.app_port
    target_port = var.app_port

    target_groups = [{
      backend_protocol     = "HTTPS"
      backend_port         = var.app_port
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
            port               = var.app_port,
            protocol           = "HTTPS",
        }
    ]

    tags = {
        Environment = var.env
        Application = "${var.env}-ec2-app"
    }

    image_id = data.aws_ami.app_ami.id
    key_name = "ec2-key-pair"

    ### Reference https://github.com/tellisnz/terraform-aws/blob/master/terraform/app-asg.tf
    user_data = <<-EOF
              #!/bin/bash
              yum install -y java-1.8.0-openjdk-devel wget git
              export JAVA_HOME=/etc/alternatives/java_sdk_1.8.0
              wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
              sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
              yum install -y apache-maven
              git clone https://github.com/tellisnz/terraform-aws.git
              cd terraform-aws/sample-web-app/server
              nohup mvn spring-boot:run -Dspring.datasource.url=jdbc:postgresql://"${module.rds.db_instance_address}:${var.db_port}/${var.db_name}" -Dspring.datasource.username="${var.db_username}" -Dspring.datasource.password="${var.db_password}" -Dserver.port="${var.app_port}" &> mvn.out &
              EOF
 
}