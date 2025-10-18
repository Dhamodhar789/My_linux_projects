# Log Rotation Automation Script

## Overview

This Bash script automates log rotation for a specified directory. It renames and optionally compresses log files when they exceed a specified size and maintains a fixed number of backup files. All actions are logged for easy monitoring.

## Features

Rotates log files based on size

Keeps a configurable number of backups

Optionally compresses rotated logs (gzip)

Logs all script actions with timestamps

Supports CLI arguments for customization

## Usage

./log_rotation.sh [--path=/dir] [--size=5M] [--keep=5] [--compress] [--log=/path/to/script_log] [--help]

### Options

```
Option	    Description	                                Default
--path	    Directory containing log files	            /var/log
--size	    Maximum log size before rotation (e.g., 5M)	5M
--keep	    Number of rotated logs to keep	            5
--compress  Compress rotated files (optional)	        false
--log	    Path for script log file	                /tmp/log_rotation_script.log
--help	    Show usage help	—
```

### Examples

Run with default settings:

./log_rotation.sh


Specify directory, size, backups, and log file:

./log_rotation.sh --path=/tmp/rotation_test --size=10M --keep=3 --log=/tmp/rotation_script.log


Enable compression:

./log_rotation.sh --compress

## Sample Log Output

```
2025-10-18 19:54:09 ==== Log Rotation Script Started ====
2025-10-18 19:54:09 Target Directory: /tmp/rotation_test
2025-10-18 19:54:09 Max Size: 5M
2025-10-18 19:54:09 Max Backups: 3
2025-10-18 19:54:09 Compression: true
2025-10-18 19:54:09 Rotating /tmp/rotation_test/app.log (Size: 10485760 bytes)
2025-10-18 19:54:09 Deleted oldest backup: /tmp/rotation_test/app.log.3
2025-10-18 19:54:09 Renamed /tmp/rotation_test/app.log.2 -> /tmp/rotation_test/app.log.3
2025-10-18 19:54:09 Renamed /tmp/rotation_test/app.log.1 -> /tmp/rotation_test/app.log.2
2025-10-18 19:54:09 Rotated /tmp/rotation_test/app.log to /tmp/rotation_test/app.log.1
2025-10-18 19:54:09 Compressed /tmp/rotation_test/app.log.1 to /tmp/rotation_test/app.log.1.gz
2025-10-18 19:54:09 ==== Rotation Check Completed ====
```