const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

let dbConfig = null;

async function getDbConfig() {
  if (dbConfig) return dbConfig;

  // Se estiver em ambiente local, usar variáveis de ambiente
  if (isLocalConnection()) {
    dbConfig = {
      username: process.env.DB_USER || "postgres",
      password: process.env.DB_PWD || "postgres",
      database: process.env.DB_NAME || "postgres", // Usar postgres em vez de bia
      host: process.env.DB_HOST || "127.0.0.1",
      port: process.env.DB_PORT || 5433,
      dialect: "postgres",
      dialectOptions: getRemoteDialectOptions()
    };
    return dbConfig;
  }

  // Em produção, usar Secrets Manager
  try {
    const client = new SecretsManagerClient({ region: 'us-east-1' });
    const secretName = process.env.DB_SECRET_NAME || 'bia/database/credentials';
    const command = new GetSecretValueCommand({ SecretId: secretName });
    const secret = await client.send(command);
    
    const credentials = JSON.parse(secret.SecretString);
    
    dbConfig = {
      username: credentials.username,
      password: credentials.password,
      database: credentials.database,
      host: credentials.host,
      port: credentials.port,
      dialect: "postgres",
      dialectOptions: getRemoteDialectOptions()
    };
    
    return dbConfig;
  } catch (error) {
    console.error('Erro ao buscar credenciais:', error);
    throw error;
  }
}

module.exports = getDbConfig;

function isLocalConnection() {
  // Usar variáveis de ambiente quando DB_HOST está definido (CodeBuild)
  // Usar Secrets Manager apenas quando não há variáveis de ambiente
  return (
    process.env.DB_HOST !== undefined &&
    process.env.DB_USER !== undefined &&
    process.env.DB_PWD !== undefined
  );
}

function getRemoteDialectOptions() {
  // Configurações específicas para conexões remotas (útil a partir do pg 15)
  return {
    ssl: {
      require: true,
      rejectUnauthorized: false, // Permite certificados auto-assinados
    },
  };
}
