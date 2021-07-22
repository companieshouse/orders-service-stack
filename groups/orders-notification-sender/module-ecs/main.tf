resource "aws_security_group" "orders-notification-security-group" {
  name = var.deployment_name
  description = "Orders notification sender security group"
  vpc_id = var.vpc_id

  /*
  TODO: healthcheck API usage TBC
  ingress {
    from_port = ???
    to_port = ???
    protocol = "tcp"
    cidr_blocks = var.subnets # permit inbound connections from other applications
  }
  */

  # permit all outbound connections
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.deployment_name
    Environment = var.environment
    Service = var.application_name
  }
}

resource "aws_ecs_cluster" "orders-notification-ecs-cluster" {
  name = var.deployment_name
  setting {
    name  = "containerInsights"
    value = var.container_insights_enabled ? "enabled" : "disabled"
  }
  tags = {
    Name = var.deployment_name
    Environment = var.environment
    Service = var.application_name
  }
}

resource "aws_ecs_task_definition" "orders-notification-task" {
  family = var.deployment_name
  execution_role_arn = var.role_arn
  task_role_arn = var.role_arn
  cpu = var.cpu_units
  memory = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  container_definitions = templatefile("${path.module}/task-definition.tmpl", var.task_definition_parameters)
  tags = {
    Name = var.deployment_name
    Environment = var.environment
    Service = var.application_name
  }
}

resource "aws_ecs_service" "orders-notification-service" {
  name = var.deployment_name
  cluster = aws_ecs_cluster.orders-notification-ecs-cluster.id
  task_definition = aws_ecs_task_definition.orders-notification-task.arn
  desired_count = 1
  launch_type = "FARGATE"
  network_configuration {
    subnets = var.subnets
    security_groups = [aws_security_group.orders-notification-security-group.id]
  }
  tags = {
    Name = var.deployment_name
    Environment = var.environment
    Service = var.application_name
  }
}