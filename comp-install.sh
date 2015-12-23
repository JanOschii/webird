#!/bin/bash

# INSTALL DOCKER-COMPOSE
if ! type "docker-compose" > /dev/null; then
	echo "docker-compose is not installed!"
	exit
else
	echo "docker-compose installed"
fi

# BUILD CONTAINERS
echo "Building containers"
docker-compose build

# RUN CONTAINERS
echo "Running containers"
docker-compose up -d

# NOTICES
echo ""
echo "Set the following hosts in you /etc/hosts file"
echo "{docker-machine-ip} www.test.com"
echo "like:"
echo "192.168.59.103 www.test.com"
echo ""

echo "Happy hunting!"

