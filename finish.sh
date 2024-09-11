#!/bin/bash
# Created based on the teachings of John Hammond
# This will mark your directory as _COMPLETED for
# any CTF folder you are presently in on you machine
original_directory=$(pwd)

# echo $original_directory

cd ..

mv $original_directory ${original_directory}_COMPLETED
