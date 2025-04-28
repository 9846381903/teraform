locals {
  monitoring_setup_script = <<EOF
#!/bin/bash
# Install Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.0/node_exporter-1.9.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.9.0.linux-amd64.tar.gz
sudo mv node_exporter-1.9.0.linux-amd64/node_exporter /usr/local/bin/
sudo useradd --system --no-create-home --shell /bin/false node_exporter
cat <<EOT | sudo tee /etc/systemd/system/node-exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOT
sudo systemctl daemon-reload
sudo systemctl start node-exporter
sudo systemctl enable node-exporter

# Install Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.53.1/prometheus-2.53.1.linux-amd64.tar.gz
tar -xvf prometheus-2.53.1.linux-amd64.tar.gz
sudo mv prometheus-2.53.1.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-2.53.1.linux-amd64/promtool /usr/local/bin/
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo useradd --system --no-create-home --shell /bin/false prometheus
cat <<EOT | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
EOT
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
cat <<EOT | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
  --config.file /etc/prometheus/prometheus.yml \\
  --storage.tsdb.path /var/lib/prometheus \\
  --web.listen-address=0.0.0.0:9090

[Install]
WantedBy=multi-user.target
EOT
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Grafana
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
EOF
}
