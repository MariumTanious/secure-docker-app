# Secure Dockerized Web Application on AWS

A production-ready, secure web application deployed on AWS using Docker and ECS Fargate.

---

## Architecture

```
Internet
    ↓
ALB (public subnet)          ← accepts HTTP on port 80
    ↓
ECS Fargate (private subnet) ← runs Docker container on port 3000
    ↓
ECR (via VPC Endpoints)      ← pulls Docker image privately
    ↓
Secrets Manager              ← fetches secrets at runtime
```

---

## What I Built & Why

### 1. Docker — Secure Image
Built a hardened Docker image using:
- **Multi-stage build**: separates build stage from production stage — source code and build tools never end up in the final image
- **Alpine base image**: 48MB instead of 900MB with node:latest — smaller attack surface
- **Non-root user**: container runs as `appuser` not root — if compromised, attacker has no system privileges
- **exec form CMD**: proper signal handling so container shuts down cleanly

### 2. AWS VPC — Network Isolation
Created a custom VPC with 4 subnets:
- **2 Public Subnets**: only the ALB lives here — accessible from internet
- **2 Private Subnets**: containers live here — not directly accessible from internet
- **Internet Gateway + Route Table**: routes public traffic correctly
- Why 2 of each? AWS requires 2 Availability Zones for the load balancer — also provides high availability

### 3. ECR — Private Container Registry
- **Scan on push**: every image is automatically scanned for vulnerabilities when pushed
- **Image tag immutability**: prevents overwriting existing image tags — ensures what's deployed is exactly what was tested

### 4. ECS Fargate — Serverless Containers
- **Fargate vs EC2**: with Fargate, AWS manages the underlying servers — no patching, no scaling servers manually
- **Task Definition**: defines CPU (0.5 vCPU), memory (1GB), image, port, logging, and secrets
- **Service**: ensures 1 task is always running — restarts automatically if it crashes

### 5. ALB — Load Balancer
- Sits in the public subnet and accepts HTTP traffic on port 80
- Forwards traffic to containers in private subnets on port 3000
- **Target Group**: health checks every 30 seconds — unhealthy containers stop receiving traffic
- Separates public-facing infrastructure from application containers

### 6. Security Groups — Firewall Rules
Two security groups with least privilege:
- **alb-sg**: only accepts port 80 from anywhere (0.0.0.0/0)
- **app-sg**: only accepts port 3000 from alb-sg — containers are unreachable from anywhere else
- This means even if someone knows the container's IP, they cannot reach it directly

### 7. VPC Endpoints — Private AWS Connectivity
Created 4 VPC Endpoints so containers in private subnets can reach AWS services without going through the internet:
- **ecr.api**: authenticate with ECR
- **ecr.dkr**: pull Docker image layers
- **s3**: pull image layers stored in S3
- **secretsmanager**: fetch secrets at runtime
- **logs**: send container logs to CloudWatch
Without these, containers would need a NAT Gateway (more expensive, less secure)

### 8. Secrets Manager — No Secrets in Code
- DB passwords and API keys stored in Secrets Manager under `prod/app/db-password`
- ECS injects the secret as an environment variable at runtime
- Secret never appears in the Dockerfile, code, or Docker image
- IAM policy on `ecsTaskExecutionRole` limits access to only the specific secret ARN

### 9. IAM — Least Privilege
Two separate roles:
- **Execution Role** (`ecsTaskExecutionRole`): used by ECS to pull the image from ECR and fetch secrets — before the container starts
- **Task Role**: used by the running container to call AWS services at runtime (e.g. S3, DynamoDB)
Keeping them separate follows the principle of least privilege

### 10. CI/CD Pipeline — GitHub Actions
Every `git push` to main branch triggers:
1. Checkout code
2. Configure AWS credentials (stored as GitHub Secrets — never in code)
3. Login to ECR
4. Build Docker image tagged with the git commit SHA
5. Push image to ECR
6. Force new ECS deployment

### 11. Terraform — Infrastructure as Code
The entire infrastructure is defined as code:
- `providers.tf`: AWS provider configuration
- `variables.tf`: reusable variables (region, app name, CIDR blocks)
- `main.tf`: all resources (VPC, subnets, security groups, ECR, ECS, ALB, IAM)
- `outputs.tf`: useful values after deployment (ALB DNS, ECR URL, VPC ID)

Benefits: reproducible, version-controlled, reviewable infrastructure

---

## Security Checklist

- [x] Container runs as non-root user
- [x] Alpine base image — minimal attack surface
- [x] Multi-stage build — no source code in production image
- [x] No secrets in code, Dockerfile, or environment variables
- [x] Secrets fetched from AWS Secrets Manager at runtime
- [x] Containers in private subnets — not internet-facing
- [x] Security groups enforce least privilege
- [x] VPC Endpoints — traffic stays inside AWS network
- [x] ECR scan on push — vulnerability detection
- [x] IAM roles scoped to minimum required permissions
- [x] CI/CD credentials stored as GitHub Secrets

---

## Tech Stack

`Docker` `AWS ECS Fargate` `AWS ECR` `AWS ALB` `AWS VPC` `AWS Secrets Manager` `AWS IAM` `VPC Endpoints` `GitHub Actions` `Terraform` `Node.js`

---

## Project Structure

```
secure-docker-app/
├── .github/workflows/
│   └── deploy.yml        # CI/CD Pipeline — build, push, deploy
├── terraform/
│   ├── main.tf           # VPC, Subnets, SGs, ECR, ECS, ALB, IAM
│   ├── variables.tf      # Input variables
│   ├── outputs.tf        # ALB DNS, ECR URL, VPC ID
│   └── providers.tf      # AWS provider + Terraform version
├── Dockerfile            # Multi-stage secure build
├── .dockerignore         # Excludes node_modules, .env, .git
├── package.json          # Node.js dependencies
└── server.js             # Express application
```
