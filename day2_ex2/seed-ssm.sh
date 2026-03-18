#!/bin/bash
# Run once to seed SSM parameters for each environment

REGION="ca-central-1"

for ENV in prod stg dev; do
  aws ssm put-parameter \
    --name "/myapp/${ENV}/index_html" \
    --value "<!DOCTYPE html><html><head><title>${ENV}</title></head><body><h1>Hello from ${ENV} environment!</h1></body></html>" \
    --type "SecureString" \
    --region "$REGION" \
    --overwrite \
    --profile sandbox
  echo "Created SSM param for $ENV"
done
