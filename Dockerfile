FROM node:24-slim

WORKDIR /usr/src/app

# Copiar e instalar dependências do backend primeiro
COPY package*.json ./
RUN npm install --loglevel=error

# Copiar e buildar o frontend
COPY client/package*.json ./client/
RUN cd client && npm install --loglevel=error

# Copiar código fonte
COPY . .

# Buildar o React com Node.js 24
RUN cd client && REACT_APP_API_URL=http://localhost:3001 SKIP_PREFLIGHT_CHECK=true npm run build

# Mover build para local correto
RUN mv client/build client_build && rm -rf client && mkdir client && mv client_build client/build

EXPOSE 8080

CMD [ "npm", "start" ]
