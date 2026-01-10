# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Serve
FROM nginx:alpine

# Copy static assets from builder
COPY --from=builder /app/out /usr/share/nginx/html

# Copy custom nginx config if needed (optional, using default for now but robust for SPA)
# We need a simple config to handle clean URLs (e.g. /blog -> /blog.html)
RUN echo 'server { \
    listen 80; \
    root /usr/share/nginx/html; \
    index index.html; \
    include /etc/nginx/mime.types; \
    location / { \
    try_files $uri $uri.html $uri/ =404; \
    } \
    error_page 404 /404.html; \
    }' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
