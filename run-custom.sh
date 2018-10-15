#!/usr/bin/env bash
docker run -ti -p 8080:8080 -v `pwd`/custom-examples:/home/opam/custom-examples links_stwt ./links/links --config=config custom-examples/$@
