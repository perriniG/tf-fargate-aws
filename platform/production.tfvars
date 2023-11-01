# remote state bucket

remote_state_key    = "PROD/infra.tfstate"
remote_state_bucket = "emi-ecs-fargate-terraform-remote-state"

ecs_domain_name      = "prosolutionweb.com"
ecs_cluster_name     = "Production-ECS-Cluster"
internet_cidr_blocks = "0.0.0.0/0"