# Multi-stage build para otimização
FROM node:22-slim AS builder

WORKDIR /usr/src/app

# Instalar dependências do backend
COPY package*.json ./
RUN npm ci --only=production --loglevel=error

# Instalar e buildar frontend
COPY client/package*.json ./client/
COPY client/.env ./client/
RUN cd client && npm ci --loglevel=error

COPY . .
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN cd client && npm run build

# Stage final - imagem mínima
FROM node:22-slim

WORKDIR /usr/src/app

# Copiar apenas o necessário do builder
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/client/build ./client/build
COPY --from=builder /usr/src/app/package*.json ./
COPY --from=builder /usr/src/app/server.js ./
COPY --from=builder /usr/src/app/config ./config
COPY --from=builder /usr/src/app/api ./api
COPY --from=builder /usr/src/app/lib ./lib
COPY --from=builder /usr/src/app/database ./database

ENV NODE_ENV=production
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD [ "npm", "start" ]
