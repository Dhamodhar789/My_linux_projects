#!/bin/bash

read -p "Give the directory path eg:/home/xyz: " path

if [ -z "$path" ];then
	echo "Input is empty. Exiting."
	exit 1
fi

if [ -d "$path" ];then
	echo "$path exists. Listing the contents in the path $path below"
	ls -l $path
else
	echo "$path doesn't exist"
fi
