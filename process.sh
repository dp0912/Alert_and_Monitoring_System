#!/bin/bash
# Data Processing Script
# Parses sensor data, checks thresholds, logs results, and triggers alerts.

# Threshold values for sensors
LDR_THRESHOLD_LOW=300
LDR_THRESHOLD_HIGH=900
SOUND_THRESHOLD=50
DISTANCE_THRESHOLD=10

# Database and log file configuration
DB_FILE="sensor_data.db"
LOG_FILE="data.log"

# Twilio SMS alert configuration (replace with your credentials)
TWILIO_ACCOUNT_SID="your_account_sid"
TWILIO_AUTH_TOKEN="your_auth_token"
TWILIO_PHONE_NUMBER="+1XXXXXXXXXX"
RECIPIENT_PHONE_NUMBER="+1XXXXXXXXXX"

# Generate a session table name for this run
SESSION_NUMBER=$(sqlite3 "$DB_FILE" "SELECT IFNULL(MAX(CAST(SUBSTR(name, 8) AS INTEGER)), 0) + 1 FROM sqlite_master WHERE type='table' AND name LIKE 'session%';")
TABLE_NAME="session$SESSION_NUMBER"

# Ensure the database exists; create it if necessary
if [[ ! -f "$DB_FILE" ]]; then
    sqlite3 "$DB_FILE" "VACUUM;"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create database $DB_FILE." >> error.log
        exit 1
    fi
fi

# Create a new table for this session
sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS $TABLE_NAME (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ldr INTEGER NOT NULL,
    sound INTEGER NOT NULL,
    distance REAL NOT NULL,
    alert_sent INTEGER NOT NULL DEFAULT 0,
    alert_sent_for TEXT DEFAULT NULL,
    timestamp TEXT NOT NULL
);
EOF

# Tail the log file and process each line
tail -F "$LOG_FILE" | while read -r line; do
    # Parse valid log entries
    if [[ $line =~ LDR=([0-9]+),Sound=([0-9]+),Distance=([0-9.]+) ]]; then
        LDR=${BASH_REMATCH[1]}
        SOUND=${BASH_REMATCH[2]}
        DISTANCE=${BASH_REMATCH[3]}
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        ALERT_SENT=0
        ALERT_SENT_FOR=""

        # Check thresholds and prepare alerts
        if (( $LDR < $LDR_THRESHOLD_LOW || $LDR > $LDR_THRESHOLD_HIGH )); then ALERT_SENT=1; ALERT_SENT_FOR+="LDR,"; fi
        if (( $SOUND > $SOUND_THRESHOLD )); then ALERT_SENT=1; ALERT_SENT_FOR+="Sound,"; fi
        if (( $(echo "$DISTANCE < $DISTANCE_THRESHOLD" | bc -l) )); then ALERT_SENT=1; ALERT_SENT_FOR+="Distance,"; fi

        ALERT_SENT_FOR=${ALERT_SENT_FOR%,}  # Remove trailing comma

        # Trigger SMS alert if necessary
        if [[ $ALERT_SENT -eq 1 ]]; then
            curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json" \
                --data-urlencode "Body=Alert! Issue with $ALERT_SENT_FOR. LDR=$LDR, Sound=$SOUND, Distance=$DISTANCE" \
                --data-urlencode "From=$TWILIO_PHONE_NUMBER" \
                --data-urlencode "To=$RECIPIENT_PHONE_NUMBER" \
                -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN" >/dev/null 2>&1
        fi

        # Log data into the database
        sqlite3 "$DB_FILE" <<EOF
INSERT INTO $TABLE_NAME (ldr, sound, distance, alert_sent, alert_sent_for, timestamp)
VALUES ($LDR, $SOUND, $DISTANCE, $ALERT_SENT, '$ALERT_SENT_FOR', '$TIMESTAMP');
EOF
    else
        echo "Invalid log entry: $line" >> error.log
    fi
done
