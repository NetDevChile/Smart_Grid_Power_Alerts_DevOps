#!/bin/sh
sudo echo "Necesito ser súper usuario (root)"

# Sección instalación y config de RKE CLI
sudo apt-get install wget -y
wget https://github.com/rancher/rke/releases/download/v1.4.1/rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke
sudo chmod +x /usr/local/bin/rke

# Sección instalación y config de kubectl
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Sección instalación y config de helm
wget https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz
tar -zxvf helm-v3.10.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
