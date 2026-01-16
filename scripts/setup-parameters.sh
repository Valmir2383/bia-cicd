#!/bin/bash

# Script para configurar parâmetros no AWS Parameter Store
# Uso: ./scripts/setup-parameters.sh

set -e

AWS_REGION=${AWS_REGION:-us-east-1}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Configurando parâmetros no Parameter Store..."
echo "Região: $AWS_REGION"
echo "Conta: $AWS_ACCOUNT_ID"
echo ""

# Solicitar valores
read -p "ARN do Secret do RDS: " SECRET_ARN
read -p "Hostname do banco de dados: " DB_HOST
read -p "Nome do repositório ECR [bia]: " ECR_REPO
ECR_REPO=${ECR_REPO:-bia}

# Criar parâmetros
echo "Criando parâmetros..."

aws ssm put-parameter \
  --name /bia/secrets/rds-secret-arn \
  --value "$SECRET_ARN" \
  --type String \
  --overwrite \
  --region $AWS_REGION

aws ssm put-parameter \
  --name /bia/db/host \
  --value "$DB_HOST" \
  --type String \
  --overwrite \
  --region $AWS_REGION

aws ssm put-parameter \
  --name /bia/ecr/repository-name \
  --value "$ECR_REPO" \
  --type String \
  --overwrite \
  --region $AWS_REGION

echo ""
echo "✅ Parâmetros configurados com sucesso!"
echo ""
echo "Parâmetros criados:"
echo "  - /bia/secrets/rds-secret-arn"
echo "  - /bia/db/host"
echo "  - /bia/ecr/repository-name"
