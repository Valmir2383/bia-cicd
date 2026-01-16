module.exports = {
  up: async (queryInterface, Sequelize) => queryInterface.createTable('Tarefas', {
    uuid: {
      allowNull: false,
      primaryKey: true,
      defaultValue: Sequelize.UUIDV1,
      type: Sequelize.UUID,
    },
    titulo: {
      allowNull: false,
      type: Sequelize.STRING,
    },
    dia_atividade: {
      allowNull: true,
      type: Sequelize.STRING,
    },
    importante: {
      allowNull: true,
      defaultValue: false,
      type: Sequelize.BOOLEAN,
    },
    createdAt: {
      allowNull: false,
      type: Sequelize.DATE,
    },
    updatedAt: {
      allowNull: false,
      type: Sequelize.DATE,
    },
  }),

  down: async (queryInterface) => {
    await queryInterface.dropTable('Tarefas');
  },
};
