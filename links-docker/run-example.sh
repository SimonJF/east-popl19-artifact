#!/usr/bin/env bash
cat examples/paper-examples/$1.links
printf "\n"
printf "Actual output: \n"
./links/links --config=config examples/paper-examples/$1.links
