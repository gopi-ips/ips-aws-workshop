# AWS Workshop — Systems Manager & IAM Identity Center

A hands-on workshop covering IAM Identity Center (SSO) local setup and four core AWS Systems Manager services — with full CLI and Console (GUI) walkthroughs for every step.

---

## Slide Deck

> Open the workshop presentation in your browser:
>
> **[▶ View Workshop Slides](https://htmlpreview.github.io/?https://github.com/gopi-ips/ips-aws-workshop/blob/main/workshop1.html)**

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

---

> Workshop content maintained by [IPS AI](https://ips-ai.com). For issues or contributions, open a pull request or file an issue on this repository.
