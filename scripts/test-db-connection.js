const { Sequelize } = require('sequelize');

async function getDbConfig() {
  // 1. Prioridade Total: Variáveis de Ambiente (Injetadas pelo Buildspec)
  if (process.env.DB_USER && process.env.DB_PWD) {
    console.log('Usando credenciais das variáveis de ambiente...');
    return {
      username: process.env.DB_USER,
      password: process.env.DB_PWD,
      database: process.env.DB_NAME || 'postgres',
      host: process.env.DB_HOST || 'bia-db.c4nckw8qytev.us-east-1.rds.amazonaws.com',
      port: process.env.DB_PORT || 5432,
      dialect: 'postgres',
      logging: false,
      dialectOptions: {
        ssl: {
          require: true,
          rejectUnauthorized: false,
        },
      },
    };
  }

  // 2. Fallback para Localhost (Desenvolvimento)
  return {
    username: 'postgres',
    password: 'password',
    database: 'bia',
    host: '127.0.0.1',
    port: 5432,
    dialect: 'postgres',
    logging: false,
  };
}

async function testConnection() {
  try {
    const config = await getDbConfig();
    console.log(`Tentando conectar ao host: ${config.host}`);

    const sequelize = new Sequelize(
      config.database,
      config.username,
      config.password,
      {
        host: config.host,
        port: config.port,
        dialect: config.dialect,
        logging: config.logging,
        dialectOptions: config.dialectOptions,
      },
    );

    await sequelize.authenticate();
    console.log('✅ Conexão com banco estabelecida com sucesso');
    process.exit(0);
  } catch (error) {
    console.error('❌ Erro ao conectar com banco:', error.message);
    process.exit(1);
  }
}

testConnection();
