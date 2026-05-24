# Secure Dockerized Web Application on AWS

A production-ready, secure web application deployed on AWS using Docker and ECS Fargate.

## Architecture

```
Internet → ALB (public subnet) → ECS Fargate (private subnet) → ECR (via VPC Endpoints)
                                                                      ↓
                                                              Secrets Manager
```

## Infrastructure Components

- **Docker**: Multi-stage build, non-root user, Alpine image (48MB vs 900MB)
- **AWS VPC**: Public/Private subnets, Internet Gateway, Route Tables
- **ECS Fargate**: Serverless container deployment in private subnets
- **ECR**: Private container registry with vulnerability scanning on push
- **ALB**: Application Load Balancer for traffic distribution
- **Secrets Manager**: Secure secrets management (no secrets in code or image)
- **VPC Endpoints**: Private connectivity to ECR, S3, Secrets Manager, CloudWatch
- **Security Groups**: Least privilege — ALB only accepts port 80, containers only accept from ALB
- **CI/CD**: GitHub Actions automated build and deploy pipeline
- **Terraform**: Full Infrastructure as Code

## Security Features

- Non-root container user (appuser)
- Private subnets for containers — not directly accessible from internet
- Security groups with least privilege access
- No secrets in code, Dockerfile, or Docker image
- Automated vulnerability scanning on every image push
- VPC Endpoints — traffic stays inside AWS network
- IAM roles scoped to minimum required permissions

## CI/CD Pipeline

Every `git push` to main branch:
1. Builds Docker image
2. Pushes to ECR
3. Deploys to ECS Fargate automatically

## Tech Stack

`Docker` `AWS ECS Fargate` `AWS ECR` `AWS ALB` `AWS VPC` `Secrets Manager` `GitHub Actions` `Terraform` `Node.js`

## Project Structure

```
secure-docker-app/
├── .github/workflows/
│   └── deploy.yml        # CI/CD Pipeline
├── terraform/
│   ├── main.tf           # VPC, Subnets, SGs, ECS, ALB
│   ├── variables.tf      # Input variables
│   ├── outputs.tf        # Output values
│   └── providers.tf      # AWS provider config
├── Dockerfile            # Multi-stage secure build
├── .dockerignore         # Excludes secrets and cache
└── server.js             # Node.js application
```
