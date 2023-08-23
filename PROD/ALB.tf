
#Create docker image and repository
data "aws_ecr_repository" "e-learning-reponew" {
  name = var.e-learning-reponew
}


#Create Container Cluster
resource "aws_ecs_cluster" "e-learning-cluster" {
  name = var.e-learning-cluster
}


#Create Load Balancer
resource "aws_lb" "e-learning-alb" {
  name               = "e-learning-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.e-learning-pub-sub1new.id, aws_subnet.e-learning-pub-sub2new.id]
  security_groups    = [aws_security_group.e-learning-secgrpnew.id]

  tags = {
    Name = "${var.e-learning-alb}"
  }
}

resource "aws_lb_listener" "alb-http-listener" {
  load_balancer_arn = aws_lb.e-learning-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.e-learning-targetgrp.arn
  }
}

resource "aws_lb_listener_certificate" "alb-ssl-cert" {
  listener_arn    = aws_lb_listener.https-lb-listener.arn
  certificate_arn = data.aws_acm_certificate.mycaleb-domain-cert.arn
}


#Create Aplication Load Balancer Listener
resource "aws_lb_listener" "https-lb-listener" {
  load_balancer_arn = aws_lb.e-learning-alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.mycaleb-domain-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.e-learning-targetgrp.arn
  }
}


# SSL certificate that is issued
data "aws_acm_certificate" "mycaleb-domain-cert" {
  domain   = "calebcreatives.click"
  statuses = ["ISSUED"]
}


#Create  Auto Scaling Target Group for Load Balancer
resource "aws_lb_target_group" "e-learning-targetgrp" {
  name        = "e-learning-targetgrp"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.e-learning-vpcnew.id

  health_check {
    healthy_threshold   = "2"
    interval            = "50"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/v1/status"
    unhealthy_threshold = "3"
  }

  tags = {
    Name = "${var.e-learning-targetgrp}"
  }
}

/* port        = 443
protocol    = "HTTPS" */


#Create IAM Role for ECS Auto Scaling
resource "aws_iam_role" "asg-iam-role" {
  name = "asg-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "sts:AssumeRole",

      ]
      Principal = {
        Service = ["ecs-tasks.amazonaws.com"]
      }
      Effect = "Allow"
    }]
  })
}


# Create the IAM policy for the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.asg-iam-role.name
}


#Create Task Definition
resource "aws_ecs_task_definition" "e_learning_taskdef" {
  family = "e_learning_taskdef"
  container_definitions = jsonencode([
    {
      name   = var.container_name
      image  = "${data.aws_ecr_repository.e-learning-reponew.repository_url}:latest"
      cpu    = var.cpu
      memory = var.memory
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  execution_role_arn = aws_iam_role.asg-iam-role.arn
}


# allow events role to run ecs tasks
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["ecs:RunTask"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


#Create Elastic Container Service 
resource "aws_ecs_service" "e-learning-service" {
  name                = var.e-learning-service
  cluster             = aws_ecs_cluster.e-learning-cluster.id
  task_definition     = aws_ecs_task_definition.e_learning_taskdef.id
  desired_count       = 2
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
    assign_public_ip = true
    subnets          = [aws_subnet.e-learning-priv-sub1new.id, aws_subnet.e-learning-priv-sub2new.id]
    security_groups  = [aws_security_group.e-learning-secgrpnew.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.e-learning-targetgrp.arn
    container_name   = var.e-learning-reponew
    container_port   = 80
  }

  depends_on = [aws_lb_listener.https-lb-listener, aws_iam_role_policy_attachment.ecs-task-execution-role_policy]
}


#Reference Route 53 (calling ans exisiting resource)
data "aws_route53_zone" "route53-hosted_zone" {
  name = var.domain_name
}


resource "aws_route53_record" "calebcreative_record" {
  zone_id = data.aws_route53_zone.route53-hosted_zone.id
  name    = "calebcreatives.click"
  type    = "A"

  alias {
    name                   = aws_lb.e-learning-alb.dns_name
    zone_id                = aws_lb.e-learning-alb.zone_id
    evaluate_target_health = true
  }
}
