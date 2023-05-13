---
- hosts: all
  become: true
  tasks:
  - name: install promethus server
    shell: | 
      sudo apt update 
      sudo apt install docker.io -y 
      wget https://github.com/prometheus/prometheus/releases/download/v2.44.0-rc.2/prometheus-2.44.0-rc.2.linux-amd64.tar.gz 
      tar -xvzf prometheus-2.44.0-rc.2.linux-amd64.tar.gz 
      cd prometheus-2.44.0-rc.2.linux-amd64
      sudo docker run -d --name node-exporter -p 9100:9100 prom/node-exporter 
      echo '
      # my global config
      global:
        scrape_interval: 15s
        evaluation_interval: 15s

      alerting:
        alertmanagers:
          - static_configs:
              - targets:
                # - alertmanager:9093

      rule_files:

      scrape_configs:
        - job_name: "prometheus"
          static_configs:
            - targets: ["localhost:9090"]
        - job_name: "node-exporter"
          static_configs:
            - targets: ["localhost:9100"]
      ' > prometheus.yml
      nohup ./prometheus > prometheus.log 2>&1 &
  

  - name: install grafana server
    shell: |
      sudo apt-get install -y apt-transport-https
      sudo apt-get install -y software-properties-common wget
      sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
      echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
      sudo apt-get update
      sudo apt-get install grafana -y 
      sudo systemctl daemon-reload
      sudo systemctl start grafana-server
      sudo systemctl enable grafana-server
