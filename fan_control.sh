#!/bin/bash

# Configurable Parameters
LOG_FILE="/var/log/fan_control.log" # Log file location
TEMP_CHECK_INTERVAL=30             # Time (in seconds) between temperature checks
MIN_FAN_SPEED=20                   # Minimum fan speed (%)
MAX_FAN_SPEED=50                   # Maximum fan speed (%)
TEMP_THRESHOLDS=(40 50 60 70 80)   # Temperature thresholds (°C)
FAN_SPEEDS=(20 25 30 40 50)        # Corresponding fan speeds (%)

# Function to log messages
log() {
  echo "$(date): $1" | tee -a "$LOG_FILE"
}

# Function to restore dynamic fan control
restore_dynamic_control() {
  log "Restoring dynamic fan control..."
  ipmitool raw 0x30 0x30 0x01 0x01 2>&1 | tee -a "$LOG_FILE"
  if [ $? -ne 0 ]; then
    log "Failed to restore dynamic fan control!"
  fi
}

# Function to set fan speed
set_fan_speed() {
  local speed=$1
  local hex_speed=$(printf "%x" "$speed")

  log "Disabling dynamic fan control..."
  ipmitool raw 0x30 0x30 0x01 0x00 2>&1 | tee -a "$LOG_FILE"
  if [ $? -ne 0 ]; then
    log "Failed to disable dynamic fan control!"
    restore_dynamic_control
    exit 1
  fi

  log "Setting fan speed to $speed% (0x$hex_speed)..."
  ipmitool raw 0x30 0x30 0x02 0xff 0x$hex_speed 2>&1 | tee -a "$LOG_FILE"
  if [ $? -ne 0 ]; then
    log "Failed to set fan speed to $speed%!"
    restore_dynamic_control
    exit 1
  fi
}

# Function to get the highest temperature
get_highest_temperature() {
  local temp=$(ipmitool sdr type temperature | grep -i "temp" | awk -F'|' '{print $5}' | awk '{print $1}' | sort -nr | head -n 1)
  if ! [[ "$temp" =~ ^[0-9]+$ ]]; then
    log "Failed to read temperature. Restoring dynamic fan control."
    restore_dynamic_control
    exit 1
  fi
  echo "$temp"
}

# Main control loop
log "Starting dynamic fan control script..."
trap restore_dynamic_control EXIT  # Ensure dynamic control is restored on exit

while :; do
  # Get the highest temperature
  highest_temp=$(get_highest_temperature)
  log "Highest temperature detected: ${highest_temp}°C"

  # Determine the appropriate fan speed
  fan_speed=$MIN_FAN_SPEED
  for i in "${!TEMP_THRESHOLDS[@]}"; do
    if (( highest_temp >= TEMP_THRESHOLDS[i] )); then
      fan_speed=${FAN_SPEEDS[i]}
    fi
  done

  # Set the fan speed
  set_fan_speed "$fan_speed"

  log "Fan speed set to $fan_speed%. Sleeping for $TEMP_CHECK_INTERVAL seconds..."
  sleep "$TEMP_CHECK_INTERVAL"
done
