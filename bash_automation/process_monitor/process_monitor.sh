#!/bin/bash
#===============================================================================
# Script Name : process_monitor.sh
# Description : Monitors a list of systemd services or processes, restarts them
#               if they stop, and logs all events to timestamped log files.
#
# Usage       : ./process_monitor.sh --processes "sshd,nginx,sleep" --interval=20
#
# Author      : Dhamodhar R V
# Version     : 1.0
# Date        : 16-10-2025
#===============================================================================

show_help()
{
	cat << EOF
***************************************************************************
Usage: $0 [OPTIONS]

Options:
--processes "proc1,proc2,..."    Comma-separated list of process names or services to monitor
--interval=<seconds>              Optional. Monitoring interval. Default: 30 seconds
-h, --help                        Show this help message

Example:
$0 --processes "sshd,nginx" --interval=20

***************************************************************************
EOF
}

# Timestamped logging with emojis :)
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

error() {
    log "❌ ERROR: $1" | tee -a "$error_log" > /dev/null
}

success() {
    log "✅ SUCCESS: $1" | tee -a "$monitor_log" > /dev/null
}

info() {
    log "ℹ️ INFO: $1" | tee -a "$monitor_log" > /dev/null
}

validate_process() {
    local proc="$1"

    # Check if it's a systemctl service
    if systemctl list-units --type=service | grep -q "${proc}.service"; then
        success "'$proc' is a valid systemd service."
        return 0
    fi

    # Check if it's a valid process or executable command
    if pgrep -x "$proc" >/dev/null 2>&1 || command -v "$proc" >/dev/null 2>&1; then
        success "'$proc' is a valid process or command."
        return 0
    fi

    error "'$proc' is not a valid service or command."
    return 1
}

restart_process() {
    local proc="$1"

    if systemctl list-units --type=service | grep -q "${proc}.service"; then
        systemctl restart "$proc"
        if [ $? -eq 0 ]; then
            success "Restarted '$proc' via systemctl."
        else
            error "Failed to restart '$proc' via systemctl."
            return 1
        fi
    else
		"$proc" >/dev/null 2>&1 &
		local pid=$!
		if pgrep -x "$proc" >/dev/null 2>&1; then
			disown
			success "Restarted '$proc' as a background process (PID: $pid)."
		else
			error "Failed to restart '$proc'."
			return 1
		fi
    fi
    return 0
}

main()
{
	log "****Validating the processes entered by the user: $process_values****" > $debug
	valid_processes=()
	for p in "${process_array[@]}";do
		log "Validating process: $p" >> $debug
		if validate_process "$p"; then
        	valid_processes+=("$p")
			log "✅ $p is a valid process" >> $debug
    	else
        	log "⚠️ Skipping invalid process: $p" >> $debug
    	fi
	done
	
	if [[ ${#valid_processes[@]} -eq 0 ]];then
		echo "⚠️ No valid processes to monitor. Exiting." > $valid_process_list
		exit 1
	else
		count=1
		echo "Below valid processes are going to be monitored in the interval of $check_frequency" > $valid_process_list
		for p in "${valid_processes[@]}";do 
			echo "$count. $p" >> $valid_process_list
			((count++))
		done
	fi

	info "Starting monitoring loop for ${#valid_processes[@]} processes every $check_frequency seconds."

	while true; do
		for p in "${valid_processes[@]}"; do
			info "Check if process \"$p\" is still running..."
			if pgrep -x "$p" > /dev/null; then
				info "\"$p\" is running."
			else
				log "\"$p\" is not running. Restarting..." | tee -a $monitor_log $failure_log > /dev/null
				restart_process "$p"
				if [ $? -ne 0 ]; then
					info "Couldn't restart $p. Skipping this process in upcoming iterations."
					valid_processes=($(printf "%s\n" "${valid_processes[@]}" | grep -v "^$p$"))
					if [[ ${#valid_processes[@]} -gt 0 ]]; then
						info "After removing $p, remaining valid processes: ${valid_processes[*]}"
					else
						echo "⚠️ No valid processes to monitor. Exiting." >> $valid_process_list
						exit 1
					fi
				fi
			fi
		done
		sleep $check_frequency
	done
}

# ---------------- Command-line argument parsing ----------------
while [[ $# -gt 0 ]]; do
	case "$1" in
		--processes)
			process_values=$2
			shift 2
			;;
		--interval=*)
			check_frequency="${1#*=}"
			shift
			;;
		-h|--help)
			show_help
			exit 0
			;;
		*)
			echo "Invalid option $1"
			show_help
			exit 1
			;;
	esac
done

IFS=',' read -r -a process_array <<< "$process_values"
if [ -z "$check_frequency" ]; then
	check_frequency=30
fi

# ---------------- Initialize log folder & files ----------------
LOG_DIR="monitor_logs_$(date +"%d_%m_%Y_%H_%M_%S")"
mkdir -p "$LOG_DIR"
cd "$LOG_DIR" || exit 1

monitor_log="monitor.log"
error_log="error.log"
failure_log="failure.log"
valid_process_list="valid_processes.log"
debug="debug.log"

echo "Check the log files in the folder $LOG_DIR"
trap 'echo "🧹 Cleaning up and exiting..."; cd - >/dev/null' EXIT

# ---------------- Start monitoring ----------------
main
