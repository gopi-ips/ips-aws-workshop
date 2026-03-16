# Module 1 — IAM Identity Center (Connect from Local Machine)

[← Prerequisites](00-prerequisites.md) | [Back to Workshop Home](../README.md) | [Next: Parameter Store →](02-parameter-store.md)

---

> **Before you start:** Your AWS admin must have already enabled IAM Identity Center, created your user, and assigned you to the dev / stg / prod accounts. You will configure all three profiles below.

---

## Step 1 — Configure the SSO Profile for Each Environment

Run this once per environment. Each run creates one named profile.

### dev

```bash
aws configure sso
```

```
SSO session name (Recommended): workshop-session
SSO start URL [None]: https://d-9d677c6f3a.awsapps.com/start
SSO region [None]: ca-central-1
SSO registration scopes [sso:account:access]: sso:account:access
```

Browser opens — sign in and approve the request. Back in the terminal:

```
CLI default client Region [None]: ca-central-1
CLI default output format [None]: json
CLI profile name [...]: dev
```

---

### stg

```bash
aws configure sso
```

```
SSO session name (Recommended): workshop-session
SSO start URL [None]: https://d-9d677c6f3a.awsapps.com/start
SSO region [None]: ca-central-1
SSO registration scopes [sso:account:access]: sso:account:access
```

```
CLI default client Region [None]: ca-central-1
CLI default output format [None]: json
CLI profile name [...]: stg
```

---

### prod

```bash
aws configure sso
```

```
SSO session name (Recommended): workshop-session
SSO start URL [None]: https://d-9d677c6f3a.awsapps.com/start
SSO region [None]: ca-central-1
SSO registration scopes [sso:account:access]: sso:account:access
```

```
CLI default client Region [None]: ca-central-1
CLI default output format [None]: json
CLI profile name [...]: prod
```

---

After all three, `~/.aws/config` will contain:

```ini
[sso-session workshop-session]
sso_start_url = https://d-9d677c6f3a.awsapps.com/start
sso_region = ca-central-1
sso_registration_scopes = sso:account:access

[profile dev]
sso_session = workshop-session
sso_account_id = <dev-account-id>
sso_role_name = <your-role>
region = ca-central-1
output = json

[profile stg]
sso_session = workshop-session
sso_account_id = <stg-account-id>
sso_role_name = <your-role>
region = ca-central-1
output = json

[profile prod]
sso_session = workshop-session
sso_account_id = <prod-account-id>
sso_role_name = <your-role>
region = ca-central-1
output = json
```

---

## Step 2 — Log In

One login command authenticates all profiles that share the same SSO session:

```bash
aws sso login --profile dev
```

Terminal confirms:

```
Successfully logged into Start URL: https://d-9d677c6f3a.awsapps.com/start
```

---

## Step 3 — Verify Each Profile

```bash
aws sts get-caller-identity --profile dev
aws sts get-caller-identity --profile stg
aws sts get-caller-identity --profile prod
```

---

## Step 4 — Switch Between Environments

```bash
# Inline — per command
aws s3 ls --profile dev
aws s3 ls --profile stg
aws s3 ls --profile prod

# Or export for the entire terminal session
export AWS_PROFILE=dev     # switch to dev
export AWS_PROFILE=stg     # switch to stg
export AWS_PROFILE=prod    # switch to prod
```

---

## Step 5 — Refresh When Token Expires

```bash
aws sso login --profile dev
```

This refreshes credentials for all three profiles (dev / stg / prod) at once.

---

## Step 6 — Log Out

```bash
aws sso logout --profile dev
```

---

[← Prerequisites](00-prerequisites.md) | [Back to Workshop Home](../README.md) | [Next: Parameter Store →](02-parameter-store.md)
