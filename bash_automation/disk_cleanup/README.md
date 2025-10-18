# Disk Usage & Cleanup Automation Script

## Overview

This Bash script helps monitor disk usage, list the top 10 largest files, and delete old files from specified directories.
It supports both interactive and automatic cleanup modes and logs all actions with timestamps.

## Features

- Displays current disk usage in human-readable format

- Lists top 10 largest files in each target directory

- Deletes files older than N days (interactive confirmation)

- Logs every action with timestamps to a log file

- Supports CLI arguments for custom paths, days, and log location

## Usage
./disk_cleanup.sh [--path=/dir1,/dir2] [--days=N] [--log=/path/to/logfile] [--help]

### Options:
Option	Description	Default
--path	Comma-separated directories to scan	/tmp,/var/log
--days	Delete files older than N days	30
--log	Log file path	/tmp/disk_cleanup.log
--help	Show usage help	—

#### Examples

1. Run with default settings:

./disk_cleanup.sh

2. Specify directories and log file:

./disk_cleanup.sh --path=/tmp,/home/user/logs --days=7 --log=/var/log/my_cleanup.log

## Sample Log Output

```
2025-10-18 07:10:17 ==== Disk Usage & Cleanup Script Started ====
2025-10-18 07:10:17 Current Disk Usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   20G   28G  42% /
...
2025-10-18 07:10:17 Top 10 largest files in /tmp:
200M    /tmp/large_file.log
...
2025-10-18 07:10:17 Deleted: /tmp/old1.log
2025-10-18 07:10:17 Skipped: /tmp/old2.log
2025-10-18 07:10:17 ==== Script Completed ====

```