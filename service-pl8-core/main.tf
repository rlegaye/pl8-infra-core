resource "aws_cloudwatch_log_group" "this" {
  name_prefix       = "pl8_core-"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "this" {
  family = "pl8_core"

  container_definitions = <<EOF
[
  {
    "name": "pl8_core",
    "image": "pl8-core",
    "cpu": 0,
    "memory": 128,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-2",
        "awslogs-group": "${aws_cloudwatch_log_group.this.name}",
        "awslogs-stream-prefix": "ec2"
      }
    },
    "environment" : [
        {
            "name" : "db_pass",
            "value": "${var.database_pass}"
        },
        {
            "name" : "db_user",
            "value": "${var.database_username}"
        }
	]
  }
]
EOF
}

resource "aws_ecs_service" "this" {
  name            = "pl8_core"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
