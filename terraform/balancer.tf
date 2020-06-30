resource "aws_alb" "webapp_alb" {
  name               = var.resource_names.load_balancer
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group_alb.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  depends_on         = [aws_security_group.security_group_alb]
}

resource "aws_alb_target_group" "webapp_tg" {
  name        = var.resource_names.target_group
  target_type = "instance"
  protocol    = "HTTP"
  port        = 3000
  vpc_id      = aws_vpc.vpc.id
  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 4
    interval            = 5
    matcher             = "200"
  }
  depends_on = [aws_vpc.vpc]
}

resource "aws_lb_listener" "webapp_alb_listener" {
  load_balancer_arn = aws_alb.webapp_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.webapp_tg.arn
  }
  depends_on = [aws_alb.webapp_alb, aws_alb_target_group.webapp_tg]
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.application.id}"
  alb_target_group_arn   = "${aws_alb_target_group.webapp_tg.arn}"
}