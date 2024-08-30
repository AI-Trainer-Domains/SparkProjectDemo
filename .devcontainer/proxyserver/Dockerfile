FROM nginx:latest
LABEL authors="dalexander"

COPY .devcontainer/proxynode/nginx.conf /etc/nginx/nginx.conf
COPY .devcontainer/proxynode/certs /etc/nginx/ssl

EXPOSE 80 443
