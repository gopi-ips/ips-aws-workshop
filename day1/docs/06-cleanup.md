# Module 6 — Cleanup

[← State Manager](05-state-manager.md) | [Back to Workshop Home](../README.md)

---

Run these steps after finishing the workshop to remove all resources and avoid unexpected charges.

> Work through each section in order — some resources depend on others being removed first.

---

## 1. Delete State Manager Associations

```bash
aws ssm delete-association \
  --association-name "workshop-keep-ssm-agent-updated" \
  --profile workshop

aws ssm delete-association \
  --association-name "workshop-install-cloudwatch-agent" \
  --profile workshop

aws ssm delete-association \
  --association-name "workshop-monthly-patching" \
  --profile workshop

aws ssm delete-association \
  --association-name "workshop-enforce-motd" \
  --profile workshop
```

Verify none remain:

```bash
aws ssm list-associations \
  --association-filter-list "key=AssociationName,value=workshop" \
  --profile workshop
```

---

## 2. Delete Custom SSM Documents

```bash
aws ssm delete-document \
  --name "Workshop-InstallNginx" \
  --profile workshop

aws ssm delete-document \
  --name "Workshop-EnforceMotd" \
  --profile workshop
```

---

## 3. Delete SSM Parameters

```bash
aws ssm delete-parameters \
  --names \
    "/workshop/app/db-host" \
    "/workshop/app/db-password" \
    "/workshop/app/api-key" \
    "/workshop/app/allowed-ips" \
  --profile workshop
```

Verify no parameters remain under `/workshop/`:

```bash
aws ssm describe-parameters \
  --parameter-filters "Key=Path,Option=Recursive,Values=/workshop" \
  --query "Parameters[*].Name" \
  --output table \
  --profile workshop
```

---

## 4. Remove IAM Instance Profile and Role

```bash
# Step 1 — Detach the role from the instance profile
aws iam remove-role-from-instance-profile \
  --instance-profile-name WorkshopEC2Profile \
  --role-name WorkshopEC2Role \
  --profile workshop

# Step 2 — Delete the instance profile
aws iam delete-instance-profile \
  --instance-profile-name WorkshopEC2Profile \
  --profile workshop

# Step 3 — Detach the managed policy from the role
aws iam detach-role-policy \
  --role-name WorkshopEC2Role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore \
  --profile workshop

# Step 4 — Delete the role
aws iam delete-role \
  --role-name WorkshopEC2Role \
  --profile workshop
```

---

## 5. (Optional) Remove IAM Identity Center Resources

If you created workshop-specific users or permission sets that are no longer needed:

### Remove Account Assignment (GUI)

1. Open **IAM Identity Center > AWS accounts**.
2. Select the account, click **Remove access** for the workshop user.

### Remove Account Assignment (CLI)

```bash
aws sso-admin delete-account-assignment \
  --instance-arn "arn:aws:sso:::instance/ssoins-xxxxxxxxxx" \
  --target-id "123456789012" \
  --target-type "AWS_ACCOUNT" \
  --permission-set-arn "arn:aws:sso:::permissionSet/ssoins-xxxxxxxxxx/ps-xxxxxxxxxx" \
  --principal-type "USER" \
  --principal-id "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
  --profile workshop
```

### Delete Permission Set (GUI)

1. Go to **Permission sets**, select `WorkshopAdmin`.
2. Click **Delete**, confirm.

### Delete User (GUI)

1. Go to **Users**, select the workshop user.
2. Click **Delete user**, confirm.

---

## 6. Log Out of SSO

```bash
aws sso logout --profile workshop
```

---

## Cleanup Checklist

- [ ] All State Manager associations deleted
- [ ] Custom SSM documents deleted
- [ ] All `/workshop/*` parameters deleted
- [ ] `WorkshopEC2Profile` instance profile deleted
- [ ] `WorkshopEC2Role` IAM role deleted
- [ ] IAM Identity Center account assignments removed (if applicable)
- [ ] Workshop users removed from Identity Center (if applicable)
- [ ] SSO session logged out

---

[← State Manager](04-state-manager.md) | [Back to Workshop Home](../README.md)
