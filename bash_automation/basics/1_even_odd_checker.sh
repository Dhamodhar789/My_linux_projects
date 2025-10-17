#!/bin/bash

read -p "Enter the number: " num
if [ $(( num%2 )) -eq 0 ];then
	echo "$num is an even number"
else
	echo "$num is an odd number"
fi
