#!/bin/bash

PROGNAME=$0

# Setup script directory
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD/.."; fi

USER=User
PASSWORD=User
VM=4

usage(){
cat <<EOF
  -h : help
  -u : le User qui sera cree dans les containers, par defaut User (user=User)
  -p : le Password qui sera cree dans les containers, par defaut User (password=User)
  -v : le nombre de container devant simuler les vmX (Si n=4 alors vous aurez :
       1 host + 4 VM
  -e : votre proxy sous la fome "http://nom:password@adresse"
  Exemple: bash $0 -u MonUser -p MonPassword -n 6

EOF
  exit 1
}

while getopts ":h:u:p:v:e:" option; do
  case "${option}" in
    h) 
      usage
    ;;

    u)
      USER=${OPTARG}
    ;;
    p)
      PASSWORD=${OPTARG}
    ;;
    v)
      VM=${OPTARG}
      if ! [ $VM -eq $VM ]; then
        echo "invalid number"
	usage
      fi
    ;;
    e)
      proxy=${OPTARG}
      export http_proxy="$proxy"
      export https_proxy="$proxy"
    ;;

    *)
      usage
    ;;
    esac
done

##################################
#      Setup log directory       #  
##################################

LOGPATH=$DIR/installation/log/
LOGFILE=$DIR/installation/log/installation.log

if [ -f $LOGFILE ]; then
  echo "file exist"
elif [ -d $LOGPATH ]; then
  echo "Directory exists $LOGPATH"
  echo "Creating File"
  touch $LOGFILE
  echo 
else
  mkdir -p $LOGPATH
  touch $LOGFILE
fi

setup() {
 term=$(tty)
 if (( $? != 0 ))
 then
  exec 1<&-
  exec 2<&-
  exec 1<> $LOGFILE
  exec 2>&1
  echo "Script is not executed from a terminal"
 else
  exec 1<> $LOGFILE
  exec 2>&1
  tail --pid $$ -f $LOGFILE >> $term & echo "Script is executed from a terminal"
 fi
}


######################################
#             Fonctions              #
######################################

if [ -d $DIR/ansible/ ]; then
  echo "Directory exists $DIR/ansible"
else
  echo "Creating directory $DIR/ansible"
  mkdir -p $DIR/ansible/
fi

source $DIR/installation/ressources/compose/compose.sh
source $DIR/installation/ressources/container/container.sh
source $DIR/installation/ressources/docker/docker.sh
source $DIR/installation/information/infos.sh

setup echo "Installation et configuration de l'environnement Ansible"

#installPrerequired 
#installDocker
#addUserToGroupDocker
#installDockerCompose
#loginToDockerHub

# Create centos container with systemd
createDockerfileCentosSystemd
buildContainer centos-systemd

# Create centos container with ssh
createDockerfileSshCentos
buildContainer ssh-centos

# Create centos container with ansible
createContainerAnsible ansible-centos
buildContainer ansible-centos

prepareEnvironementTest $VM
startEnvironementTest
howTo
