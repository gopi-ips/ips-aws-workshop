# AWS Workshop | by IPS

---

## Day 1 — IAM Identity Center & AWS Systems Manager

A hands-on workshop covering IAM Identity Center (SSO) local setup and four core AWS Systems Manager services — with full CLI and Console (GUI) walkthroughs for every step.

### Slide Deck

> **[▶ View Workshop Slides](https://gopi-ips.github.io/ips-aws-workshop/workshop1.html)**

### Modules

| # | Module | Topics Covered |
|---|---|---|
| 0 | [Prerequisites](day1/docs/00-prerequisites.md) | AWS CLI v2, Session Manager Plugin |
| 1 | [IAM Identity Center](day1/docs/01-iam-identity-center.md) | Configure local CLI profiles (dev / stg / prod), login, switch environments |
| 2 | [SSM Parameter Store](day1/docs/02-parameter-store.md) | Create, read, update, delete, version history, path-based retrieval, SecureString |
| 3 | [SSM Run Command](day1/docs/03-run-command.md) | Send commands, target by tag, check output, S3/CloudWatch output |
| 4 | [SSM Session Manager](day1/docs/04-session-manager.md) | Interactive shell, port forwarding, SSH tunnelling, session history |
| 5 | [SSM State Manager](day1/docs/05-state-manager.md) | Associations, schedules, patch management, custom document enforcement |
| 6 | [Cleanup](day1/docs/06-cleanup.md) | Remove all Day 1 workshop resources |

---

## Day 2 — ECS Fargate & Containerised Workloads

> 📁 See **[day2/README.md](day2/README.md)** for the full Day 2 workshop.

| # | Module | Topics Covered |
|---|---|---|
| 1 | [ECS Fargate](day2/docs/01-ecs-fargate.md) | IAM roles, ECR, CloudWatch Logs, ECS cluster, task definition, Fargate service |
| 2 | [Cleanup](day2/docs/02-cleanup.md) | Remove all Day 2 workshop resources |

---

## AWS Documentation

| Service | Reference |
|---|---|
| IAM Identity Center | [What is IAM Identity Center?](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html) |
| IAM Identity Center — CLI SSO | [Configuring the AWS CLI to use IAM Identity Center](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) |
| SSM Overview | [What is AWS Systems Manager?](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html) |
| SSM Parameter Store | [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) |
| SSM Run Command | [AWS Systems Manager Run Command](https://docs.aws.amazon.com/systems-manager/latest/userguide/execute-remote-commands.html) |
| SSM Session Manager | [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) |
| SSM State Manager | [AWS Systems Manager State Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state.html) |
| SSM Agent — Ubuntu | [Install SSM Agent on Ubuntu Server](https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu-64-snap.html) |
| Session Manager Plugin | [Install the Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) |
| SSM Managed Policy | [AmazonSSMManagedInstanceCore](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonSSMManagedInstanceCore.html) |
| ECS Fargate | [Getting started with Amazon ECS using Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/getting-started-fargate.html) |
| ECR | [Amazon Elastic Container Registry](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) |
| ECS Task Definitions | [Amazon ECS task definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html) |
| ECS IAM Roles | [Amazon ECS task IAM role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html) |
