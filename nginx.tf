locals {
  nginx_setup_script = <<EOF
#!/bin/bash
sudo apt-get install -y nginx
cat <<EOT | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;
    root /var/www/html;
    index index.php index.html;
    server_name _;
    location / {
        try_files \$uri \$uri/ =404;
    }
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }
}
EOT
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
EOF
}
