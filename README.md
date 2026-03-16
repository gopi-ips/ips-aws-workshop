# AWS Workshop — Systems Manager & IAM Identity Center

A hands-on workshop covering IAM Identity Center (SSO) local setup and four core AWS Systems Manager services — with full CLI and Console (GUI) walkthroughs for every step.

---

## Modules

| # | Module | Topics Covered |
|---|---|---|
| 0 | [Prerequisites](docs/00-prerequisites.md) | AWS CLI v2, Session Manager Plugin |
| 1 | [IAM Identity Center](docs/01-iam-identity-center.md) | Configure local CLI profiles (dev / stg / prod), login, switch environments |
| 2 | [SSM Parameter Store](docs/02-parameter-store.md) | Create, read, update, delete, version history, path-based retrieval, SecureString |
| 3 | [SSM Run Command](docs/03-run-command.md) | Send commands, target by tag, check output, S3/CloudWatch output |
| 4 | [SSM Session Manager](docs/04-session-manager.md) | Interactive shell, port forwarding, SSH tunnelling, session history |
| 5 | [SSM State Manager](docs/05-state-manager.md) | Associations, schedules, patch management, custom document enforcement |
| 6 | [Cleanup](docs/06-cleanup.md) | Remove all workshop resources |

---

## How to Use This Workshop

1. Start with **[Prerequisites](docs/00-prerequisites.md)** to install required tools.
2. Complete **[IAM Identity Center](docs/01-iam-identity-center.md)** to get your local AWS credentials set up — all subsequent modules depend on this.
3. Work through modules **2 → 5** in order.
4. Run **[Cleanup](docs/06-cleanup.md)** when done to avoid unexpected charges.

---

## Quick Reference

| Task | CLI Command |
|---|---|
| SSO login | `aws sso login --profile workshop` |
| Who am I? | `aws sts get-caller-identity --profile workshop` |
| Create parameter | `aws ssm put-parameter --name /x --value y --type String --profile workshop` |
| Get parameter | `aws ssm get-parameter --name /x --with-decryption --profile workshop` |
| Get all by path | `aws ssm get-parameters-by-path --path /workshop/ --recursive --profile workshop` |
| Run a command | `aws ssm send-command --document-name AWS-RunShellScript --targets ... --profile workshop` |
| Check command output | `aws ssm get-command-invocation --command-id ID --instance-id ID --profile workshop` |
| Start session | `aws ssm start-session --target i-xxxxxxxxx --profile dev` |
| Port forward | `aws ssm start-session --target i-xxx --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["5432"],"localPortNumber":["5432"]}' --profile dev` |
| Create association | `aws ssm create-association --name DOC --targets ... --schedule-expression ... --profile dev` |
| Trigger association now | `aws ssm start-associations-once --association-ids ID --profile dev` |

---

> Workshop content maintained by [IPS AI](https://ips-ai.com). For issues or contributions, open a pull request or file an issue on this repository.
