#!/bin/bash
set -euo pipefail

# Install Docker from the official Debian repo
apt-get update -y
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install AWS CLI v2
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/awscliv2.zip /tmp/aws

# Install SSM Agent (enables aws ssm start-session without opening port 22)
curl -fsSL "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb" \
  -o /tmp/ssm.deb
dpkg -i /tmp/ssm.deb
rm /tmp/ssm.deb
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Create app directory
mkdir -p /opt/app

# Write postgres init schema and nginx config (base64-encoded at Terraform render time)
echo "${init_sql_b64}" | base64 -d > /opt/app/init.sql
echo "${nginx_conf_b64}" | base64 -d > /opt/app/nginx.prod.conf

# Fetch application secrets from SSM Parameter Store
REGION="${region}"
get_param() {
  /usr/local/bin/aws ssm get-parameter --region "$REGION" --name "$1" --with-decryption \
    --query Parameter.Value --output text
}

POSTGRES_USER=$(get_param "${ssm_prefix}/POSTGRES_USER")
POSTGRES_PASSWORD=$(get_param "${ssm_prefix}/POSTGRES_PASSWORD")
POSTGRES_DB=$(get_param "${ssm_prefix}/POSTGRES_DB")
BACKEND_PORT=$(get_param "${ssm_prefix}/BACKEND_PORT")
CORS_ORIGIN=$(get_param "${ssm_prefix}/CORS_ORIGIN")
VITE_FRONTEND_PORT=$(get_param "${ssm_prefix}/VITE_FRONTEND_PORT")
HTTP_PORT=$(get_param "${ssm_prefix}/HTTP_PORT")
VITE_FRONTEND_API_URL=$(get_param "${ssm_prefix}/VITE_FRONTEND_API_URL")

# Write .env consumed by docker compose
cat > /opt/app/.env <<EOF
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB
BACKEND_PORT=$BACKEND_PORT
CORS_ORIGIN=$CORS_ORIGIN
VITE_FRONTEND_PORT=$VITE_FRONTEND_PORT
HTTP_PORT=$HTTP_PORT
VITE_FRONTEND_API_URL=$VITE_FRONTEND_API_URL
ECR_REPOSITORY_URI=${ecr_repository_uri}
IMAGE_ENV=${environment}
EOF

# Write compose file (base64-encoded at Terraform render time)
echo "${compose_b64}" | base64 -d > /opt/app/docker-compose.ecr.yaml

# Authenticate to ECR and start services
/usr/local/bin/aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "${ecr_registry}"

cd /opt/app
docker compose -f docker-compose.ecr.yaml up -d
