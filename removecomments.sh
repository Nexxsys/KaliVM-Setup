#!/bin/bash

args=("$@")
# echo ${args[0]}
sudo sed -i 's/^\#.*$//g' ${args[0]} && sudo sed -i '/^$/d' ${args[0]}