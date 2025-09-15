#!/bin/bash
# Rollback script for ECS service

set -e

AWS_REGION="us-east-1"
CLUSTER_NAME="python-web-app-cluster"
SERVICE_NAME="python-web-app-service"

echo "Starting rollback process..."

# Get the previous task definition ARN
PREVIOUS_TASK_DEF=$(aws ecs describe-services --region $AWS_REGION --cluster $CLUSTER_NAME --services $SERVICE_NAME --query "services[0].deployments[?status=='PRIMARY'].taskDefinition" --output text)

if [ -z "$PREVIOUS_TASK_DEF" ]; then
    echo "Error: Could not find previous task definition"
    exit 1
fi

echo "Rolling back to task definition: $PREVIOUS_TASK_DEF"

# Update service to use previous task definition
aws ecs update-service --region $AWS_REGION --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition $PREVIOUS_TASK_DEF --force-new-deployment

echo "Rollback initiated successfully. Monitoring deployment..."

# Wait for service to stabilize
aws ecs wait services-stable --region $AWS_REGION --cluster $CLUSTER_NAME --services $SERVICE_NAME

echo "Rollback completed successfully."