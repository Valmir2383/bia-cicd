const logger = require('../../lib/logger');

// eslint-disable-next-line no-unused-vars
const errorHandler = (err, req, res, next) => {
  logger.error('Error occurred', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    body: req.body,
  });

  if (err.name === 'SequelizeValidationError') {
    return res.status(400).json({
      error: 'Validation Error',
      message: err.errors.map((e) => e.message).join(', '),
    });
  }

  if (err.name === 'SequelizeDatabaseError') {
    return res.status(500).json({
      error: 'Database Error',
      message: 'Erro ao processar operação no banco de dados',
    });
  }

  res.status(500).json({
    error: 'Internal Server Error',
    message: 'Ocorreu um erro inesperado. Por favor, tente novamente.',
  });
};

module.exports = errorHandler;
