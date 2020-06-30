#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo docker run -d -e "APPPORT=3000" -p 3000:3000 --restart on-failure christianhxc/golang-customserver:1.0 
