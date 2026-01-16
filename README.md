# bia-cicd

Aplicação BIA com pipeline CI/CD integrado ao AWS CodeBuild.

## Funcionalidades
- API REST para gerenciamento de tarefas
- Frontend React integrado
- Pipeline CI/CD automatizado
- Integração segura com banco PostgreSQL via AWS Secrets Manager
- Health check endpoint
- Logging estruturado
- Validação de input
- Multi-stage Docker build

## Comandos
```bash
npm install          # Instalar dependências
npm test            # Executar testes unitários
npm run test:integration  # Executar testes de integração
npm run db:test     # Testar conexão com banco
npm run db:migrate  # Executar migrações
npm run lint        # Verificar código com ESLint
npm run lint:fix    # Corrigir problemas de lint automaticamente
npm start           # Iniciar aplicação
```

## Configuração

### Variáveis de Ambiente
Consulte [ENV_VARS.md](./ENV_VARS.md) para documentação completa das variáveis de ambiente.

### Setup do Parameter Store
```bash
./scripts/setup-parameters.sh
```

## Endpoints

### Health Check
- `GET /health` - Verifica status da aplicação e conexão com banco

### API de Tarefas
- `GET /api/tarefas` - Listar todas as tarefas
- `POST /api/tarefas` - Criar nova tarefa
- `GET /api/tarefas/:uuid` - Buscar tarefa por UUID
- `PUT /api/tarefas/update_priority/:uuid` - Atualizar prioridade
- `DELETE /api/tarefas/:uuid` - Deletar tarefa

### Versão
- `GET /api/versao` - Obter versão da API

## Melhorias Implementadas

✅ Validação de input com middleware  
✅ Tratamento de erros centralizado  
✅ Logging estruturado (JSON)  
✅ Health check endpoint  
✅ Parametrização do buildspec.yml  
✅ SSL configurável no banco  
✅ Multi-stage Docker build  
✅ ESLint configurado  
✅ Documentação de variáveis de ambiente  
✅ HTTP status codes apropriados  
✅ Docker healthcheck  

## Status
Pipeline testado em: 2026-01-16 17:17 - Melhorias de segurança e qualidade implementadas