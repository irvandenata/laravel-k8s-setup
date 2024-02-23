FROM nginx:1.19-alpine AS nginx
WORKDIR /var/www/html
COPY / /var/www/html/
COPY /docker/vhost.conf /etc/nginx/conf.d/default.conf
# COPY --from=assets-build /public /var/www/html/
