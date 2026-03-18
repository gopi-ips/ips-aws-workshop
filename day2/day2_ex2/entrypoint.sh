#!/bin/bash
set -e

# ENV must be: prod | stg | dev
ENV=${ENV:-prod}
REGION=${AWS_REGION:-ca-central-1}

echo "Fetching HTML content from SSM for environment: $ENV"

aws ssm get-parameter \
  --name "/myapp/${ENV}/index_html" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region "$REGION" > /var/www/html/index.html

echo "Starting Apache..."
exec httpd -D FOREGROUND
