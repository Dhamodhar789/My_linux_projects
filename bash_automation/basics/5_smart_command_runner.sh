#!/bin/bash

read -p "Enter a command: " com

if [ -z "$com" ];then
	echo "Empty input. Exiting."
	exit 1
fi

$com 2>/dev/null
exit_code=$?
if [ $exit_code -eq 0 ];then
	echo "$com command executed successfully"
else
	echo "$com failed with exit code $exit_code"
fi	
