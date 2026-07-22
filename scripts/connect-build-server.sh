#!/bin/bash

# Script para conectar ao servidor de build via SSM
# Uso: ./connect-build-server.sh <instance-id>

INSTANCE_ID=$1

if [ -z "$INSTANCE_ID" ]; then
    echo "Uso: $0 <instance-id>"
    echo ""
    echo "Para encontrar o ID da instância do seu servidor de build:"
    echo "aws ec2 describe-instances --filters 'Name=tag:Name,Values=*build*' --query 'Reservations[].Instances[].{ID:InstanceId,Name:Tags[?Key==\`Name\`].Value|[0],State:State.Name}' --output table"
    exit 1
fi

echo "🔗 Conectando ao servidor de build: $INSTANCE_ID"
echo "💡 Dica: Use 'sudo su -' para virar root se necessário"
echo ""

aws ssm start-session --target "$INSTANCE_ID"
