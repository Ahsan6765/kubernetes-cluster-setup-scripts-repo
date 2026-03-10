#!/bin/bash

# =========================================================
# WordPress Auto Installer for Azure LAMP Server
# =========================================================

set -e

WEB_ROOT="/var/www/mysite"
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="StrongWPpassword123!"
DB_ROOT_PASS="StrongRootPass123!"

echo "Installing required PHP extensions..."
sudo apt update -y
sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip unzip curl -y

echo "Creating WordPress database and user..."
sudo mysql -u root -p$DB_ROOT_PASS <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "Downloading latest WordPress..."
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

echo "Cleaning web root..."
sudo rm -rf $WEB_ROOT/*

echo "Copying WordPress files..."
sudo cp -r /tmp/wordpress/* $WEB_ROOT

echo "Setting permissions..."
sudo chown -R www-data:www-data $WEB_ROOT
sudo chmod -R 755 $WEB_ROOT

echo "Creating wp-config.php..."
cd $WEB_ROOT
sudo cp wp-config-sample.php wp-config.php

sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
sudo sed -i "s/username_here/$DB_USER/" wp-config.php
sudo sed -i "s/password_here/$DB_PASS/" wp-config.php
sudo sed -i "s/localhost/localhost/" wp-config.php

echo "Adding WordPress security salts..."
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
sudo sed -i "/AUTH_KEY/d" wp-config.php
sudo sed -i "/SECURE_AUTH_KEY/d" wp-config.php
sudo sed -i "/LOGGED_IN_KEY/d" wp-config.php
sudo sed -i "/NONCE_KEY/d" wp-config.php
sudo sed -i "/AUTH_SALT/d" wp-config.php
sudo sed -i "/SECURE_AUTH_SALT/d" wp-config.php
sudo sed -i "/LOGGED_IN_SALT/d" wp-config.php
sudo sed -i "/NONCE_SALT/d" wp-config.php
echo "$SALTS" | sudo tee -a wp-config.php > /dev/null

echo "Enabling Apache rewrite module..."
sudo a2enmod rewrite

echo "Restarting Apache..."
sudo systemctl restart apache2

echo "Cleaning temporary files..."
rm -rf /tmp/wordpress*

echo "================================================="
echo "WordPress installation complete!"
echo "================================================="
echo "Open your browser and complete setup:"
echo "http://104.211.60.242"
echo ""
echo "Database Name: $DB_NAME"
echo "Database User: $DB_USER"
echo "Database Password: $DB_PASS"
echo "================================================="