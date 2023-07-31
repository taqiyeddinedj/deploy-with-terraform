#!/bin/bash
sudo yum install httpd -y
sudo systemctl start httpd
hostname=$(hostname)
echo "<html><h1>Hello Taqiyeddine, from host: $hostname</h1></html>" > /var/www/html/index.html