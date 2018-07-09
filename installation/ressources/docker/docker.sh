#!/bin/bash

installPrerequired(){
  yum -y install curl yum-utils epel-release device-mapper-persistent-data lvm2
  mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=$proxy"
EOF

}

installDocker(){
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum -y remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-selinux \
                docker-engine-selinux \
                docker-engine
  
  yum -y install docker-ce
  systemctl start docker
}

addUserToGroupDocker(){
  usermod -aG docker $(whoami)
}

loginToDockerHub(){
  docker login -u tmpuser -p tmpuser
}

installDockerCompose(){
  curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  systemctl restart docker
  docker-compose --version
}
