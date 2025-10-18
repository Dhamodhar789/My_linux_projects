#!/bin/bash
# =============================================
# Disk Usage & Cleanup Automation Script
# Author: Dhamodhar R V
# Description: Monitors disk usage, lists largest files,
#              deletes old files in specified directories,
#              and logs summary of actions.
# =============================================

# -------- Color codes for output --------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# -------- Default values --------
PATHS=("/tmp" "/var/log")
DAYS=30
LOG_FILE="/tmp/disk_cleanup.log"

# -------- Functions --------
usage() {
    echo -e "${GREEN}Usage:${NC} $0 [--path=/dir1,/dir2] [--days=N] [--log=/path/to/logfile] [--help]"
    echo -e "  --path    Comma-separated directories to check (default: /tmp,/var/log)"
    echo -e "  --days    Delete files older than N days (default: 30)"
    echo -e "  --log     Log file path (default: /tmp/disk_cleanup.log)"
    echo -e "  --help    Show this help message"
}

log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# -------- Parse CLI arguments --------
for arg in "$@"; do
    case $arg in
        --path=*)
            IFS=',' read -r -a PATHS <<< "${arg#*=}"
            shift
            ;;
        --days=*)
            DAYS="${arg#*=}"
            shift
            ;;
        --log=*)
            LOG_FILE="${arg#*=}"
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            usage
            exit 1
            ;;
    esac
done

# -------- Main script --------
log "${YELLOW}==== Disk Usage & Cleanup Script Started ====${NC}"

# Display disk usage
log "${GREEN}Current Disk Usage:${NC}"
df -h | tee -a "$LOG_FILE"

# List top 10 largest files in each directory
for dir in "${PATHS[@]}"; do
    if [[ -d "$dir" ]]; then
        log "${GREEN}Top 10 largest files in $dir:${NC}"
        find "$dir" -type f -exec du -h {} + 2>/dev/null | sort -hr | head -n 10 | tee -a "$LOG_FILE"
    else
        log "${RED}Directory $dir does not exist. Skipping.${NC}"
    fi
done

# Delete files older than $DAYS in specified paths (interactive)
for dir in "${PATHS[@]}"; do
    if [[ -d "$dir" ]]; then
        old_files=$(find "$dir" -type f -mtime +"$DAYS" 2>/dev/null)
        if [[ -n "$old_files" ]]; then
            log "${YELLOW}Found files older than $DAYS days in $dir:${NC}"
            echo "$old_files"
            echo
            read -rp "Do you want to delete all these files? (y/n) " delete_all
            if [[ "$delete_all" == "y" || "$delete_all" == "Y" ]]; then
                while IFS= read -r file; do
                    if rm -f "$file"; then
                        log "${GREEN}Deleted: $file${NC}"
                    else
                        log "${RED}Failed to delete: $file${NC}"
                    fi
                done <<< "$old_files"
            else
                while IFS= read -r file; do
                    read -rp "Delete $file? (y/n) " answer < /dev/tty
                    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
                        if rm -f "$file"; then
                            log "${GREEN}Deleted: $file${NC}"
                        else
                            log "${RED}Failed to delete: $file${NC}"
                        fi
                    else
                        log "${YELLOW}Skipped: $file${NC}"
                    fi
                done <<< "$old_files"
            fi
        else
            log "${GREEN}No files older than $DAYS days in $dir${NC}"
        fi
    else
        log "${RED}Directory $dir does not exist. Skipping.${NC}"
    fi
done

log "${YELLOW}==== Script Completed ====${NC}"
