variable "region" {}
variable "final-project" {}
variable "e-learning-vpcnew_cidr" {}
variable "instance_tenancy" {}
variable "e-learning-pub-sub1new_cidr" {}
variable "e-learning-pub-sub2new_cidr" {}
variable "e-learning-priv-sub1new_cidr" {}
variable "e-learning-priv-sub2new_cidr" {}
variable "availability_zones" {}
variable "e-learning-secgrpnew" {}
variable "e-learning-reponew" {}
variable "e-learning-cluster" {}
variable "e-learning-alb" {}
variable "e-learning-targetgrp" {}
variable "e_learning_taskdef" {}
variable "container_name" {}
variable "cpu" {}
variable "memory" {}
variable "e-learning-service" {}
variable "e-learning-sns" {}
variable "db_subnet_group_name" {}
variable "instance_class" {}
variable "identifier" {}
variable "db_username" {
  description = "Database administrator username"
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  sensitive   = true
}
variable "domain_name" {}


