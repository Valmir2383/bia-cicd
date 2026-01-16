// Este formato é o padrão exigido pelo Sequelize CLI
const config = {
  username: process.env.DB_USER || "postgres",
  password: process.env.DB_PWD || "postgres",
  database: process.env.DB_NAME || "postgres",
  host: process.env.DB_HOST || "bia-db.c4nckw8qytev.us-east-1.rds.amazonaws.com",
  port: process.env.DB_PORT || 5432,
  dialect: "postgres",
  logging: false,
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  }
};

module.exports = {
  development: config,
  test: config,
  production: config
};