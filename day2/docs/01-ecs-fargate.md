# ECS Fargate — Deploy a Containerised App

This module walks through deploying a Docker container to AWS ECS Fargate using ECR, IAM roles, CloudWatch Logs, and a Fargate service.

---

## Variables

```bash
ACCOUNT_ID="904233105347"
REGION="ca-central-1"
SUBNET_ID="subnet-0aa220e91724231d2"
```

---

## Step 1 — IAM Roles

### Task Role (runtime permissions)

```bash
aws iam create-role \
  --role-name ips-dev-workshop-task-role \
  --assume-role-policy-document '{
    "Version":"2012-10-17",
    "Statement":[{"Effect":"Allow","Principal":{"Service":"ecs-tasks.amazonaws.com"},"Action":"sts:AssumeRole"}]
  }'

aws iam put-role-policy \
  --role-name ips-dev-workshop-task-role \
  --policy-name s3-access \
  --policy-document '{
    "Version":"2012-10-17",
    "Statement":[{"Effect":"Allow","Action":["s3:GetObject","s3:ListBucket"],"Resource":["arn:aws:s3:::ips-aws-workshop-2026","arn:aws:s3:::ips-aws-workshop-2026/*"]}]
  }'
```

### Task Execution Role (ECS agent permissions)

```bash
aws iam create-role \
  --role-name ips-dev-workshop-task-exec-role \
  --assume-role-policy-document '{
    "Version":"2012-10-17",
    "Statement":[{"Effect":"Allow","Principal":{"Service":"ecs-tasks.amazonaws.com"},"Action":"sts:AssumeRole"}]
  }'

aws iam attach-role-policy \
  --role-name ips-dev-workshop-task-exec-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

---

## Step 2 — ECR Repository, Build & Push Image

```bash
# Create the repository
aws ecr create-repository \
  --repository-name ips-workshop-ecr \
  --region $REGION

# Authenticate Docker to ECR
aws ecr get-login-password --region ca-central-1 | docker login --username AWS --password-stdin 904233105347.dkr.ecr.ca-central-1.amazonaws.com

# Build the image
docker build -t ips-workshop-ecr .

# Tag and push
docker tag ips-workshop-ecr:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/ips-workshop-ecr:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/ips-workshop-ecr:latest
```

---

## Step 3 — CloudWatch Log Group

```bash
aws logs create-log-group \
  --log-group-name /ecs/myapp \
  --region ca-central-1
```

---

## Step 4 — ECS Cluster

```bash
aws ecs create-cluster \
  --cluster-name ips-dev-workshop-ecs-cluster \
  --region ca-central-1
```

---

## Step 5 — Task Definition

```bash
aws ecs register-task-definition \
  --family ips-dev-workshop-task-defn \
  --network-mode awsvpc \
  --requires-compatibilities FARGATE \
  --cpu 256 \
  --memory 512 \
  --task-role-arn arn:aws:iam::904233105347:role/ips-dev-workshop-task-role \
  --execution-role-arn arn:aws:iam::904233105347:role/ips-dev-workshop-task-exec-role \
  --container-definitions '[
    {
      "name": "myapp",
      "image": "904233105347.dkr.ecr.ca-central-1.amazonaws.com/ips-workshop-ecr:latest",
      "essential": true,
      "environment": [
        {"name":"ENV","value":"dev"},
        {"name":"AWS_REGION","value":"ca-central-1"}
      ],
      "portMappings": [{"containerPort":80,"protocol":"tcp"}],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/myapp",
          "awslogs-region": "ca-central-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]' \
  --region ca-central-1
```

---

## Step 6 — ECS Service

```bash
aws ecs create-service \
  --cluster ips-dev-workshop-ecs-cluster \
  --service-name ips-dev-workshop-ecs-service \
  --task-definition ips-dev-workshop-task-defn \
  --launch-type FARGATE \
  --desired-count 1 \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-0aa220e91724231d2],assignPublicIp=ENABLED}" \
  --region ca-central-1
```

---

## AWS Documentation

| Resource | Link |
|---|---|
| ECS Fargate | [Getting started with Amazon ECS using Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/getting-started-fargate.html) |
| ECR | [Amazon Elastic Container Registry](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) |
| Task Definitions | [Amazon ECS task definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) |
| ECS IAM Roles | [Amazon ECS task IAM role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html) |
| CloudWatch Logs | [Using the awslogs log driver](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html) |
