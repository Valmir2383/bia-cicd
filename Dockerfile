FROM node:16-slim

WORKDIR /usr/src/app

# Primeiro, buildar o frontend em um diretório isolado
COPY client/ ./client/
RUN cd client && npm install && node --openssl-legacy-provider node_modules/.bin/react-scripts build

# Agora instalar backend
COPY package*.json ./
RUN npm install

# Copiar resto do código (exceto client)
COPY api/ ./api/
COPY config/ ./config/
COPY database/ ./database/
COPY lib/ ./lib/
COPY scripts/ ./scripts/
COPY server.js ./
COPY .sequelizerc ./

# Mover build do React para local correto
RUN rm -rf client/src client/public client/package*.json client/node_modules

EXPOSE 8080

CMD ["npm", "start"]
