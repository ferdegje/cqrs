resource "aws_ecs_cluster" "main" {
  name = "tf-ecs-cluster"
}

resource "aws_ecs_task_definition" "webservice" {
  family = "webservice"

  container_definitions = "${file('task_definition.json')}"
}
