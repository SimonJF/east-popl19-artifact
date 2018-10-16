#!/usr/bin/env bash
if [ -z "$LINKS_PORT" ]
then
  LINKS_PORT=8080
fi
docker run -ti -p $LINKS_PORT:8080 --rm links_stwt ./run-example.py
