#!/bin/bash

PROGNAME=$0

# Setup script directory
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD/.."; fi

cd $DIR/ansible
docker-compose down
rm docker-compose.yml
docker rm $(docker ps -a -q)
docker rmi $(docker images -a -q)
