#!/bin/bash

echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
#up_time=$(uptime |awk '{print $3}')
echo "Uptime: $(uptime -p)"
