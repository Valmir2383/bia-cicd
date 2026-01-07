const initializeDatabase = require("../models");

module.exports = () => {
  const controller = {};

  controller.create = async (req, res) => {
    try {
      const { Tarefas } = await initializeDatabase();
      let tarefa = {
        titulo: req.body.titulo,
        dia_atividade: req.body.dia,
        importante: req.body.importante,
      };

      Tarefas.create(tarefa)
        .then((data) => {
          res.send(data);
        })
        .catch((err) => {
          res.status(500).send({
            message: err.message || "Deu ruim.",
          });
        });
    } catch (error) {
      res.status(500).send({ message: "Erro ao inicializar banco de dados." });
    }
  };

  controller.find = async (req, res) => {
    try {
      const { Tarefas } = await initializeDatabase();
      let uuid = req.params.uuid;
      Tarefas.findByPk(uuid)
        .then((data) => {
          res.send(data);
        })
        .catch((err) => {
          res.status(500).send({
            message: err.message || "Deu ruim.",
          });
        });
    } catch (error) {
      res.status(500).send({ message: "Erro ao inicializar banco de dados." });
    }
  };

  controller.delete = async (req, res) => {
    try {
      const { Tarefas } = await initializeDatabase();
      let { uuid } = req.params;

      Tarefas.destroy({
        where: {
          uuid: uuid,
        },
      })
        .then(() => {
          res.send();
        })
        .catch((err) => {
          res.status(500).send({
            message: err.message || "Deu ruim.",
          });
        });
    } catch (error) {
      res.status(500).send({ message: "Erro ao inicializar banco de dados." });
    }
  };

  controller.update_priority = async (req, res) => {
    try {
      const { Tarefas } = await initializeDatabase();
      let { uuid } = req.params;

      Tarefas.update(req.body, {
        where: {
          uuid: uuid,
        },
      })
        .then(() => {
          Tarefas.findByPk(uuid).then((data) => {
            res.send(data);
          });
        })
        .catch((err) => {
          res.status(500).send({
            message: err.message || "Deu ruim.",
          });
        });
    } catch (error) {
      res.status(500).send({ message: "Erro ao inicializar banco de dados." });
    }
  };

  controller.findAll = async (req, res) => {
    try {
      const { Tarefas } = await initializeDatabase();
      Tarefas.findAll()
        .then((data) => {
          res.send(data);
        })
        .catch((err) => {
          res.status(500).send({
            message: err.message || "Deu ruim.",
          });
        });
    } catch (error) {
      res.status(500).send({ message: "Erro ao inicializar banco de dados." });
    }
  };
  
  return controller;
};
