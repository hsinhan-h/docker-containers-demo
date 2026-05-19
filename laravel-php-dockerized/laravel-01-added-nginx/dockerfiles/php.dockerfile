FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

COPY src .

RUN docker-php-ext-install pdo pdo_mysql
    #PHP-FPM 是用 www-data 執行，但 Laravel 的 storage、bootstrap/cache、database/database.sqlite 都是 root 建的，導致 Laravel 連 log 都寫不進去，這裡改 owner 和權限
    # && chown -R www-data:www-data /var/www/html \ 
    # && chmod -R ug+rwX /var/www/html/laravel/storage /var/www/html/laravel/bootstrap/cache /var/www/html/laravel/database

RUN chown -R www-data:www-data /var/www/html
