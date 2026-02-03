// Application Load Balancer

alb_name = "alb-internet-facing"

alb_target_port     = "80"
alb_target_protocol = "HTTP"
alb_target_type     = "ip"

alb_internal               = false
enable_deletion_protection = false

health_check_path     = "/"
health_check_protocol = "HTTP"
health_check_matcher  = "200-399"
health_check_interval = 30
health_check_timeout  = 10

alb_sg_ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP requests"
  }
]

alb_sg_egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]