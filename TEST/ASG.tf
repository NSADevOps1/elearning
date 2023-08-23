#Create An App Autoscaling and Target Group 
resource "aws_appautoscaling_target" "e-learning-asgtarget" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.e-learning-cluster.name}/${aws_ecs_service.e-learning-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.asg-scaling-role.arn
}


#Create Autoscaling Policy
resource "aws_appautoscaling_policy" "e-learning-ecs-policy" {
  name               = "e-learning-autoscaling-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.e-learning-asgtarget.resource_id
  scalable_dimension = aws_appautoscaling_target.e-learning-asgtarget.scalable_dimension
  service_namespace  = aws_appautoscaling_target.e-learning-asgtarget.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 2
    }

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}


#Create Cloudwatch Alarm
resource "aws_cloudwatch_metric_alarm" "e-learning-cloudwatch" {
  alarm_name          = "e-learning-cloudwatch"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ec2 cpu utilization and ECS"
  alarm_actions       = [aws_appautoscaling_policy.e-learning-ecs-policy.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.e-learning-cluster.name
    ServiceName = aws_ecs_service.e-learning-service.name
  }
}

resource "aws_iam_role" "asg-scaling-role" {
  name = "asg-scaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      }
    ]
  })
} 


# Policy for the role to assume the resource
resource "aws_iam_role_policy" "asg-scaling-policy" {
  name = "asg-scaling-policy"
  role = aws_iam_role.asg-scaling-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "application-autoscaling:*",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:GetMetricStatistics",
        "ecs:DescribeServices"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}






