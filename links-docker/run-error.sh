#!/usr/bin/env bash
cat examples/caught-errors/$1.links
printf "\n"
printf "Actual output: \n"
./links/links --config=config examples/caught-errors/$1.links
