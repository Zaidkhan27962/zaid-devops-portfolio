# Stage 1: Build stage (future proof - agar baad mein CSS/JS compile karna ho)
FROM node:20-alpine AS builder
WORKDIR /app

# Stage 2: Production - Nginx
FROM nginx:1.25-alpine

# Remove default nginx configs
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Copy portfolio HTML
COPY frontend/index.html /usr/share/nginx/html/index.html

# Create cache/log/run directories and ensure they're writable
RUN mkdir -p /var/cache/nginx/client_temp /var/log/nginx /var/run/nginx && \
  chmod -R 777 /var/cache/nginx /var/log/nginx /var/run/nginx && \
  chmod 755 /usr/share/nginx/html && \
  chmod 644 /usr/share/nginx/html/index.html

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost || exit 1

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]