module.exports = (app) => {
  const controller = require('../controllers/health')();

  app.route('/health').get(controller.check);
  app.route('/api/health').get(controller.check);
};
