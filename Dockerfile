# Stage 1: Builder
FROM node:20.11.0-alpine3.19 AS builder

WORKDIR /app

COPY package.json ./
RUN npm install

COPY . .

# Stage 2: Production
FROM node:20.11.0-alpine3.19 AS production

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/server.js .
COPY --from=builder --chown=appuser:appgroup /app/package.json .

USER appuser

EXPOSE 3000

CMD ["node", "server.js"]