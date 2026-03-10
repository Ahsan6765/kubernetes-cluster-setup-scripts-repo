#!/bin/bash

# =========================================================
# LAMP Stack Auto Installer for Azure Ubuntu VM
# Apache + MySQL + PHP + Virtual Host + Firewall
# =========================================================

set -e

VM_IP="104.211.60.242"
SITE_NAME="mysite"
WEB_ROOT="/var/www/$SITE_NAME"

echo "Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "Installing Apache..."
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

echo "Installing MySQL..."
sudo apt install mysql-server -y
sudo systemctl enable mysql
sudo systemctl start mysql

echo "Securing MySQL..."
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'StrongRootPass123!';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "Installing PHP and modules..."
sudo apt install php libapache2-mod-php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip -y

echo "Creating website directory..."
sudo mkdir -p $WEB_ROOT
sudo chown -R $USER:$USER $WEB_ROOT
sudo chmod -R 755 $WEB_ROOT

echo "Creating homepage..."
cat <<EOF > $WEB_ROOT/index.html
<html>
<head>
<title>Azure LAMP Server</title>
</head>
<body>
<h1>SUCCESS 🎉</h1>
<p>Your LAMP stack is deployed successfully!</p>
<p>Server IP: $VM_IP</p>
</body>
</html>
EOF

echo "Creating PHP test page..."
cat <<EOF > $WEB_ROOT/info.php
<?php
phpinfo();
?>
EOF

echo "Creating Apache Virtual Host..."
sudo bash -c "cat > /etc/apache2/sites-available/$SITE_NAME.conf" <<EOF
<VirtualHost *:80>
    ServerAdmin admin@localhost
    ServerName $VM_IP
    DocumentRoot $WEB_ROOT

    <Directory $WEB_ROOT>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${SITE_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${SITE_NAME}_access.log combined
</VirtualHost>
EOF

echo "Enabling virtual host..."
sudo a2ensite $SITE_NAME.conf
sudo a2dissite 000-default.conf

echo "Enabling Apache rewrite module..."
sudo a2enmod rewrite

echo "Restarting Apache..."
sudo apache2ctl configtest
sudo systemctl restart apache2

echo "Configuring Firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'
sudo ufw --force enable

echo "Creating MySQL database and user..."
sudo mysql -u root -pStrongRootPass123! <<EOF
CREATE DATABASE myapp;
CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON myapp.* TO 'myuser'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "================================================="
echo "LAMP STACK INSTALLATION COMPLETE!"
echo "================================================="
echo "Visit your site:"
echo "http://$VM_IP"
echo ""
echo "PHP Info page:"
echo "http://$VM_IP/info.php"
echo ""
echo "MySQL DB: myapp"
echo "DB User: myuser"
echo "DB Password: StrongPassword123!"
echo "MySQL root password: StrongRootPass123!"
echo "================================================="