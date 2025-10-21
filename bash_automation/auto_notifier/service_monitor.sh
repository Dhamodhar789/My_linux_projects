#!/bin/bash
# ===================================================
# Script 5: Service Status & Auto-Notifier (v2)
# Monitors specified Linux services continuously,
# logs their status, restarts if required,
# and sends notifications on failure.
# ===================================================

LOG_DIR="./service_logs"
LOG_FILE="$LOG_DIR/service_status.log"
SERVICES=()
RESTART=false
INTERVAL=10
NOTIFY_TYPE="console"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXX/XXXX/XXXX"  # placeholder can be replaced with original webhook URL

# Color codes
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

usage() {
    echo "Usage: $0 --services=svc1,svc2 [--restart] [--interval=N] [--notify=type] [--help]"
    echo ""
    echo "Options:"
    echo "  --services    Comma-separated list of systemd services to monitor"
    echo "  --restart     Automatically restart service if it's not active"
    echo "  --interval    Check interval in seconds (default: 10)"
    echo "  --notify      Notification type: console | email | slack (default: console)"
    echo "  --help        Display this help message"
    echo ""
    echo "Examples:"
    echo "  nohup $0 --services=ssh,cron --restart & disown"
    echo "  $0 --services=nginx --notify=email"
    echo "  $0 --services=mysql --notify=slack"
}

log() {
    local msg="$1"
    mkdir -p "$LOG_DIR"
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $msg" | tee -a "$LOG_FILE" > /dev/null
}

send_notification() {
    local svc="$1"
    local msg="🚨 ALERT: Service '$svc' is DOWN on $(hostname) at $(date)"

    case "$NOTIFY_TYPE" in
        console)
            log "Notification (console): $msg"
            ;;
        email)
            # mail id can be replaced in place of admin@example.com
            echo "$msg" | mail -s "Service Alert: $svc" thamodharan789@gmail.com
            log "Notification (email) sent for '$svc'."
            ;;
        slack)
            curl -s -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$msg\"}" \
            "$SLACK_WEBHOOK_URL" >/dev/null
            log "Notification (Slack) sent for '$svc'."
            ;;
        *)
            log "Unknown notification type '$NOTIFY_TYPE'. Defaulting to console."
            log "Notification (console): $msg"
            ;;
    esac
}

validate_services() {
    local valid_services=()
    for svc in "${SERVICES[@]}"; do
        if systemctl list-unit-files | grep -q "^${svc}.service"; then
            valid_services+=("$svc")
        else
            echo -e "${YELLOW}[WARN]${RESET} Service '${svc}' does not exist."
            log "WARN: Service '${svc}' does not exist."
        fi
    done

    # Replace SERVICES array with only valid ones
    SERVICES=("${valid_services[@]}")

    if [ ${#SERVICES[@]} -eq 0 ]; then
        echo -e "${RED}[ERROR]${RESET} No valid services found. Exiting..."
        log "ERROR: No valid services found. Exiting script."
        exit 1
    fi
}

check_service() {
    local svc="$1"

    # Check if service exists
    if ! systemctl list-unit-files | grep -q "^${svc}.service"; then
        echo -e "${YELLOW}[WARN]${RESET} Service '${svc}' does not exist."
        log "WARN: Service '${svc}' does not exist."
        return
    fi

    # Check if service is active
    if systemctl is-active --quiet "$svc"; then
        echo -e "${GREEN}[OK]${RESET} Service '$svc' is running."
        log "Service '$svc' is running."
    else
        echo -e "${RED}[DOWN]${RESET} Service '$svc' is NOT running!"
        log "ALERT: Service '$svc' is NOT running!"
        if $RESTART; then
            systemctl restart "$svc"
            sleep 2
            if systemctl is-active --quiet "$svc"; then
                echo -e "${GREEN}[RESTARTED]${RESET} Service '$svc' restarted successfully."
                log "Service '$svc' restarted successfully."
            else
                echo -e "${RED}[FAILED]${RESET} Restart failed for '$svc'."
                log "Failed to restart service '$svc'."
            fi
        fi
        send_notification "$svc"
    fi
}

parse_args() {
    for arg in "$@"; do
        case $arg in
            --services=*)
                IFS=',' read -r -a SERVICES <<< "${arg#*=}"
                ;;
            --restart)
                RESTART=true
                ;;
            --interval=*)
                INTERVAL="${arg#*=}"
                ;;
            --notify=*)
                NOTIFY_TYPE="${arg#*=}"
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $arg"
                usage
                exit 1
                ;;
        esac
    done

    if [ ${#SERVICES[@]} -eq 0 ]; then
        echo "Error: No services specified."
        usage
        exit 1
    fi
}

# -------------------------------
# Main Script
# -------------------------------
parse_args "$@"
validate_services
log "==== Starting Service Monitor ===="
echo "Monitoring services: ${SERVICES[*]}"
echo "Interval: ${INTERVAL}s | Restart: $RESTART | Notify: $NOTIFY_TYPE"
echo "Logs: $LOG_FILE"

while true; do
    for svc in "${SERVICES[@]}"; do
        check_service "$svc"
    done
    sleep "$INTERVAL"
done
