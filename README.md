# Secure Dockerized Web Application on AWS

A production-ready, secure web application deployed on AWS using Docker and ECS Fargate.

## Architecture
- **Docker**: Multi-stage build, non-root user, Alpine image
- **AWS VPC**: Public/Private subnets, Internet Gateway
- **ECS Fargate**: Serverless container deployment
- **ECR**: Private container registry with vulnerability scanning
- **ALB**: Application Load Balancer for traffic distribution
- **Secrets Manager**: Secure secrets management
- **VPC Endpoints**: Private connectivity to AWS services
- **CI/CD**: GitHub Actions automated deployment pipeline

## Security Features
- Non-root container user
- Private subnets for containers
- Security groups with least privilege
- No secrets in code or Docker image
- Automated vulnerability scanning on push

## Tech Stack
Docker | AWS ECS | AWS ECR | AWS ALB | GitHub Actions | Node.js
