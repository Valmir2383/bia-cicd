FROM node:22-slim

WORKDIR /usr/src/app

# Copiar e instalar dependências do backend primeiro
COPY package*.json ./
RUN npm install --loglevel=error

# Copiar e buildar o frontend
COPY client/package*.json ./client/
COPY client/.env ./client/
RUN cd client && npm install --loglevel=error

# Copiar código fonte
COPY . .
ENV NODE_OPTIONS=--openssl-legacy-provider
# Buildar o React com configurações do .env
RUN cd client && npm run build

# Mover build para local correto
RUN mv client/build client_build && rm -rf client && mkdir client && mv client_build client/build

EXPOSE 8080

CMD [ "npm", "start" ]
