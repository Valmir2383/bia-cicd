#!/bin/bash

# Script para reconfigurar CodeBuild com GitHub source

PROJECT_NAME="bia-cicd-build"
GITHUB_REPO="https://github.com/valmir2383/bia-cicd.git"
BRANCH="pr-cicd"

echo "Reconfigurando projeto CodeBuild..."

# Deletar projeto existente (se houver problemas)
# aws codebuild delete-project --name $PROJECT_NAME

# Criar novo projeto com GitHub source
aws codebuild create-project \
  --name $PROJECT_NAME \
  --source '{
    "type": "GITHUB",
    "location": "'$GITHUB_REPO'",
    "buildspec": "buildspec.yml",
    "gitCloneDepth": 1,
    "reportBuildStatus": true
  }' \
  --artifacts '{
    "type": "NO_ARTIFACTS"
  }' \
  --environment '{
    "type": "LINUX_CONTAINER",
    "image": "aws/codebuild/amazonlinux2-x86_64-standard:5.0",
    "computeType": "BUILD_GENERAL1_MEDIUM",
    "privilegedMode": true
  }' \
  --service-role "arn:aws:iam::804826263064:role/service-role/codebuild-bia-service-role"

echo "Projeto criado! Configurando webhook..."

# Configurar webhook para builds automáticos
aws codebuild create-webhook \
  --project-name $PROJECT_NAME \
  --filter-groups '[
    [
      {
        "type": "EVENT",
        "pattern": "PUSH"
      },
      {
        "type": "HEAD_REF",
        "pattern": "refs/heads/'$BRANCH'"
      }
    ]
  ]'

echo "Configuração concluída!"
