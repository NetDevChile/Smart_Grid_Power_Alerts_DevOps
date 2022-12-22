# instalación net-snmp
sudo apt update
sudo apt install snmp snmp-mibs-downloader -y

# instalación OpenSSL
apt install openssl -y

# instalación Docker
apt install -y \
    apt-transport-https \
    ca-certificates \
curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - apt-key fingerprint 0EBFCD88
add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose;
sudo groupadd docker
sudo gpasswd -a $USER docker
newgrp docker

# inlfuxdb
mkdir -p /home/smartgrid/Escritorio/docker-data/influx1/etc
mkdir -p /home/smartgrid/Escritorio/docker-data/influx1/backup
mkdir -p /home/smartgrid/Escritorio/data/influx1
cp (deprecado)influxdb.conf /home/smartgrid/Escritorio/docker-data/influx1/etc/

# red Docker
docker network ls
docker network create dockerlink

# influx-nut
mkdir /var/tmp/influx-nut
cd /var/tmp/influx-nut
git clone https://github.com/lf-/influx_nut.git

