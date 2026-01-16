const initializeDatabase = require("../models");

module.exports = () => {
  const controller = {};

  controller.check = async (req, res) => {
    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: 'unknown'
    };

    try {
      const { sequelize } = await initializeDatabase();
      await sequelize.authenticate();
      health.database = 'connected';
      res.json(health);
    } catch (error) {
      health.status = 'unhealthy';
      health.database = 'disconnected';
      res.status(503).json(health);
    }
  };

  return controller;
};
