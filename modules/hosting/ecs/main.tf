resource "aws_ecs_cluster" "web" {
  name = "ecommerce-cluster"
}

data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*-x86_64"]
  }
  owners = ["amazon"]
}

resource "aws_iam_role" "ecs_role" {
  name = "ecsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_role_attachment" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = "ecsProfile"
  role = aws_iam_role.ecs_role.name
}

# Create launch template and asg
resource "aws_launch_template" "ecs_launch_template" {
  name = "${var.project_name}-lt"
  image_id = data.aws_ami.ecs_ami.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_profile.name
  }

  user_data = testing #add shell script
  vpc_security_group_ids = [] # Define security group
}

resource "aws_autoscaling_group" "main" {
  name = "${var.project_name}-asg"
  max_size = var.asg_max_size
  min_size = var.asg_min_size
  health_check_grace_period = 300
  vpc_zone_identifier = [var.private_subnet_a_id, var.private_subnet_b_id]
  target_group_arns = [var.target_group_arn]

  launch_template {
    id = aws_launch_template.ecs_launch_template.id
    version = aws_launch_template.ecs_launch_template.latest_version
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"
}

# Scaling policies
resource "aws_autoscaling_policy" "up" {
  name = "${var.project_name}_scale_up_policy"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name = "${var.project_name}_asg_scale_up_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 180
  statistic = "Average"
  threshold = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_description = "Monitors ec2 cpu utilization >= 80%"
  alarm_actions = [aws_autoscaling_policy.up.arn]
}

resource "aws_autoscaling_policy" "down" {
  name = "${var.project_name}_scale_down_policy"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name = "${var.project_name}_asg+scale_down_alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 180
  statistic = "Average"
  threshold = 15

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_description = "Monitors ec2 cpu utilization <= 15%"
  alarm_actions = [aws_autoscaling_policy.down.arn]
}