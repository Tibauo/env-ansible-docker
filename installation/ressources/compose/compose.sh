prepareEnvironementTest(){

local nbvm=$1

if [ -f $DIR/ansible/docker-compose.yml ]; then
  rm -f $DIR/ansible/docker-compose.yml
fi
cat > $DIR/ansible/docker-compose.yml <<EOF
version: '2'

# defie services
services:
  mamachine:
    image: ansible-centos
    links:
EOF
for i in $( seq 1 $nbvm ); do
echo "      - vm$i" >> $DIR/ansible/docker-compose.yml
done
echo -e "    privileged: true
    hostname: mamachine
    stdin_open: true
    tty: true
    entrypoint: /usr/sbin/init
    container_name: mamachine" >> $DIR/ansible/docker-compose.yml
for i in $( seq 1 $nbvm ); do
echo -e "  vm$i:
    image: ansible-centos
    privileged: true
    stdin_open: true
    hostname: vm$i
    tty: true
    entrypoint: /usr/sbin/init
    container_name: vm$i">> $DIR/ansible/docker-compose.yml
done;
}

startEnvironementTest(){
  cd $DIR/ansible/ 
  docker-compose up -d
}
