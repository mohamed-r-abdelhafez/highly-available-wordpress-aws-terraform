#!/bin/bash

# Update packages and install dependencies
sudo yum update -y
sudo yum install -y nginx 
sudo yum install -y mariadb105
sudo yum install -y php8.2 php-fpm php-mbstring php-xml php-mysqlnd amazon-ssm-agent
sudo yum install -y amazon-efs-utils

# Enable and start NGINX and PHP-FPM services
sudo systemctl enable nginx
sudo systemctl enable php-fpm
sudo systemctl start nginx
sudo systemctl start php-fpm

# Install and configure the SSM Agent
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent

# Install Memcached Client
sudo wget https://elasticache-downloads.s3.amazonaws.com/ClusterClient/PHP-8.2/latest-64bit-X86-openssl3
sudo tar -zxvf latest-64bit-X86-openssl3
sudo mv amazon-elasticache-cluster-client.so /usr/lib64/php8.2/modules/
sudo echo "extension=amazon-elasticache-cluster-client.so" | sudo tee --append /etc/php.d/50-memcached.ini
sudo rm -rfv latest-64bit-X86-openssl3 


# Fetching Database Credentials from SSM Parameter Store
DB_NAME=$(aws ssm get-parameter --name "/db-server/db-name" --with-decryption --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "/db-server/db-username" --with-decryption --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/db-server/password" --with-decryption --query "Parameter.Value" --output text)
DB_HOST=$(aws ssm get-parameter --name "/db-server/db-host" --with-decryption --query "Parameter.Value" --output text)

# Fetching Memcached Endpoint & Port from SSM Parameter Store
MEMCACHED_ENDPOINT=$(aws ssm get-parameter --name "/memcached/endpoint" --with-decryption --query "Parameter.Value" --output text)
MEMCACHED_PORT=$(aws ssm get-parameter --name "/memcached/port" --with-decryption --query "Parameter.Value" --output text)

# Fetching EFS ID from SSM Parameter Store
EFS_ID=$(aws ssm get-parameter --name "/efs/id" --with-decryption --query "Parameter.Value" --output text)


# Fetching Wordpress Credentials from SSM Parameter Store
site_url=$(aws ssm get-parameter --name "/wordpress/site_url" --with-decryption --query "Parameter.Value" --output text)
wp_title=$(aws ssm get-parameter --name "/wordpress/title" --with-decryption --query "Parameter.Value" --output text)
wp_username=$(aws ssm get-parameter --name "/wordpress/username" --with-decryption --query "Parameter.Value" --output text)
wp_password=$(aws ssm get-parameter --name "/wordpress/password" --with-decryption --query "Parameter.Value" --output text)
wp_email=$(aws ssm get-parameter --name "/wordpress/email" --with-decryption --query "Parameter.Value" --output text)

# Adjust permissions
sudo chown -R nginx:nginx /var/www/html
sudo chmod -R 755 /var/www/html

#Mount EFS file system
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "$EFS_ID".efs.ap-south-1.amazonaws.com:/ /var/www/html

# Download WordPress
cd /var/www
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo rm latest.tar.gz

# Move WordPress files to html director
sudo mv wordpress/* html

# Set up the WordPress wp-config.php file
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php

# Set WordPress configurations
sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
sudo sed -i "s/localhost/$DB_HOST/" wp-config.php

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

#Install w3-total cache plugin 
sudo -u nginx wp plugin install w3-total-cache --activate
# Configure W3 Total Cache to use Memcached
sudo -u nginx wp option update w3tc_config '{"dbcache.engine":"memcached","objectcache.engine":"memcached","pagecache.engine":"memcached"}'

# Update wp-config.php with Memcached settings
cat <<EOL >> /var/www/html/wp-config.php

// Memcached configuration
\$memcached_servers = array(
    array('$MEMCACHED_ENDPOINT', '$PORT')
);
EOL

# Run WordPress core installation
echo "Installing WordPress...."
sudo -u nginx wp core install --url=$site_url --title="$wp_title" --admin_user=$wp_username --admin_password=$wp_password --admin_email=$wp_email

# Configure NGINX
sudo cat <<EOT > /etc/nginx/conf.d/wordpress.conf
server {
    listen 80;
    server_name _;
    root /var/www/html;

    index index.php index.html index.htm;
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }
    
    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~* \.(jpg|jpeg|png|gif|css|js|ico|svg)$ {
        expires max;
        log_not_found off;
    }
}
EOT

sudo sed -i "s/^listen = .*/listen = 127.0.0.1:9000/" /etc/php-fpm.d/www.conf
sudo systemctl restart php-fpm
# Restart NGINX to apply configuration changes
sudo systemctl restart nginx
