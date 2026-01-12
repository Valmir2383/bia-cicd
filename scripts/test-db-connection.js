const { Sequelize } = require('sequelize');

async function testConnection() {
  try {
    // Usar as variáveis de ambiente já configuradas no buildspec
    const config = {
      username: process.env.DB_USER,
      password: process.env.DB_PWD,
      database: process.env.DB_NAME || "postgres",
      host: process.env.DB_HOST,
      port: process.env.DB_PORT || 5432,
      dialect: "postgres",
      dialectOptions: {
        ssl: {
          require: true,
          rejectUnauthorized: false
        }
      },
      logging: false
    };

    console.log(`Testando conexão com: ${config.host}:${config.port}/${config.database}`);
    
    const sequelize = new Sequelize(config);
    await sequelize.authenticate();
    
    console.log('✅ Conexão com banco estabelecida com sucesso');
    await sequelize.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Erro ao conectar com banco:', error.message);
    process.exit(1);
  }
}

testConnection();
