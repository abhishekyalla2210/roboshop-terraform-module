  
resource "aws_instance" "main" {
    ami = var.ami_id
    subnet_id   = local.private_subnet_id
    instance_type = var.instance_type
    vpc_security_group_ids = [local.sg_id]
     tags = merge(
        local.common_tags,
        {
            Name = "${local.common_name_suffix}-${var.component}"
        }
    )
}

resource "terraform_data" "main" {

    triggers_replace = [
        aws_instance.main.id
    ]
     connection {
        type        = "ssh"
        user        = "ec2-user"
        password  = "DevOps321"
        host        = aws_instance.main.private_ip
  }
      provisioner "file" {
        source = "bootstrap.sh"  
        destination = "/tmp/bootstrap.sh"
      }
     provisioner "remote-exec" { 
     inline =   [
        "sudo chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh ${var.component}"
      ] 
    }  
    }



  



resource "aws_ec2_instance_state" "main" {
  instance_id = aws_instance.main.id
  state       = "stopped"
  depends_on = [ terraform_data.main ]
}

resource "aws_ami_from_instance" "main" {
  source_instance_id = aws_instance.main.id
  name               = "${local.common_name_suffix}-${var.component}-ami"
  depends_on = [ aws_ec2_instance_state.main ]
  }


resource "aws_lb_target_group" "main" {
  name     = "${local.common_name_suffix}-${var.component}"
  port     = local.tg_port
  protocol = "HTTP"
  vpc_id   =  local.vpc_id
  deregistration_delay = 60
    
     health_check {
    path                = local.health_check_path
    port                = local.tg_port
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 10
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_launch_template" "main" {
  name = "${local.common_name_suffix}-${var.component}"


  instance_initiated_shutdown_behavior = "terminate"
  image_id = aws_ami_from_instance.main.id
  instance_type = var.instance_type
  vpc_security_group_ids = [local.sg_id]
  update_default_version = true
 tag_specifications {
   resource_type = "instance"
 

 tags = merge(
  local.common_tags,
  {
    Name = local.common_name_suffix
  }
 ) 
 }
  tag_specifications {
   resource_type = "volume"
  tags = merge(
  local.common_tags,
  {
    Name = "${local.common_name_suffix}-${var.component}"
  }
 ) 
  
  }
}



resource "aws_autoscaling_group" "main" {
  name = "${local.common_name_suffix}-${var.component}"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = false
  depends_on = [ aws_lb_target_group.main ]
  launch_template {
    id = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }
  vpc_zone_identifier       = [local.private_subnet_ids]
  target_group_arns = [aws_lb_target_group.main.arn]
 instance_refresh {
  strategy = "Rolling"
  preferences {
    min_healthy_percentage = 50
  }
  triggers = [ "launch_template" ]

}
  
  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${local.common_name_suffix}-${var.component}"
      }
    )
  content {
    key                 = tag.key
    value               = tag.value
    propagate_at_launch = true
  }
  }
 timeouts {
    delete = "15m"
  }
  

}


resource "aws_autoscaling_policy" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.name
  name = "${local.common_name_suffix}-${var.component}"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
    
  }
 }


resource "aws_lb_listener_rule" "main" {
  listener_arn = local.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    host_header {
      values = [local.host_header]
    }
  }
}




















   