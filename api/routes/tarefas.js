module.exports = (app) => {
  const controller = require("../controllers/tarefas")();
  const { validateTarefa, validateUUID } = require("../middleware/validator");

  app.route("/api/tarefas")
    .get(controller.findAll)
    .post(validateTarefa, controller.create);
  
  app.route("/api/tarefas/:uuid")
    .get(validateUUID, controller.find)
    .delete(validateUUID, controller.delete);
  
  app.route("/api/tarefas/update_priority/:uuid")
    .put(validateUUID, controller.update_priority);
};
