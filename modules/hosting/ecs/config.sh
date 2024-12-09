#!/bin/bash

echo "Updating system packages..."
sudo dnf update -y

echo "Installing nginx..."
sudo dnf install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

# Check nginx service/status
echo "Checking nginx status..."
if systemctl is-active --quiet nginx; then
    echo "Nginx is running."
else
    echo "Nginx failed to start."
    exit 1
fi