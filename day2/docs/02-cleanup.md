# Cleanup — Remove All Day 2 Resources

Run these commands in order to tear down everything created during the Day 2 workshop.

---

## Variables

```bash
ACCOUNT_ID="904233105347"
REGION="ca-central-1"
```

---

## Step 1 — ECS Service & Cluster

```bash
aws ecs update-service \
  --cluster ips-dev-workshop-ecs-cluster \
  --service ips-dev-workshop-ecs-service \
  --desired-count 0 \
  --region $REGION

aws ecs delete-service \
  --cluster ips-dev-workshop-ecs-cluster \
  --service ips-dev-workshop-ecs-service \
  --region $REGION

aws ecs delete-cluster \
  --cluster ips-dev-workshop-ecs-cluster \
  --region $REGION
```

---

## Step 2 — Task Definitions

```bash
for arn in $(aws ecs list-task-definitions \
  --family-prefix ips-dev-workshop-task-defn \
  --query "taskDefinitionArns[]" --output text --region $REGION); do
  aws ecs deregister-task-definition --task-definition $arn --region $REGION
done
```

---

## Step 3 — ECR Repository

```bash
aws ecr delete-repository \
  --repository-name ips-workshop-ecr \
  --force \
  --region $REGION
```

---

## Step 4 — CloudWatch Log Group

```bash
aws logs delete-log-group \
  --log-group-name /ecs/myapp \
  --region $REGION
```

---

## Step 5 — IAM Roles

```bash
aws iam delete-role-policy \
  --role-name ips-dev-workshop-task-role \
  --policy-name s3-access

aws iam delete-role \
  --role-name ips-dev-workshop-task-role

aws iam detach-role-policy \
  --role-name ips-dev-workshop-task-exec-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

aws iam delete-role \
  --role-name ips-dev-workshop-task-exec-role
```
