resource "aws_iam_instance_profile" "ec2_profile" {
  name       = var.resource_names.profile
  role       = aws_iam_role.db_conn_role.id
  depends_on = [aws_iam_role.db_conn_role]
}

data "template_file" "bootstrap" {
  template = file("bootstrap.sh")
}

resource "aws_launch_template" "application" {
  name_prefix   = "app"
  image_id      = "ami-06ce3edf0cff21f07"
  instance_type = "t2.micro"
  user_data     = base64encode(data.template_file.bootstrap.rendered)
  vpc_security_group_ids = [aws_security_group.security_group_ec2.id]
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
}

resource "aws_autoscaling_group" "application" {
  vpc_zone_identifier = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  desired_capacity    = 3
  max_size            = 5
  min_size            = 2

  launch_template {
    id      = aws_launch_template.application.id
    version = "$Latest"
  }
}
