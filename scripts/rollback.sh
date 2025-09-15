# Enhanced Rollback script for ECS service (Windows PowerShell version)

$ErrorActionPreference = "Stop"

$AWSRegion = "us-east-1"
$ClusterName = "python-web-app-cluster"
$ServiceName = "python-web-app-service"

Write-Host "Starting rollback process at $(Get-Date)"

try {
    # Get the current service details
    Write-Host "Getting current service details..."
    $serviceDetails = aws ecs describe-services --region $AWSRegion --cluster $ClusterName --services $ServiceName --output json | ConvertFrom-Json
    
    if (-not $serviceDetails.services -or $serviceDetails.services.length -eq 0) {
        Write-Host "❌ Error: ECS service '$ServiceName' not found in cluster '$ClusterName'"
        exit 1
    }

    # Get all task definitions for the service family
    Write-Host "Getting task definition history..."
    $taskDefinitions = aws ecs list-task-definitions --region $AWSRegion --family-prefix python-web-app --sort DESC --output json | ConvertFrom-Json
    
    if (-not $taskDefinitions.taskDefinitionArns -or $taskDefinitions.taskDefinitionArns.length -lt 2) {
        Write-Host "❌ Error: Not enough task definitions for rollback. Need at least 2, found $($taskDefinitions.taskDefinitionArns.length)"
        exit 1
    }

    # Get the previous task definition (skip the current one)
    $previousTaskDef = $taskDefinitions.taskDefinitionArns[1]
    Write-Host "Rolling back to previous task definition: $previousTaskDef"

    # Update service to use previous task definition
    Write-Host "Updating ECS service..."
    $updateResult = aws ecs update-service --region $AWSRegion --cluster $ClusterName --service $ServiceName --task-definition $previousTaskDef --force-new-deployment --output json | ConvertFrom-Json
    
    Write-Host "✅ Rollback initiated successfully"
    Write-Host "New service configuration:"
    Write-Host "  Task Definition: $($updateResult.service.taskDefinition)"
    Write-Host "  Desired Count: $($updateResult.service.desiredCount)"
    Write-Host "  Running Count: $($updateResult.service.runningCount)"

    # Wait for service to stabilize with timeout
    Write-Host "Waiting for service to stabilize (timeout: 300 seconds)..."
    $timeout = 300
    $startTime = Get-Date
    $serviceStable = $false
    
    while (((Get-Date) - $startTime).TotalSeconds -lt $timeout) {
        $serviceStatus = aws ecs describe-services --region $AWSRegion --cluster $ClusterName --services $ServiceName --output json | ConvertFrom-Json
        $deployments = $serviceStatus.services[0].deployments
        
        $primaryDeployment = $deployments | Where-Object { $_.status -eq "PRIMARY" }
        
        if ($primaryDeployment.rolloutState -eq "COMPLETED" -and $primaryDeployment.desiredCount -eq $primaryDeployment.runningCount) {
            $serviceStable = $true
            break
        }
        
        Write-Host "Service status: $($primaryDeployment.rolloutState), Desired: $($primaryDeployment.desiredCount), Running: $($primaryDeployment.runningCount)"
        Start-Sleep -Seconds 10
    }

    if ($serviceStable) {
        Write-Host "✅ Rollback completed successfully at $(Get-Date)"
        Write-Host "Service is now stable with task definition: $previousTaskDef"
    } else {
        Write-Host "⚠️  Rollback initiated but service did not stabilize within timeout period"
        Write-Host "Please check ECS console for current status"
    }

} catch {
    Write-Host "❌ Rollback failed with error: $($_.Exception.Message)"
    Write-Host "Please perform manual rollback through AWS Console"
    exit 1
}