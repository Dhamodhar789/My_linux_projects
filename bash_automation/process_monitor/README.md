# Process Monitor — Bash Automation Tool

This is a Bash script to monitor system processes or systemd services, restart them automatically if they stop, and log all events with timestamps.
This is a Stage 1 portfolio project focused on advanced Bash scripting, process management, and professional logging.
Slight code tweaks might be required based on different OS depending upon the architecture of the OS.

## Features

Monitor multiple processes or services — supports systemd services and standalone processes

Automatic restart — any stopped process/service is restarted in the background

Logging system — timestamped logs with INFO, SUCCESS, and ERROR messages

Flexible monitoring interval — customizable via CLI argument (--interval)

Built-in help — --help displays usage instructions

Validation — checks if entered processes/services are valid before monitoring

## Usage
./process_monitor.sh --processes "sshd,nginx,sleep" --interval=20


### Optional help:

./process_monitor.sh --help


### Command-line options:

Option	Description
--processes "proc1,proc2,..."	Comma-separated list of processes/services to monitor
--interval=<seconds>	Optional. Monitoring interval in seconds. Default: 30s
-h, --help	Display usage instructions
Example Run
Check the log files in the folder monitor_logs_17_10_2025_18_40_00
ℹ️ INFO: Starting monitoring loop for 3 process(es) every 20 seconds.
✅ SUCCESS: 'sshd' is a valid process or service.
✅ SUCCESS: 'nginx' is a valid process or service.
✅ SUCCESS: 'sleep' is a valid process or command.
ℹ️ INFO: Check if process "sshd" is still running...
ℹ️ INFO: "sshd" is running.
ℹ️ INFO: Check if process "nginx" is still running...
❌ ERROR: "nginx" is not running. Restarting...
✅ SUCCESS: Restarted 'nginx' as a background process (PID: 12345).


Logs are written to:

monitor.log — main monitoring log

error.log — errors during validation or restarts

failure.log — failed restart attempts

valid_processes.log — list of valid processes being monitored

debug.log — internal debugging info

## Learnings & Challenges

- Learnt to log the output based on whether its a success or error or just an info.
- Learnt how to parse CLI arguments given along with the execution of the script and different methods to get CLI inputs like 
    1. --processes "proc1,proc2,..." 
    2. --interval=5
- Tried different logics to validate and restart processes. Faced lot of challenges in coming up with the logics to implement these functions and learnt some new ideas.
- Learnt about some pgrep options and difference between systemd processes and simple command processes.
- Learnt about trap command which can capture signals like CTRL+C and execute the commands given in as arguments.


## Small Intro About Me

This is my second script that can actually solve some more deep real-world problems.

Here I used most of my learnings I got from my first portfolio script and learnt new syntax, shortcuts and bash pattern matching techniques when facing new challenges specific to the user requirements.

Here I went one step deeper into the bash scripting world where I faced lot of challenges and bugs. It took long hours to debug and fix those bugs.

This script have definitely challenged my patience 😂 where I faced unexpected behaviour,unexpected errors and definitely improved my endurance in rootcausing and fixing the errors one by one during messy and overwhelming conditions.

 Short-term goal: Build more advanced Bash scripts and master Linux automation.

 Long-term goal: Solve bigger problems and deploy large-scale Linux projects.
