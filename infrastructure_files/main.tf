resource "aws_ecs_cluster" "dotnet_cluster" {
  name = "dotnet-ecs-cluster"
}

resource "aws_lb" "dotnet_alb" {
  name               = "dotnet-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "dotnet_tg" {
  name     = "dotnet-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "dotnet_listener" {
  load_balancer_arn = aws_lb.dotnet_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dotnet_tg.arn
  }
}

resource "aws_ecs_task_definition" "dotnet_task" {
  family                   = "dotnet-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions    = file("task_definition.json")
}

resource "aws_ecs_service" "dotnet_service" {
  name            = "dotnet-service"
  cluster         = aws_ecs_cluster.dotnet_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.dotnet_task.arn
  desired_count   = 2

  network_configuration {
    subnets         = module.vpc.public_subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dotnet_tg.arn
    container_name   = "dotnet-app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.dotnet_listener]
}

