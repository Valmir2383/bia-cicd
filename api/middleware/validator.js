const validator = {
  validateTarefa: (req, res, next) => {
    const { titulo, dia, importante } = req.body;
    
    if (!titulo || typeof titulo !== 'string' || titulo.trim().length === 0) {
      return res.status(400).json({ 
        error: 'Validation Error',
        message: 'Campo "titulo" é obrigatório e deve ser uma string não vazia' 
      });
    }
    
    if (titulo.length > 255) {
      return res.status(400).json({ 
        error: 'Validation Error',
        message: 'Campo "titulo" não pode exceder 255 caracteres' 
      });
    }
    
    if (dia && !/^\d{4}-\d{2}-\d{2}$/.test(dia)) {
      return res.status(400).json({ 
        error: 'Validation Error',
        message: 'Campo "dia" deve estar no formato YYYY-MM-DD' 
      });
    }
    
    if (importante !== undefined && typeof importante !== 'boolean') {
      return res.status(400).json({ 
        error: 'Validation Error',
        message: 'Campo "importante" deve ser um booleano' 
      });
    }
    
    next();
  },

  validateUUID: (req, res, next) => {
    const { uuid } = req.params;
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    
    if (!uuid || !uuidRegex.test(uuid)) {
      return res.status(400).json({ 
        error: 'Validation Error',
        message: 'UUID inválido' 
      });
    }
    
    next();
  }
};

module.exports = validator;
