locals {
  db_setup_script = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y mysql-server
sudo systemctl start mysql
sudo mysql -e "CREATE DATABASE attendance_db;"
sudo mysql -e "CREATE USER 'attendance_user'@'localhost' IDENTIFIED BY '${var.db_password}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON attendance_db.* TO 'attendance_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
EOF
}
