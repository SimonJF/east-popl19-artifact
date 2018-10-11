#!/bin/bash

if [ ! "$(docker images links_stwt | grep links_stwt )" ]; then
	docker build -t links_stwt links-docker
fi
