resource "aws_ecs_cluster" "main" {
  name = "${var.name}"
}

resource "aws_ecs_task_definition" "webservice" {
  family = "${var.name}-webservice"

  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = "${aws_iam_role.ecs_task_assume.arn}"
  container_definitions = "${file("${path.module}/task_definition.json")}"
  cpu = 256
  memory = 512
}

locals {
  web_port = 80
  app_port = 5000
}

resource "aws_ecs_service" "webservice" {
  name            = "${var.name}-webservice"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.webservice.arn}"
  desired_count   = "1"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks.id}"]
    subnets         = ["${var.aws_subnets}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "HelloWorld"
    container_port   = "${local.app_port}"
  }

  depends_on = [
    "aws_alb_listener.front_end",
  ]
}

resource "aws_alb_target_group" "app" {
  name        = "tf-ecs-chat"
  port        = "${local.app_port}"
  protocol    = "HTTP"
  vpc_id      = "${var.aws_vpc}"
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/"
    port                = "${local.app_port}"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202,302"
  }
}

resource "aws_alb" "main" {
  name            = "tf-ecs-chat"
  subnets         = ["${var.aws_subnets}"]
  security_groups = ["${aws_security_group.lb.id}"]
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "${local.web_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}



# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name        = "tf-ecs-alb"
  description = "controls access to the ALB"
  vpc_id      = "${var.aws_vpc}"

  ingress {
    protocol    = "tcp"
    from_port   = "${local.web_port}"
    to_port     = "${local.web_port}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "tf-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${var.aws_vpc}"

  ingress {
    protocol        = "tcp"
    from_port       = "${local.app_port}"
    to_port         = "${local.app_port}"
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "webservice" {
  name = "${lower(var.name)}"
}
