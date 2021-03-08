#!/bin/bash
sudo apt-get install default-jre -y
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt install filebeat -y
sudo filebeat modules enable system
sudo filebeat setup --pipelines --modules system
sudo filebeat modules enable apache
