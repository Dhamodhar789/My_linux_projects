# Service Status & Auto-Notifier (Script 5)

## Overview

service_monitor.sh is a Bash script that continuously monitors specified Linux services, logs their status, optionally restarts stopped services, and sends alerts via console or Slack.
This script is ideal for demonstrating Linux automation, service monitoring, and alerting skills in a portfolio.

## Features

Monitor multiple systemd services continuously.

Warns if a service does not exist.

Logs all service status events to a timestamped log file.

Optionally restarts services that are down.

Sends notifications via:

Console (default)

Slack

(Email notifications can be added if required by client)

Configurable check interval.

## Requirements

Linux system with systemd.

bash shell (tested with Bash ≥ 4).

Optional: Slack webhook URL for Slack notifications.

## Usage
./service_monitor.sh --services=svc1,svc2 [--restart] [--interval=N] [--notify=type] [--help]

## Options
```
Option	    Description
--services	Comma-separated list of systemd services to monitor
--restart	Automatically restart service if it’s not active
--interval	Check interval in seconds (default: 10)
--notify	Notification type: console (default)
--help	    Display usage instructions
```

## Examples

### Monitor ssh and cron services with default settings
./service_monitor.sh --services=ssh,cron

### Monitor nginx service and restart if down
./service_monitor.sh --services=nginx --restart

### Monitor mysql service with Slack notifications
./service_monitor.sh --services=mysql --notify=slack

### Run in background
nohup ./service_monitor.sh --services=ssh,cron --restart & disown

## Logs:

Logs are saved in ./service_logs/service_status.log.

Each log entry is timestamped.

## How it Works

Argument Parsing: Validates CLI arguments.

Service Validation: Checks if services exist; warns and skips invalid ones.

Monitoring Loop: Repeatedly checks service status every interval seconds.

Restart (optional): If --restart is specified, automatically restarts stopped services.

Notifications: Logs events to console or Slack.

Logging: All actions recorded with timestamps for easy tracking.

## Notes

Email notifications are not implemented by default for portfolio purposes but can be added using client SMTP credentials if requested.

Tested on Ubuntu 20.04 LTS / systemd environment.

## License

MIT License — free to use and adapt.