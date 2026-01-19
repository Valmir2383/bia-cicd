bash
#!/bin/bash

set -e

AWS_PROFILE="valmir"
AWS_REGION="us-east-1"
NOME="ec2-porteiro-rds-zona-b"

echo "Criando EC2 Porteiro na Zona B..."

# Buscar subnet zona B
SUBNET_ID=$(aws ec2 describe-subnets \
    --filters "Name=availability-zone,Values=${AWS_REGION}b" "Name=default-for-az,Values=true" \
    --query 'Subnets[0].SubnetId' \
    --output text \
    --profile $AWS_PROFILE \
    --region $AWS_REGION)

if [ -z "$SUBNET_ID" ]; then
    echo "Erro: Subnet zona B não encontrada"
    exit 1
fi

# Buscar security group bia-dev
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=bia-dev" \
    --query 'SecurityGroups[0].GroupId' \
    --output text \
    --profile $AWS_PROFILE \
    --region $AWS_REGION)

if [ -z "$SG_ID" ] || [ "$SG_ID" = "None" ]; then
    echo "Erro: Security Group bia-dev não encontrado"
    exit 1
fi

# User data para instalar Docker
USER_DATA='#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user'

# Lançar instância
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0453ec754f44f9a4a \
    --instance-type t3.micro \
    --subnet-id $SUBNET_ID \
    --security-group-ids $SG_ID \
    --iam-instance-profile Name=role-acesso-ssm \
    --user-data "$USER_DATA" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NOME}]" \
    --query 'Instances[0].InstanceId' \
    --output text \
    --profile $AWS_PROFILE \
    --region $AWS_REGION)

echo "Instância criada: $INSTANCE_ID"
echo "Aguardando inicialização..."

aws ec2 wait instance-running \
    --instance-ids $INSTANCE_ID \
    --profile $AWS_PROFILE \
    --region $AWS_REGION

PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text \
    --profile $AWS_PROFILE \
    --region $AWS_REGION)

echo ""
echo "✓ Instância criada com sucesso!"
echo "Instance ID: $INSTANCE_ID"
echo "IP Público: $PUBLIC_IP"
echo "Zona: ${AWS_REGION}b"
echo ""
echo "Aguarde 2 minutos para SSM agent ficar online"


Para usar:
bash
chmod +x 07-criar-porteiro-zona-b.sh
./07-criar-porteiro-zona-b.sh