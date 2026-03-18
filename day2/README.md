# AWS Workshop — Day 2 | by IPS
## ECS Fargate & Containerised Workloads

A hands-on workshop covering deploying Docker containers to AWS ECS Fargate using ECR, IAM roles, CloudWatch Logs, and Fargate services — with full CLI walkthroughs for every step.

---

## Modules

| # | Module | Topics Covered |
|---|---|---|
| 1 | [ECS Fargate](docs/01-ecs-fargate.md) | IAM roles, ECR, CloudWatch Logs, ECS cluster, task definition, Fargate service |
| 2 | [Cleanup](docs/02-cleanup.md) | Remove all Day 2 workshop resources |

---

## How to Use This Workshop

1. Set your variables (`ACCOUNT_ID`, `REGION`, `SUBNET_ID`) at the top of each module.
2. Work through the steps in order — each step depends on the previous one.
3. Run **[Cleanup](docs/02-cleanup.md)** when done to avoid unexpected charges.

---

## Supporting Files

| Folder | Description |
|---|---|
| [day2_ex1/](day2_ex1/) | Exercise 1 — Dockerfile & entrypoint |
| [day2_ex2/](day2_ex2/) | Exercise 2 — Dockerfile, entrypoint & SSM seed script |
