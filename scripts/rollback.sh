# Rollback script for ECS service (Windows PowerShell version)

$ErrorActionPreference = "Stop"

$AWSRegion = "us-east-1"
$ClusterName = "python-web-app-cluster"
$ServiceName = "python-web-app-service"

Write-Host "Starting rollback process..."

# Get the previous task definition ARN
$PreviousTaskDef = aws ecs describe-services --region $AWSRegion --cluster $ClusterName --services $ServiceName --query "services[0].deployments[?status=='PRIMARY'].taskDefinition" --output text

if ([string]::IsNullOrEmpty($PreviousTaskDef)) {
    Write-Host "Error: Could not find previous task definition"
    exit 1
}

Write-Host "Rolling back to task definition: $PreviousTaskDef"

# Update service to use previous task definition
aws ecs update-service --region $AWSRegion --cluster $ClusterName --service $ServiceName --task-definition $PreviousTaskDef --force-new-deployment

Write-Host "Rollback initiated successfully. Monitoring deployment..."

# Wait for service to stabilize
aws ecs wait services-stable --region $AWSRegion --cluster $ClusterName --services $ServiceName

Write-Host "Rollback completed successfully."