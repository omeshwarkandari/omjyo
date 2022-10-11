#!/bin/bash

sudo yum update
sudo yum install httpd -y
echo "Hello World Server1!" > /var/www/html/index.html
service httpd start
