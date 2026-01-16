# Variáveis de Ambiente - BIA CI/CD

## Obrigatórias

### Banco de Dados
- `DB_HOST` - Hostname do banco PostgreSQL (ex: `bia-db.xxx.rds.amazonaws.com`)
- `DB_USER` - Usuário do banco de dados
- `DB_PWD` - Senha do banco de dados
- `DB_NAME` - Nome do banco de dados (padrão: `postgres`)
- `DB_PORT` - Porta do banco (padrão: `5432`)

### Aplicação
- `PORT` - Porta da aplicação (padrão: `8080`)
- `NODE_ENV` - Ambiente de execução (`development`, `test`, `production`)

## Opcionais

### SSL/TLS
- `DB_SSL` - Habilitar SSL no banco (`true`/`false`, padrão: `true`)
- `RDS_CA_CERT` - Caminho para certificado CA do RDS (para SSL com verificação)

### AWS (para CI/CD)
- `AWS_DEFAULT_REGION` - Região AWS (padrão: `us-east-1`)
- `AWS_ACCOUNT_ID` - ID da conta AWS (obtido automaticamente no pipeline)

## Parameter Store (CodeBuild)

Configure no AWS Systems Manager Parameter Store:

```bash
# ARN do secret do RDS no Secrets Manager
/bia/secrets/rds-secret-arn

# Hostname do banco de dados
/bia/db/host

# Nome do repositório ECR
/bia/ecr/repository-name
```

## Exemplo de Configuração Local

Crie um arquivo `.env` na raiz do projeto (não commitar):

```bash
DB_HOST=localhost
DB_USER=postgres
DB_PWD=postgres
DB_NAME=postgres
DB_PORT=5432
DB_SSL=false
PORT=8080
NODE_ENV=development
```

## Configuração no CodeBuild

1. Crie os parâmetros no Parameter Store:
```bash
aws ssm put-parameter \
  --name /bia/secrets/rds-secret-arn \
  --value "arn:aws:secretsmanager:us-east-1:ACCOUNT_ID:secret:SECRET_NAME" \
  --type String

aws ssm put-parameter \
  --name /bia/db/host \
  --value "bia-db.xxx.rds.amazonaws.com" \
  --type String

aws ssm put-parameter \
  --name /bia/ecr/repository-name \
  --value "bia" \
  --type String
```

2. Garanta que a role do CodeBuild tenha permissão para:
   - Ler parâmetros do Parameter Store
   - Ler secrets do Secrets Manager
   - Push para ECR
