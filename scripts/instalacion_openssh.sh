#!/bin/sh
sudo echo "Necesito ser súper usuario (root)"

# Sección instalación y config de SSH
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl enable ssh --now

# Sección firewall
sudo apt install ufw -y
sudo ufw allow ssh
echo "y" | sudo ufw enable
