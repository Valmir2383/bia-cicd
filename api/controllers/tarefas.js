const initializeDatabase = require('../models');
const logger = require('../../lib/logger');

module.exports = () => {
  const controller = {};

  controller.create = async (req, res, next) => {
    try {
      const { Tarefas } = await initializeDatabase();
      const tarefa = {
        titulo: req.body.titulo,
        dia_atividade: req.body.dia,
        importante: req.body.importante,
      };

      const data = await Tarefas.create(tarefa);
      logger.info('Tarefa criada', { uuid: data.uuid });
      res.status(201).json(data);
    } catch (error) {
      next(error);
    }
  };

  controller.find = async (req, res, next) => {
    try {
      const { Tarefas } = await initializeDatabase();
      const { uuid } = req.params;
      const data = await Tarefas.findByPk(uuid);

      if (!data) {
        return res.status(404).json({
          error: 'Not Found',
          message: 'Tarefa não encontrada',
        });
      }

      res.json(data);
    } catch (error) {
      next(error);
    }
  };

  controller.delete = async (req, res, next) => {
    try {
      const { Tarefas } = await initializeDatabase();
      const { uuid } = req.params;

      const deleted = await Tarefas.destroy({ where: { uuid } });

      if (deleted === 0) {
        return res.status(404).json({
          error: 'Not Found',
          message: 'Tarefa não encontrada',
        });
      }

      logger.info('Tarefa deletada', { uuid });
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  };

  controller.update_priority = async (req, res, next) => {
    try {
      const { Tarefas } = await initializeDatabase();
      const { uuid } = req.params;

      const [updated] = await Tarefas.update(req.body, { where: { uuid } });

      if (updated === 0) {
        return res.status(404).json({
          error: 'Not Found',
          message: 'Tarefa não encontrada',
        });
      }

      const data = await Tarefas.findByPk(uuid);
      logger.info('Tarefa atualizada', { uuid });
      res.json(data);
    } catch (error) {
      next(error);
    }
  };

  controller.findAll = async (req, res, next) => {
    try {
      const { Tarefas } = await initializeDatabase();
      const data = await Tarefas.findAll();
      res.json(data);
    } catch (error) {
      next(error);
    }
  };

  return controller;
};
