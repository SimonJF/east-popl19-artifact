#!/usr/bin/env bash
docker ps -a | awk '{ print $1,$2 }' | grep links_stwt | awk '{print $1 }' | xargs -I {} docker rm {}
docker rmi links_stwt
