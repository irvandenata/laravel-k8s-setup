FROM nginx
COPY /docker/vhost.conf /etc/nginx/conf.d/default.conf
