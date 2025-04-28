# Project Structure

The project consists of the following Terraform files:

### 1. `variables.tf`
- **Purpose**: Defines input variables for the Terraform configuration.
- **Details**:
  - Contains the `db_password` variable, which is used to set the MySQL database password for the `attendance_user`.
  - The variable is marked as `sensitive` to prevent it from being displayed in Terraform logs.

### 2. `instance.tf`
- **Purpose**: Sets up the AWS EC2 instance and security group.
- **Details**:
  - Configures the AWS provider for the `ap-south-1` region.
  - Creates an EC2 instance (`t2.micro`) using the specified AMI (`ami-0e35ddab05955cf57`) and key pair (`attendance-key`).
  - Defines a security group (`web_sg`) to allow inbound traffic on:
    - Port 22 (SSH)
    - Port 80 (HTTP for the web application)
    - Port 9100 (Node Exporter)
    - Port 9090 (Prometheus)
    - Port 3000 (Grafana)
  - Includes a `user_data` script to stop/disable Apache (to free port 80) and run scripts from other `.tf` files for setting up the database, PHP, Nginx, and monitoring.

### 3. `db.tf`
- **Purpose**: Installs and configures MySQL on the EC2 instance.
- **Details**:
  - Installs the MySQL server.
  - Creates a database named `attendance_db`.
  - Sets up a MySQL user (`attendance_user@localhost`) with the password provided via the `db_password` variable.
  - Grants the user full privileges on the `attendance_db` database.

### 4. `php.tf`
- **Purpose**: Installs PHP and sets up the attendance application.
- **Details**:
  - Installs PHP 8.3 and required extensions (`php8.3-mysql`, `php8.3-fpm`).
  - Creates the attendance web page (`/var/www/html/index.php`) with a form to record student attendance (name and status: Present/Absent).
  - The PHP application connects to the MySQL database using the `attendance_user` and the password from the `db_password` variable.
  - Stores and displays attendance records in a table.

### 5. `nginx.tf`
- **Purpose**: Installs and configures Nginx as the web server.
- **Details**:
  - Installs Nginx.
  - Configures Nginx to serve PHP files from `/var/www/html` using PHP-FPM (PHP 8.3).
  - Sets up Nginx to listen on port 80 and handle PHP requests via the `fastcgi_pass` directive.

### 6. `monitoring.tf`
- **Purpose**: Sets up observability tools to monitor the EC2 instance.
- **Details**:
  - Installs **Node Exporter** to collect system metrics (CPU, memory, disk, etc.) and exposes them on port 9100.
  - Installs **Prometheus** to scrape metrics from Node Exporter and exposes its web UI on port 9090.
  - Installs **Grafana** to visualize metrics and exposes its web UI on port 3000.
  - All tools are installed directly on the VM (no Docker) and run as systemd services.

