resource "aws_ecs_cluster" "main" {
  name = "tf-ecs-cluster"
}

resource "aws_ecs_task_definition" "webservice" {
  family = "webservice"

  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = "${aws_iam_role.ecs_task_assume.arn}"
  container_definitions = "${file("${path.module}/task_definition.json")}"
  cpu = 256
  memory = 512
}
