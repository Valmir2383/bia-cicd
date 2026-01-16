const express = require("express");
var cors = require("cors");
var path = require("path");
const config = require("config");
var bodyParser = require("body-parser");
const logger = require("../lib/logger");
const errorHandler = require("../api/middleware/errorHandler");

module.exports = () => {
  const app = express();

  // SETANDO VARIÁVEIS DA APLICAÇÃO
  app.set("port", process.env.PORT || config.get("server.port"));

  //Setando react
  app.use(express.static(path.join(__dirname, "../", "client", "build")));

  // parse request bodies (req.body)
  app.use(express.urlencoded({ extended: true }));
  app.use(bodyParser.json());

  app.use(cors());

  // Request logging
  app.use((req, res, next) => {
    logger.info('Request received', {
      method: req.method,
      path: req.path,
      ip: req.ip
    });
    next();
  });

  require("../api/routes/health")(app);
  require("../api/routes/tarefas")(app);
  require("../api/routes/versao")(app);

  // Error handler (deve ser o último middleware)
  app.use(errorHandler);

  return app;
};
