#!/bin/bash

docker run \
	--name webirdc \
	-p 8080:80 \
	-p 443:443 \
	-p 8091:8091 \
	-p 8092:8092 \
	-p 8192:8192 \
	--tty=true \
	-d webird


