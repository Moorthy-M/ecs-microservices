#Layer - Build Stage

FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

#Layer - Runtime Stage

FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=build /app/server.js /server.js

ENV PORT=8081
EXPOSE 8081
CMD ["node", "server.js"]
