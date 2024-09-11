#!/bin/bash
# Removes comments from the top of files like those from exploitdb
args=("$@")
# echo ${args[0]}
sudo sed -i 's/^\#.*$//g' ${args[0]} && sudo sed -i '/^$/d' ${args[0]}
