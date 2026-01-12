#!/bin/bash

# Recriar pipeline com GitHub source
PIPELINE_NAME="bia-hom"
GITHUB_REPO="Valmir2383/bia-cicd"
BRANCH="pr-cicd"

echo "Recriando pipeline $PIPELINE_NAME com GitHub source..."

# Backup do pipeline atual
aws codepipeline get-pipeline --name $PIPELINE_NAME > pipeline-backup.json 2>/dev/null

# Deletar pipeline atual (cuidado!)
# aws codepipeline delete-pipeline --name $PIPELINE_NAME

echo "Para recriar o pipeline, execute os comandos no console AWS:"
echo "1. CodePipeline > $PIPELINE_NAME > Edit"
echo "2. Source stage > Edit stage > Edit action"
echo "3. Mudar para GitHub: $GITHUB_REPO, branch: $BRANCH"
