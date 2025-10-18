#!/bin/bash
# =============================================
# Log Rotation Automation Script
# Author: Dhamodhar R V
# Description: Rotates log files in a directory
#              based on size and keeps a fixed
#              number of backups. Supports compression.
# =============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TARGET_DIR="/var/log"
MAX_SIZE="5M"
MAX_BACKUPS=5
COMPRESS=false
SCRIPT_LOG="/tmp/log_rotation_script.log"

usage() {
    echo -e "${GREEN}Usage:${NC} $0 [--path=/dir] [--size=5M] [--keep=5] [--compress] [--log=/path/to/script_log]"
    echo -e "  --path       Directory containing log files (default: /var/log)"
    echo -e "  --size       Max log size before rotation (e.g., 5M)"
    echo -e "  --keep       Number of rotated logs to keep (default: 5)"
    echo -e "  --compress   Compress rotated files (optional)"
    echo -e "  --log        Log file path for script actions (default: /tmp/log_rotation_script.log)"
    echo -e "  --help       Show this help message"
}

log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$SCRIPT_LOG"
}

size_to_bytes() {
    local size="$1"
    local num="${size%[KMG]}"
    local unit="${size##*[0-9]}"
    case "$unit" in
        K|k) echo $((num * 1024));;
        M|m) echo $((num * 1024 * 1024));;
        G|g) echo $((num * 1024 * 1024 * 1024));;
        *) echo "$num";;
    esac
}

# -------- Parse CLI arguments --------
for arg in "$@"; do
    case $arg in
        --path=*) TARGET_DIR="${arg#*=}"; shift;;
        --size=*) MAX_SIZE="${arg#*=}"; shift;;
        --keep=*) MAX_BACKUPS="${arg#*=}"; shift;;
        --compress) COMPRESS=true; shift;;
        --log=*) SCRIPT_LOG="${arg#*=}"; shift;;
        --help) usage; exit 0;;
        *) echo -e "${RED}Unknown option: $arg${NC}"; usage; exit 1;;
    esac
done

if [[ ! -d "$TARGET_DIR" ]]; then
    log "${RED}Error: Target directory '$TARGET_DIR' does not exist.${NC}"
    exit 1
fi

log "${YELLOW}==== Log Rotation Script Started ====${NC}"
log "Target Directory: $TARGET_DIR"
log "Max Size: $MAX_SIZE"
log "Max Backups: $MAX_BACKUPS"
log "Compression: $COMPRESS"
log "Script Log: $SCRIPT_LOG"

THRESHOLD=$(size_to_bytes "$MAX_SIZE")

for logfile in "$TARGET_DIR"/*.log; do
    [[ -f "$logfile" ]] || continue

    filesize=$(stat -c%s "$logfile")
    if (( filesize > THRESHOLD )); then
        log "${YELLOW}Rotating $logfile (Size: $filesize bytes)${NC}"

        # Shift backups from MAX_BACKUPS down to 1
        for (( i=MAX_BACKUPS; i>=1; i-- )); do
            # Check for both plain and compressed backups
            for ext in "" ".gz"; do
                oldfile="${logfile}.${i}${ext}"
                if [[ -f "$oldfile" ]]; then
                    if (( i == MAX_BACKUPS )); then
                        rm -f "$oldfile"
                        log "${RED}Deleted oldest backup: $oldfile${NC}"
                    else
                        mv "$oldfile" "${logfile}.$((i+1))${ext}"
                        log "Renamed $oldfile -> ${logfile}.$((i+1))${ext}"
                    fi
                fi
            done
        done

        # Rotate current log
        mv "$logfile" "${logfile}.1"
        touch "$logfile"
        log "${GREEN}Rotated $logfile to ${logfile}.1${NC}"

        # Compress if required
        if $COMPRESS; then
            gzip -f "${logfile}.1"
            log "${GREEN}Compressed ${logfile}.1 to ${logfile}.1.gz${NC}"
        fi
    fi
done

log "${YELLOW}==== Rotation Check Completed ====${NC}"
