FROM nginx:latest
COPY /docker/vhost.conf /etc/nginx/conf.d/default.conf
