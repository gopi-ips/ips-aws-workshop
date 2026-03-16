# Module 4 — AWS SSM Session Manager

[← Run Command](03-run-command.md) | [Back to Workshop Home](../README.md) | [Next: State Manager →](05-state-manager.md)

---

Session Manager gives you an interactive shell on any managed EC2 instance directly from your browser or terminal — no SSH keys, no bastion hosts, no open inbound ports.

## How It Works

```
Your Terminal / Browser
        |
        v
   AWS Systems Manager API
        |
        v
   SSM Agent on EC2 (outbound HTTPS port 443 only)
        |
        v
   Interactive shell session on the instance
        |
        v
   Session logs  →  CloudWatch Logs  |  S3
```

---

## Prerequisites

Same as Run Command — the instance needs:
- SSM Agent running (`sudo systemctl status amazon-ssm-agent`)
- IAM instance profile with `AmazonSSMManagedInstanceCore`
- Session Manager Plugin installed on your **local machine** (see [Prerequisites](00-prerequisites.md))

---

## Console (GUI) Steps

### Start a Session

1. Open **Systems Manager → Session Manager**.
2. Click **Start session**.
3. Select your instance from the list.
4. Click **Start session** — a browser-based shell opens in a new tab.
5. You are connected as `ssm-user` with `sudo` access.
6. To end the session, type `exit` or click **Terminate** in the console.

---

### View Session History

1. In **Session Manager**, click the **Session history** tab.
2. Each row shows the session ID, target instance, start/end time, and the user who initiated it.
3. If logging is enabled, click the session ID to view the full session log in S3 or CloudWatch.

---

### Enable Session Logging (GUI)

1. In **Session Manager**, click **Preferences → Edit**.
2. Under **CloudWatch logging**, enable it and enter a log group name, e.g., `/ssm/sessions`.
3. Under **S3 logging** *(optional)*, enter your bucket name and key prefix.
4. Click **Save**.

---

## CLI Steps

### Start an Interactive Session

```bash
aws ssm start-session \
  --target i-0abcd1234efgh5678 \
  --profile dev
```

A shell opens directly in your terminal. Type `exit` to end it.

---

### Start a Session on an Instance by Tag

You cannot target by tag directly with `start-session` — first get the instance ID:

```bash
# Get instance ID by tag
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=dev" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text \
  --profile dev)

# Start the session
aws ssm start-session \
  --target "$INSTANCE_ID" \
  --profile dev
```

---

### Port Forwarding — Access a Remote Port Locally

Forward a port on the remote instance to a port on your local machine. Useful for accessing databases, internal web apps, or any service not exposed publicly.

```bash
# Forward remote port 5432 (Postgres) to local port 5432
aws ssm start-session \
  --target i-0abcd1234efgh5678 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["5432"],"localPortNumber":["5432"]}' \
  --profile dev
```

While the session runs, connect locally:

```bash
psql -h localhost -p 5432 -U myuser -d mydb
```

---

### Port Forwarding to a Private RDS / Internal Host

Forward traffic through the EC2 instance to a private endpoint (e.g., RDS in a private subnet):

```bash
aws ssm start-session \
  --target i-0abcd1234efgh5678 \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters '{
    "host":["mydb.cluster.ca-central-1.rds.amazonaws.com"],
    "portNumber":["5432"],
    "localPortNumber":["5432"]
  }' \
  --profile dev
```

---

### SSH over Session Manager (no open port 22)

Add the following to `~/.ssh/config` on your local machine:

```
Host i-* mi-*
  ProxyCommand aws ssm start-session \
    --target %h \
    --document-name AWS-StartSSHSession \
    --parameters portNumber=%p \
    --profile dev
```

Then SSH normally — Session Manager handles the tunnel:

```bash
ssh -i ~/.ssh/my-key.pem ubuntu@i-0abcd1234efgh5678
```

---

### List Active Sessions

```bash
aws ssm describe-sessions \
  --state Active \
  --profile dev
```

---

### List Session History

```bash
aws ssm describe-sessions \
  --state History \
  --profile dev
```

---

### Terminate a Session

```bash
SESSION_ID="session-0abc1234def56789"

aws ssm terminate-session \
  --session-id "$SESSION_ID" \
  --profile dev
```

---

[← Run Command](03-run-command.md) | [Back to Workshop Home](../README.md) | [Next: State Manager →](05-state-manager.md)
