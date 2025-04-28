locals {
  php_setup_script = <<EOF
#!/bin/bash
sudo apt-get install -y php8.3 php8.3-mysql php8.3-fpm
sudo mkdir -p /var/www/html
cat <<EOT | sudo tee /var/www/html/index.php
<?php
// Database connection
\$conn = new mysqli("localhost", "attendance_user", "${var.db_password}", "attendance_db");
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}

// Handle form submission
if (\$_SERVER["REQUEST_METHOD"] == "POST") {
    \$student_name = \$conn->real_escape_string(\$_POST['student_name']);
    \$status = \$conn->real_escape_string(\$_POST['status']);
    \$date = date("Y-m-d H:i:s");
    \$sql = "INSERT INTO attendance (student_name, status, date) VALUES ('\$student_name', '\$status', '\$date')";
    if (\$conn->query(\$sql) === TRUE) {
        echo "Attendance recorded successfully!";
    } else {
        echo "Error: " . \$conn->error;
    }
}

// Create table if it doesn't exist
\$sql = "CREATE TABLE IF NOT EXISTS attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(255) NOT NULL,
    status ENUM('Present', 'Absent') NOT NULL,
    date DATETIME NOT NULL
)";
\$conn->query(\$sql);

// Fetch attendance records
\$result = \$conn->query("SELECT * FROM attendance ORDER BY date DESC");
?>

<!DOCTYPE html>
<html>
<head>
    <title>Classroom Attendance</title>
</head>
<body>
    <h1>Classroom Attendance</h1>
    <form method="post">
        <label for="student_name">Student Name:</label>
        <input type="text" name="student_name" required><br>
        <label for="status">Status:</label>
        <select name="status">
            <option value="Present">Present</option>
            <option value="Absent">Absent</option>
        </select><br>
        <input type="submit" value="Record Attendance">
    </form>

    <h2>Attendance Records</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Student Name</th>
            <th>Status</th>
            <th>Date</th>
        </tr>
        <?php
        if (\$result->num_rows > 0) {
            while (\$row = \$result->fetch_assoc()) {
                echo "<tr>";
                echo "<td>" . \$row['id'] . "</td>";
                echo "<td>" . \$row['student_name'] . "</td>";
                echo "<td>" . \$row['status'] . "</td>";
                echo "<td>" . \$row['date'] . "</td>";
                echo "</tr>";
            }
        } else {
            echo "<tr><td colspan='4'>No records found</td></tr>";
        }
        \$conn->close();
        ?>
    </table>
</body>
</html>
EOT
sudo chmod 644 /var/www/html/index.php
sudo chown www-data:www-data /var/www/html/index.php
EOF
}
