createDockerfileCentosSystemd(){
cat > $DIR/ansible/Dockerfile <<EOF
FROM centos:7
ENV container docker
ENV http_proxy=$proxy
ENV https_proxy=$proxy
RUN yum -y swap -- remove systemd-container systemd-container-libs -- install systemd systemd-libs
RUN yum -y update; yum clean all \
 && (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ \$i == systemd-tmpfiles-setup.service ] || rm -f \$i; done) \
 && rm -f /lib/systemd/system/multi-user.target.wants/* \
 && rm -f /etc/systemd/system/*.wants/* \
 && rm -f /lib/systemd/system/local-fs.target.wants/* \
 && rm -f /lib/systemd/system/sockets.target.wants/*udev* \
 && rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
 && rm -f /lib/systemd/system/basic.target.wants/* \
 && rm -f /lib/systemd/system/anaconda.target.wants/*
VOLUME [ "/sys/fs/cgroup" ]
EOF
}

createDockerfileSshCentos(){
cat > $DIR/ansible/Dockerfile <<EOF
FROM centos-systemd
ENV http_proxy=$proxy
ENV https_proxy=$proxy
RUN yum -y install openssh-server openssh-clients epel-release sudo && \
    rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN sed -i 's/required/optional/g' /etc/pam.d/sshd

RUN useradd -ms /bin/bash $USER \
 && echo "$USER:$PASSWORD" | chpasswd \
 && echo "root:root" | chpasswd \
 && usermod -aG wheel $USER

RUN yum -y update \
 && yum -y install openssh-server vim openssh-clients \
 && yum clean all

RUN ssh-keygen -A \
 && ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P "" \ 
 && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config 

RUN su - $USER \
 && mkdir /home/$USER/.ssh/ \
 && ssh-keygen -t rsa -f /home/$USER/.ssh/id_rsa -q -P "" \ 
 && chown -R $USER:$USER /home/$USER/.ssh/

EXPOSE 22
RUN systemctl enable sshd
EOF
}

createContainerAnsible(){
cat > $DIR/ansible/Dockerfile <<EOF
FROM ssh-centos
ENV http_proxy=$proxy
ENV https_proxy=$proxy
RUN yum -y update \
    && yum install -y epel-release ansible \
    && yum clean all
EOF
}

buildContainer(){
 cd $DIR/ansible
 local name=$1
 docker build . -t $name
 rm $DIR/ansible/Dockerfile 
 echo "VOTRE IMAGE DOCKER : $name est cree"
 echo "Pour l'utiliser : docker run --name <NOM> -d --privileged -ti -e container=docker $name /usr/sbin/init"

}
