# Dynamic Fan Control Script for Dell R720xd

This script dynamically controls the fans on a Dell R720xd server, prioritizing quiet operation while maintaining optimal cooling. It uses `ipmitool` to adjust fan speeds based on workload and temperature.

## Features
- **Dynamic Fan Speed Adjustment**: Automatically adjusts fan speeds based on system temperature.
- **Quiet Operation**: Starts with a low fan speed and increases only as necessary.
- **Failsafe Mechanism**: Restores dynamic fan control if an error occurs.
- **Configurable**: Easily adjust temperature thresholds, fan speeds, and check intervals.
- **Detailed Logging**: Logs actions, errors, and temperature readings to `/var/log/fan_control.log`.

---

## How to Use

### 1. Prerequisites
- **IPMItool**: Ensure `ipmitool` is installed:
  ```bash
  sudo apt install ipmitool
Root Access: The script requires root privileges to control the server fans.
2. Download the Script
Save the script to /usr/local/bin/fan_control.sh:

bash
Copy code
sudo nano /usr/local/bin/fan_control.sh
Paste the script content and save.

3. Make the Script Executable
bash
Copy code
sudo chmod +x /usr/local/bin/fan_control.sh
4. Run the Script Manually
Start the script manually:

bash
Copy code
sudo /usr/local/bin/fan_control.sh
5. Stop the Script
To stop the script, press CTRL+C. The script will automatically restore dynamic fan control upon exit.

Automate the Script with systemd
1. Create a Systemd Service File
Create a new service file:

bash
Copy code
sudo nano /etc/systemd/system/fan_control.service
Paste the following:

ini
Copy code
[Unit]
Description=Dynamic Fan Control Script
After=network.target

[Service]
ExecStart=/usr/local/bin/fan_control.sh
Restart=always
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
2. Reload and Enable the Service
Reload systemd to recognize the new service:

bash
Copy code
sudo systemctl daemon-reload
sudo systemctl enable fan_control.service
Start the service:

bash
Copy code
sudo systemctl start fan_control.service
3. Verify the Service
Check the service status:

bash
Copy code
sudo systemctl status fan_control.service
Configuration
Adjustable Parameters
You can modify these parameters in the script to suit your needs:

TEMP_CHECK_INTERVAL: Time between temperature checks (default: 30 seconds).
MIN_FAN_SPEED: Minimum fan speed percentage (default: 20%).
MAX_FAN_SPEED: Maximum fan speed percentage (default: 50%).
TEMP_THRESHOLDS: Temperature thresholds for fan speed adjustments.
FAN_SPEEDS: Fan speeds corresponding to the thresholds.
Example
To adjust fan speeds more aggressively, modify:

bash
Copy code
TEMP_THRESHOLDS=(35 45 55 65 75)
FAN_SPEEDS=(20 30 40 50 60)
Logs
The script logs all actions, temperature readings, and errors to:

plaintext
Copy code
/var/log/fan_control.log
To view the logs:

bash
Copy code
tail -f /var/log/fan_control.log
Troubleshooting
Common Issues
ipmitool Command Fails:

Ensure ipmitool is installed and functional:
bash
Copy code
ipmitool sdr
Ensure IPMI is enabled in the BIOS/UEFI.
Service Fails to Start:

Check the service logs:
bash
Copy code
sudo journalctl -u fan_control.service
Fan Speed Fluctuations:

Increase the TEMP_CHECK_INTERVAL or adjust TEMP_THRESHOLDS and FAN_SPEEDS to reduce sensitivity.
License
This script is released under the MIT License.

yaml
Copy code

---

### **How to Use This README**
1. Save the content as `README.md` in your GitHub repository.
2. Commit and push it to your repository:
   ```bash
   git add README.md
   git commit -m "Added README for Dynamic Fan Control Script"
   git push
