locals {
  common_name_suffix = "${var.project_name}-${var.environment}"
  subnet_id = data.aws_ssm_parameter.public_subnet_ids.value
  sg_id = data.aws_ssm_parameter.sg_id.value
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  public_subnet_id = split(",",data.aws_ssm_parameter.public_subnet_ids.value)[0]
 public_subnet_ids = data.aws_ssm_parameter.public_subnet_ids.value
 frontend_alb_listener_arn = data.aws_ssm_parameter.frontend_alb_listener_arn.value
 backend_alb_listener_arn = data.aws_ssm_parameter.backend_alb_listener_arn.value
 listener_arn = "${var.component}" == "frontend" ? local.frontend_alb_listener_arn : local.backend_alb_listener_arn
 host_header =  "${var.component}" == "frontend" ? "${var.project_name}-${var.environment}.${var.domain_name}" : "${var.component}.backend-alb-${var.environment}.${var.domain_name}"
  tg_port = "${var.component}" == "frontend" ? 80 : 8080
  health_check_path = "${var.component}" == "frontend" ? "/" : "/health"
ami_id = data.aws_ami.ami_id.id
}

locals {
  common_tags = {
    Project = "roboshop"
    Environment = "dev"
    Terraform = true
  }
}


