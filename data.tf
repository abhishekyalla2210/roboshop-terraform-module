
data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${local.common_name_suffix}/public_subnet_ids"
}


data "aws_ssm_parameter" "sg_id" {
  name = "/${local.common_name_suffix}/${var.component}"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${local.common_name_suffix}/vpc_id"
}


data "aws_ssm_parameter" "private_subnet_id" {
  name = "/${local.common_name_suffix}/private_subnet_ids"
}



data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${local.common_name_suffix}/private_subnet_ids"
}


data "aws_ssm_parameter" "frontend_alb_listener_arn" {
  name = "/${local.common_name_suffix}/frontend_alb_listener_arn"
}

data "aws_ssm_parameter" "backend_alb_listener_arn" {
  name = "/${local.common_name_suffix}/backend_alb_listener_arn"
}





