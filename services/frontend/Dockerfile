FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ARG VITE_AUTH_URL
ARG VITE_CATALOG_URL
ENV VITE_AUTH_URL=$VITE_AUTH_URL
ENV VITE_CATALOG_URL=$VITE_CATALOG_URL
RUN npm run build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
