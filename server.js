const app = require("./config/express")();
const logger = require("./lib/logger");
const port = app.get("port");

// RODANDO NOSSA APLICAÇÃO NA PORTA SETADA
app.listen(port, () => {
  logger.info(`Servidor rodando na porta ${port}`, { 
    port, 
    env: process.env.NODE_ENV || 'development' 
  });
});
