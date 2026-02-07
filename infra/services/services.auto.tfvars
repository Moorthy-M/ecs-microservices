//************* Services *************

/* Task Role Should be "ecs-task-role-{service_name}" resolve the task roles created in the bootstrap */

services = {
  "service1" = {
    family = "ecs_demo"
    cpu    = "256"
    memory = "512"

    launch_type   = "fargate"
    desired_count = 2
    task_role     = "ecs-task-role-service1"

    container = {
      name  = "myapp"
      image = "moorthy265/terraform-projects:v1"
      port  = 80
    }
  }
}
