## remote state config
remote_state_key    = "PROD/platform.tfstate"
remote_state_bucket = "ecs-fargate-terraform-remote-state"

## service variable
ecs_service_name      = "springbootapp"
docker_container_port = 8080
desirable_task_number = "2"
spring_profile        = "default"
memory                = 1024