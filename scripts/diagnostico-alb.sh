#!/bin/bash
# Diagnóstico do ALB - BIA

echo "=== DIAGNÓSTICO ALB BIA ==="
echo ""

ALB_URL="http://bia-alb-260633202.us-east-1.elb.amazonaws.com"

echo "1. Testando conectividade com ALB..."
curl -I $ALB_URL 2>&1 | head -5
echo ""

echo "2. Testando health check..."
curl -s $ALB_URL/health
echo ""

echo "3. Testando API..."
curl -s $ALB_URL/api/versao
echo ""

echo "4. Verificando Target Groups..."
aws elbv2 describe-target-groups --region us-east-1 --query 'TargetGroups[?contains(LoadBalancerArns[0], `bia-alb`)].{Name:TargetGroupName,Port:Port,Protocol:Protocol,HealthCheck:HealthCheckPath}' --output table

echo ""
echo "5. Verificando Target Health..."
TG_ARN=$(aws elbv2 describe-target-groups --region us-east-1 --query 'TargetGroups[?contains(LoadBalancerArns[0], `bia-alb`)].TargetGroupArn' --output text)
aws elbv2 describe-target-health --target-group-arn $TG_ARN --region us-east-1 --output table

echo ""
echo "6. Verificando Listeners..."
aws elbv2 describe-listeners --region us-east-1 --query 'Listeners[?contains(LoadBalancerArn, `bia-alb`)].{Port:Port,Protocol:Protocol,DefaultActions:DefaultActions[0].Type}' --output table

echo ""
echo "7. Verificando Security Groups do ALB..."
aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[?contains(LoadBalancerArn, `bia-alb`)].SecurityGroups[]' --output text

echo ""
echo "=== CHECKLIST DE PROBLEMAS COMUNS ==="
echo ""
echo "□ Target Group está healthy?"
echo "□ Security Group do ALB permite porta 80?"
echo "□ Security Group do container permite tráfego do ALB?"
echo "□ Container está rodando na porta correta (8080)?"
echo "□ Health check path está correto (/health)?"
echo "□ ECS Service tem tasks rodando?"
