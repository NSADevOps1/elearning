
output "region" {
  value = var.region
}

output "e-learning-vpcnew_id" {
  value = aws_vpc.e-learning-vpcnew.id
}

output "e-learning-pub-sub1new_id" {
  value = aws_subnet.e-learning-pub-sub1new.id
}

output "e-learning-pub-sub2new_id" {
  value = aws_subnet.e-learning-pub-sub2new.id
}

output "e-learning-priv-sub1new_id" {
  value = aws_subnet.e-learning-priv-sub1new.id
}

output "e-learning-priv-sub2new_id" {
  value = aws_subnet.e-learning-priv-sub2new.id
}

output "e-learning-pub-rtb1_id" {
  value = aws_route_table.e-learning-pub-rtb1.id
}

output "e-learning-priv-rtb1_id" {
  value = aws_route_table.e-learning-priv-rtb1.id
}

output "e-learning-pub-sub1-assoc_id" {
  value = aws_route_table_association.e-learning-pub-sub1-assoc.id
}

output "e-learning-pub-sub2-assoc_id" {
  value = aws_route_table_association.e-learning-pub-sub2-assoc.id
}

output "e-learning-priv-sub1-assoc_id" {
  value = aws_route_table_association.e-learning-pub-sub1-assoc.id
}

output "e-learning-priv-sub2-assoc_id" {
  value = aws_route_table_association.e-learning-priv-sub2-assoc.id
}

output "e-learning-igw_id" {
  value = aws_internet_gateway.e-learning-igw.id
}

output "e-learning-pub-rtb1-intgtw_id" {
  value = aws_route.e-learning-pub-rtb1-intgtw.id
}

output "e-learning-eipnew_id" {
  value = aws_eip.e-learning-eipnew.id
}

output "e-learning-natgw_id" {
  value = aws_nat_gateway.e-learning-natgw.id
}

output "e-learning-priv-rtb-natgtw_id" {
  value = aws_nat_gateway.e-learning-natgw.id
}

output "e-learning-secgrpnew_id" {
  value = aws_security_group.e-learning-secgrpnew.id
}

output "e-learning-db-sub_id" {
  value = aws_db_subnet_group.e-learning-db-sub.id
}

output "elearning-db" {
  value     = "Server=${aws_db_instance.elearning-postsql.address}; Database=ExampleDB; Uid=${var.db_username}; Pwd=${var.db_password}"
  sensitive = true
}

output "db-parameter-grp" {
  value = aws_db_parameter_group.db-parameter-grp.id
}

output "repository_url" {
  value = data.aws_ecr_repository.e-learning-reponew
}

output "e-learning-cluster" {
  value = aws_ecs_cluster.e-learning-cluster.id
}

output "e-learning-alb_id" {
  value = aws_lb.e-learning-alb.id
}

output "e-learning-alb-listener_id" {
  value = aws_lb_listener.https-lb-listener.id
}

output "e-learning-targetgrp_id" {
  value = aws_lb_target_group.e-learning-targetgrp.id
}

output "asg-iam-role_id" {
  value = aws_iam_role.asg-iam-role.id
}

output "ecs-task-execution-role_policy_id" {
  value = aws_iam_role_policy_attachment.ecs-task-execution-role_policy.id
}

output "e_learning_taskdef_id" {
  value = aws_ecs_task_definition.e_learning_taskdef.id
}

output "assume_role_policy_json" {
  value = data.aws_iam_policy_document.assume_role_policy.json
}

output "e-learning-service_id" {
  value = aws_ecs_service.e-learning-service.id
}

output "e-learning-asgtarget_id" {
  value = aws_appautoscaling_target.e-learning-asgtarget.id
}

output "e-learning-ecs-policy_id" {
  value = aws_appautoscaling_policy.e-learning-ecs-policy
}

output "e-learning-cloudwatch_id" {
  value = aws_cloudwatch_metric_alarm.e-learning-cloudwatch.id
}

output "asg-scaling-role_id" {
  value = aws_iam_role.asg-scaling-role.id
}

output "asg-scaling-policy" {
  value = aws_iam_role_policy.asg-scaling-policy.id
}

output "e-learning-sns_id" {
  value = aws_sns_topic.e-learning-sns.id
}

output "e-learning-sqs-target_id" {
  value = aws_sns_topic_subscription.e-learning-sqs-target.id
}

output "sns-policy" {
  value = aws_sns_topic_policy.sns-policy.id
}

output "alb-http-listener" {
  value = aws_lb_listener.alb-http-listener.id
}

/* output "route53-hosted_zone"
value = data.aws_route53_zone.route53-hosted_zone.id {
}

output "calebcreative_record_id" {
  value = aws_route53_record.calebcreative_record.id
  } */
