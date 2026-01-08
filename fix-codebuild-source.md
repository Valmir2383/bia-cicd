# Correção do Erro de Source S3 no CodeBuild

## Problema
```
CLIENT_ERROR: error while downloading key bia-hom/SourceArti/prfp9wE
dial tcp 54.231.201.65:443: i/o timeout
```

## Soluções

### 1. Verificar Source Configuration
No console AWS CodeBuild, verificar:
- Source provider: deve ser GitHub/CodeCommit, não S3
- Se for S3, verificar se bucket existe e tem permissões

### 2. Mudar para GitHub Source
```json
{
  "source": {
    "type": "GITHUB",
    "location": "https://github.com/valmir2383/bia.git",
    "buildspec": "buildspec.yml"
  }
}
```

### 3. Configurar Webhook (se GitHub)
- Habilitar webhook para trigger automático
- Configurar branch: main/master

### 4. Verificar IAM Role do CodeBuild
Adicionar policies:
- AmazonS3ReadOnlyAccess (se usar S3)
- AWSCodeBuildDeveloperAccess

### 5. Configurar VPC (se necessário)
Se CodeBuild estiver em VPC privada:
- Configurar NAT Gateway
- Verificar Security Groups
- Adicionar VPC Endpoints para S3
