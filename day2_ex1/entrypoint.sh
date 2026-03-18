#!/bin/bash
set -e

# ENV must be set to: prod | stg | dev
ENV=${ENV:-dev}

echo "Fetching index.html for environment: $ENV"
aws s3 cp "s3://ips-aws-workshop-2026/${ENV}/index.html" /var/www/html/index.html

echo "Starting Apache..."
exec httpd -D FOREGROUND
