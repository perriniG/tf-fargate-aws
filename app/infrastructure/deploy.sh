#!/bin/sh
REGION="eu-west-1"
SERVICE_NAME="springbootapp"
SERVICE_TAG="${SERVICE_TAG}"
ECR_REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${SERVICE_NAME}"

####### build stage
if   [ "$1" =   "build" ];then
    echo "Building the application..."
    #cd ..
    mvn -e clean install

###### Docker in action 
elif [ "$1" =   "dockerize" ];then   
    #find ../target/ -t f \( -name "*.jar" -not -name "*sources.jar" \) -exec cp {} ../infrastructure/$SERVICE_NAME.jar \;
    $(aws ecr get-login --no-include-email --region eu-west-1)
    aws ecr creater-repository --repository-name ${SERVICE_NAME:?} || true
    docker build -t ${SERVICE_NAME}:${SERVICE_TAG} .
    docker tag ${SERVICE_NAME}:${SERVICE_TAG}
    docker push ${ECR_REPO_URL}:${SERVICE_TAG}

###### Terraform Stage 
elif [ "$1" =   "plan" ];then
    terraform init -backend-config="app-prod.config"
    terraform plan -var-file="production.tfvars" -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}"

elif [ "$1" =   "deploy" ];then
    terraform init -backend-config="app-prod.config"
    terraform tain -allow-missing aws_ecs_task_definition.springbootapp-task-definition
    terraform apply -var-file="production.tfvars" -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}" -auto-approve

elif [ "$1" =   "destroy" ];then
    terraform init -backend-config="app-prod.config"
    terraform destroy -var-file="production.tfvars" -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}" -auto-approve
fi