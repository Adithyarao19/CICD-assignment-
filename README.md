# CI/CD Pipeline for Python Web App on AWS

This project implements a complete CI/CD pipeline for a Python web application using AWS services, GitHub Actions, and Terraform.

## Architecture



The architecture consists of:
1. **GitHub Actions** for CI/CD automation
2. **Amazon ECR** for Docker image storage
3. **Amazon ECS Fargate** for container orchestration
4. **Application Load Balancer** for traffic distribution
5. **Amazon CloudFront** for global content delivery
6. **Terraform** for Infrastructure as Code

## Tech Stack Justification

- **GitHub Actions**: Chosen for its seamless integration with GitHub repositories, extensive marketplace actions, and cost-effectiveness for public repositories.
- **Terraform**: Preferred over CloudFormation for its multi-cloud capabilities, modularity, and large community support.
- **Amazon ECS Fargate**: Selected for its serverless nature, eliminating the need to manage underlying infrastructure.
- **AWS Fargate**: Provides the right balance of simplicity and scalability without managing EC2 instances.
- **CloudFront**: Enhances application performance with global CDN capabilities and SSL termination.
- **Application Load Balancer**: Distributes traffic efficiently across ECS tasks and provides health checking.

## Prerequisites

1. AWS Account with appropriate permissions
2. GitHub Repository
3. Terraform installed locally (for manual infrastructure deployment)
4. AWS CLI configured with credentials

