#!/bin/bash

# Script para configurar acesso SSM ao servidor de build
# Uso: ./setup-ssm-build-server.sh <instance-id>

set -e

INSTANCE_ID=$1
ROLE_NAME="bia-build-server-ssm-role"
INSTANCE_PROFILE_NAME="bia-build-server-ssm-profile"

if [ -z "$INSTANCE_ID" ]; then
    echo "Uso: $0 <instance-id>"
    echo "Exemplo: $0 i-1234567890abcdef0"
    exit 1
fi

echo "🔧 Configurando acesso SSM para instância: $INSTANCE_ID"

# 1. Criar role IAM se não existir
echo "📋 Verificando/criando role IAM..."
if ! aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
    echo "Criando role IAM: $ROLE_NAME"
    
    # Criar trust policy
    cat > /tmp/trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/trust-policy.json

    # Anexar política do SSM
    aws iam attach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    
    echo "✅ Role criada com sucesso"
else
    echo "✅ Role já existe"
fi

# 2. Criar instance profile se não existir
echo "📋 Verificando/criando instance profile..."
if ! aws iam get-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" &> /dev/null; then
    echo "Criando instance profile: $INSTANCE_PROFILE_NAME"
    
    aws iam create-instance-profile \
        --instance-profile-name "$INSTANCE_PROFILE_NAME"
    
    aws iam add-role-to-instance-profile \
        --instance-profile-name "$INSTANCE_PROFILE_NAME" \
        --role-name "$ROLE_NAME"
    
    echo "✅ Instance profile criado com sucesso"
    echo "⏳ Aguardando propagação (30s)..."
    sleep 30
else
    echo "✅ Instance profile já existe"
fi

# 3. Associar instance profile à instância
echo "🔗 Associando instance profile à instância..."
aws ec2 associate-iam-instance-profile \
    --instance-id "$INSTANCE_ID" \
    --iam-instance-profile Name="$INSTANCE_PROFILE_NAME" || {
    echo "⚠️  Instância pode já ter um profile associado. Tentando substituir..."
    
    # Obter associação atual
    ASSOCIATION_ID=$(aws ec2 describe-iam-instance-profile-associations \
        --filters "Name=instance-id,Values=$INSTANCE_ID" \
        --query 'IamInstanceProfileAssociations[0].AssociationId' \
        --output text)
    
    if [ "$ASSOCIATION_ID" != "None" ] && [ "$ASSOCIATION_ID" != "" ]; then
        echo "Removendo associação atual: $ASSOCIATION_ID"
        aws ec2 disassociate-iam-instance-profile \
            --association-id "$ASSOCIATION_ID"
        
        echo "⏳ Aguardando remoção (10s)..."
        sleep 10
        
        echo "Associando novo profile..."
        aws ec2 associate-iam-instance-profile \
            --instance-id "$INSTANCE_ID" \
            --iam-instance-profile Name="$INSTANCE_PROFILE_NAME"
    fi
}

# 4. Instalar SSM Agent se necessário (para instâncias mais antigas)
echo "📦 Verificando SSM Agent na instância..."
echo "Executando comando de teste via SSM..."

# Aguardar um pouco para o SSM Agent se registrar
echo "⏳ Aguardando registro do SSM Agent (60s)..."
sleep 60

# Testar conectividade
if aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["echo SSM funcionando"]' \
    --query 'Command.CommandId' \
    --output text &> /dev/null; then
    echo "✅ SSM configurado com sucesso!"
else
    echo "⚠️  SSM pode precisar de alguns minutos para ficar disponível"
    echo "Tente conectar em alguns minutos com:"
    echo "aws ssm start-session --target $INSTANCE_ID"
fi

echo ""
echo "🎉 Configuração concluída!"
echo ""
echo "Para conectar ao servidor:"
echo "aws ssm start-session --target $INSTANCE_ID"
echo ""
echo "Para editar arquivos, você pode usar:"
echo "sudo yum install -y nano vim git"
echo ""

# Cleanup
rm -f /tmp/trust-policy.json
