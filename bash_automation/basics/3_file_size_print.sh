#!/bin/bash

read -p "Enter file path: " path
if [ -z "$path" ];then
	echo "Empty input. Exiting."
	exit 1
fi

if [ -f "$path" ];then
	echo "$path file exists.The file size in bytes is given below"
	stat -c%s "$path"
else
	echo "$path file doesn't exist"
fi
