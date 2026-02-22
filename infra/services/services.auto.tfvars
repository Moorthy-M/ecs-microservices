//************* Services *************

/* Task Role Should be "ecs-task-role-{service_name}" resolve the task roles created in the bootstrap */

services = {
  "frontend" = {
    family = "ecs_frontend"
    cpu    = "256"
    memory = "512"

    launch_type   = "fargate"
    desired_count = 2
    task_role     = "ecs-task-role-frontend"

    alb = {
      route_path  = "/*"
      health_path = "/health"
      protocol    = "HTTP"
      priority    = 500
    }

    container = {
      name  = "frontend"
      image = "moorthy265/ecs-microservices:frontend-v1"
      port  = 8080
    }
  }

  "authentication" = {
    family = "ecs_authentication"
    cpu    = "256"
    memory = "512"

    launch_type   = "fargate"
    desired_count = 2
    task_role     = "ecs-task-role-authentication"

    alb = {
      route_path  = "/auth/*"
      health_path = "/auth/health"
      protocol    = "HTTP"
      priority    = 100
    }

    container = {
      name    = "authentication"
      image   = "moorthy265/ecs-microservices:authentication-v1"
      port    = 8081
      secrets = true
    }
  }

  "catalog" = {
    family = "ecs_catalog"
    cpu    = "256"
    memory = "512"

    launch_type   = "fargate"
    desired_count = 2
    task_role     = "ecs-task-role-catalog"

    alb = {
      route_path  = "/catalog/*"
      health_path = "/catalog/health"
      protocol    = "HTTP"
      priority    = 200
    }

    container = {
      name  = "catalog"
      image = "moorthy265/ecs-microservices:catalog-v1"
      port  = 8082
    }
  }
}