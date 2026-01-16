# Guia de Deploy - BIA CI/CD

## Pré-requisitos

- AWS CLI configurado
- Acesso ao AWS Console
- Repositório Git configurado
- CodeBuild project criado
- RDS PostgreSQL provisionado
- ECR repository criado

## Passo 1: Configurar Parameter Store

Execute o script interativo:

```bash
./scripts/setup-parameters.sh
```

Ou configure manualmente:

```bash
# Região AWS
export AWS_REGION=us-east-1

# ARN do Secret do RDS
aws ssm put-parameter \
  --name /bia/secrets/rds-secret-arn \
  --value "arn:aws:secretsmanager:us-east-1:ACCOUNT_ID:secret:SECRET_NAME" \
  --type String \
  --region $AWS_REGION

# Hostname do banco de dados
aws ssm put-parameter \
  --name /bia/db/host \
  --value "bia-db.xxx.rds.amazonaws.com" \
  --type String \
  --region $AWS_REGION

# Nome do repositório ECR
aws ssm put-parameter \
  --name /bia/ecr/repository-name \
  --value "bia" \
  --type String \
  --region $AWS_REGION
```

## Passo 2: Configurar IAM Role do CodeBuild

Adicione as seguintes permissões à role do CodeBuild:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:us-east-1:ACCOUNT_ID:parameter/bia/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:ACCOUNT_ID:secret:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }
  ]
}
```

## Passo 3: Validar Localmente

Antes de fazer commit, valide as mudanças:

```bash
# Instalar dependências
npm install

# Executar testes
npm test
npm run test:integration

# Verificar lint
npm run lint

# Testar conexão com banco (configure .env primeiro)
npm run db:test

# Executar migrações
npm run db:migrate

# Iniciar aplicação
npm start

# Em outro terminal, testar health check
curl http://localhost:8080/health
```

## Passo 4: Commit e Push

```bash
# Adicionar arquivos
git add .

# Commit com mensagem descritiva
git commit -m "feat: implementar melhorias de segurança e qualidade

- Adicionar validação de input
- Implementar tratamento de erros centralizado
- Adicionar logging estruturado
- Criar health check endpoint
- Parametrizar buildspec.yml
- Otimizar Dockerfile com multi-stage build
- Configurar ESLint
- Documentar variáveis de ambiente"

# Push para o repositório
git push origin main
```

## Passo 5: Monitorar Pipeline

1. Acesse o AWS CodeBuild Console
2. Localize seu projeto
3. Acompanhe o build em tempo real
4. Verifique cada fase:
   - Install: Instalação de dependências
   - Pre_build: Testes e validações
   - Build: Criação da imagem Docker
   - Post_build: Push para ECR

## Passo 6: Validar Deploy

Após o deploy bem-sucedido:

```bash
# Obter endpoint da aplicação
ENDPOINT="seu-endpoint-aqui"

# Testar health check
curl $ENDPOINT/health

# Deve retornar algo como:
# {
#   "status": "healthy",
#   "timestamp": "2026-01-16T20:20:00.000Z",
#   "uptime": 123.45,
#   "database": "connected"
# }

# Testar API de tarefas
curl $ENDPOINT/api/tarefas

# Testar versão
curl $ENDPOINT/api/versao
```

## Passo 7: Configurar Monitoramento

### CloudWatch Logs

Os logs estruturados estarão disponíveis no CloudWatch Logs. Configure filtros:

```bash
# Filtrar erros
{ $.level = "error" }

# Filtrar por operação
{ $.message = "Tarefa criada" }
```

### CloudWatch Alarms

Crie alarmes para:

1. **Health Check Failures**
   - Métrica: HealthCheckStatus
   - Threshold: < 1 por 2 períodos consecutivos

2. **High Error Rate**
   - Métrica: 5XXError
   - Threshold: > 10 por 5 minutos

3. **Database Connection Issues**
   - Baseado em logs: `{ $.database = "disconnected" }`

## Troubleshooting

### Build Falha na Fase de Testes

```bash
# Verificar logs do CodeBuild
# Comum: Falha na conexão com banco

# Solução: Verificar se o CodeBuild tem acesso ao RDS
# - Security Group do RDS permite conexão do CodeBuild
# - Subnet do CodeBuild tem rota para o RDS
```

### Erro ao Ler Parameter Store

```bash
# Erro: AccessDeniedException

# Solução: Verificar IAM role do CodeBuild
aws iam get-role-policy \
  --role-name CodeBuildServiceRole \
  --policy-name ParameterStoreAccess
```

### Erro ao Ler Secrets Manager

```bash
# Erro: AccessDeniedException

# Solução: Adicionar permissão secretsmanager:GetSecretValue
# Verificar ARN do secret está correto no Parameter Store
```

### Container Não Inicia

```bash
# Verificar logs do ECS/Fargate
# Comum: Variáveis de ambiente faltando

# Solução: Verificar task definition
# - DB_HOST está configurado
# - DB_USER e DB_PWD vêm do Secrets Manager
```

### Health Check Retorna Unhealthy

```bash
# Verificar conexão com banco
# Testar manualmente:

docker run -it --rm \
  -e DB_HOST=seu-host \
  -e DB_USER=seu-user \
  -e DB_PWD=sua-senha \
  -e DB_NAME=postgres \
  sua-imagem \
  npm run db:test
```

## Rollback

Se algo der errado:

```bash
# Opção 1: Reverter commit
git revert HEAD
git push origin main

# Opção 2: Deploy de versão anterior
# No ECS, atualizar task definition para usar tag anterior
aws ecs update-service \
  --cluster seu-cluster \
  --service bia-service \
  --task-definition bia-task:VERSAO_ANTERIOR
```

## Ambientes Múltiplos

Para deploy em dev/staging/prod:

1. Criar parâmetros específicos por ambiente:
```bash
/bia/dev/secrets/rds-secret-arn
/bia/staging/secrets/rds-secret-arn
/bia/prod/secrets/rds-secret-arn
```

2. Atualizar buildspec.yml para usar variável de ambiente:
```yaml
env:
  variables:
    ENVIRONMENT: dev
  parameter-store:
    SECRET_ARN: /bia/${ENVIRONMENT}/secrets/rds-secret-arn
```

3. Configurar no CodeBuild:
   - Criar projetos separados (bia-dev, bia-staging, bia-prod)
   - Ou usar variável de ambiente ENVIRONMENT

## Checklist de Deploy

- [ ] Parameter Store configurado
- [ ] IAM role do CodeBuild atualizada
- [ ] Testes locais passando
- [ ] Lint sem erros
- [ ] Commit e push realizados
- [ ] Build do CodeBuild bem-sucedido
- [ ] Imagem no ECR
- [ ] Container rodando
- [ ] Health check retornando 200
- [ ] API respondendo corretamente
- [ ] Logs aparecendo no CloudWatch
- [ ] Alarmes configurados

## Suporte

Para problemas ou dúvidas:

1. Verificar logs do CodeBuild
2. Verificar logs do CloudWatch
3. Consultar documentação:
   - ENV_VARS.md
   - MELHORIAS.md
   - CHECKLIST.md
4. Revisar este guia de deploy
