#!/bin/bash
#===============================================================================
# Script Name : menu_script.sh
# Description : Displays a list of options and performs the corresponding action.
# Usage       : ./menu_script.sh [--help]
# Author      : Dhamodhar R V
# Version     : 1.0
# Date        : 16-10-2025
#===============================================================================

#-----------------------------------------------
# Functions: Common Validations
#-----------------------------------------------

# Check if variable is empty
empty_variable_check() {
    if [ -z "$1" ]; then
        return 1
    fi
    return 0
}

# Check if array is empty
empty_array_check() {
    if [ $# -eq 0 ]; then
        return 1
    fi
    return 0
}

# Check if directory exists
directory_exists_check() {
    if [ -d "$1" ]; then
        return 0
    fi
    return 1
}

#-----------------------------------------------
# Display and Help
#-----------------------------------------------

display() {
    echo
    echo "********************************"
    printf "1) Show system info\n2) Monitor processes\n3) Disk usage report\n4) Cleanup temp files\n5) Exit\n"
    echo "********************************"
    echo
}

show_help() {
    cat <<EOF
Usage: ./menu_script.sh [OPTIONS]

Options:
  --help        Show this help message and exit.

Menu Options:
  1) Show system info
  2) Monitor processes
  3) Disk usage report
  4) Cleanup temp files
  5) Exit
EOF
}

#-----------------------------------------------
# Option 1: Show system info
#-----------------------------------------------

sys_info() {
    echo "############## SYSTEM INFORMATION ##############"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    up_time=$(uptime -p 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "Uptime: $up_time"
    else
        echo "❌ Uptime command not working!"
    fi
}

#-----------------------------------------------
# Option 2: Monitor processes
#-----------------------------------------------

monitor_processes() {
    echo "############## MONITOR PROCESSES ###############"
    read -a processes -p "Enter the processes separated by spaces: "
    empty_array_check "${processes[@]}"
    if [ $? -eq 1 ]; then
        echo "❌ Empty input. Exiting."
        return
    fi

    for proc in "${processes[@]}"; do
        echo "Checking process: $proc"
        if pgrep -f "$proc" > /dev/null; then
            echo "✅ $proc is running"
        else
            echo "❌ $proc is not running"
        fi
    done
}

#-----------------------------------------------
# Option 3: Disk usage report
#-----------------------------------------------

disk_usage_report() {
    echo "############## DISK USAGE REPORT ###############"
    read -p "Enter the directory path: " path
    empty_variable_check "$path" || { echo "❌ Empty input. Exiting."; return; }
    directory_exists_check "$path" || { echo "❌ Directory '$path' does not exist."; return; }

    echo "Disk space of '$path': $(du -sh "$path" 2>/dev/null | awk '{print $1}')"
}

#-----------------------------------------------
# Option 4: Cleanup temp files
#-----------------------------------------------

cleanup_temp() {
    echo "############## CLEANUP TEMP FILES ##############"
    read -p "Enter the directory path: " path
    empty_variable_check "$path" || { echo "❌ Empty input. Exiting."; return; }
    directory_exists_check "$path" || { echo "❌ '$path' doesn't exist. Exiting."; return; }

    tmp_file_list=($(find "$path" -maxdepth 1 -name "*.tmp" -printf "%f\n"))
    echo "Listing the tmp files in '$path':"
    printf "%s\n" "${tmp_file_list[@]}"

    if [ ${#tmp_file_list[@]} -eq 0 ]; then
        echo "⚠️ No tmp files in '$path'."
        return
    fi

    read -p "Do you want to delete them (y/n)? " yes_or_no
    if [ "$yes_or_no" = "y" ]; then
        cd "$path" || return
        for tmp in "${tmp_file_list[@]}"; do
            if [ "$tmp" = "important.tmp" ]; then
                echo "⚠️ Skipping important.tmp"
            else
                rm -f "$tmp"
            fi
        done
        cd - > /dev/null
    fi
}

#-----------------------------------------------
# Main function
#-----------------------------------------------

main_func() {
    case "$1" in
        1) sys_info ;;
        2) monitor_processes ;;
        3) disk_usage_report ;;
        4) cleanup_temp ;;
        5 | q | Q)
            echo "Exiting 👍."
            exit 0
            ;;
        *) echo "❌ Invalid option" ;;
    esac
}

#-----------------------------------------------
# Entry point
#-----------------------------------------------

if [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

option=6
while [ "$option" -ne 5 ]; do
    display
    unset option
    read -p "Enter any number between 1 to 5 based on above options: " option
    echo
    if [ -z "$option" ]; then
        echo "❌ Empty input..."
        option=7
        continue
    fi
    main_func "$option"
    echo -e "\n✅ Task completed. Returning to menu..."
done
