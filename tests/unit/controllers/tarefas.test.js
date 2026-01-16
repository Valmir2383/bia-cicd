const tarefasController = require('../../../api/controllers/tarefas');

// Mock do initializeDatabase
jest.mock('../../../api/models', () => {
  return jest.fn(() => Promise.resolve({
    Tarefas: {
      create: jest.fn(),
      findAll: jest.fn(),
      findByPk: jest.fn(),
      update: jest.fn(),
      destroy: jest.fn()
    }
  }));
});

describe('Tarefas Controller', () => {
  let req, res, next, mockTarefas;

  beforeEach(() => {
    req = {
      body: { titulo: 'Test', dia: '2024-01-01', importante: true },
      params: { uuid: 'test-uuid' }
    };
    res = {
      send: jest.fn(),
      json: jest.fn(),
      status: jest.fn().mockReturnThis()
    };
    next = jest.fn();
    
    const initializeDatabase = require('../../../api/models');
    mockTarefas = {
      create: jest.fn(),
      findAll: jest.fn(),
      findByPk: jest.fn(),
      update: jest.fn(),
      destroy: jest.fn()
    };
    initializeDatabase.mockResolvedValue({ Tarefas: mockTarefas });
    
    jest.clearAllMocks();
  });

  test('findAll deve retornar todas as tarefas', async () => {
    const mockData = [{ id: 1, titulo: 'Test' }];
    mockTarefas.findAll.mockResolvedValue(mockData);

    const { findAll } = tarefasController();
    await findAll(req, res, next);

    expect(mockTarefas.findAll).toHaveBeenCalled();
    expect(res.json).toHaveBeenCalledWith(mockData);
  });

  test('create deve criar uma nova tarefa', async () => {
    const mockData = { id: 1, uuid: 'test-uuid', titulo: 'Test' };
    mockTarefas.create.mockResolvedValue(mockData);

    const { create } = tarefasController();
    await create(req, res, next);

    expect(mockTarefas.create).toHaveBeenCalledWith({
      titulo: 'Test',
      dia_atividade: '2024-01-01',
      importante: true
    });
    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(mockData);
  });
});
