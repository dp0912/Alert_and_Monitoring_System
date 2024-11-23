# Multi-Sensor Data Logging and Alert System

## Overview
This project is a multi-sensor data logging and alert system designed to monitor environmental conditions in real-time. It uses an **Arduino Mega** to collect data from an **LDR**, **sound sensor**, and **ultrasonic sensor**. The data is processed, validated, and stored in an SQLite database using Bash scripts. When thresholds are exceeded, SMS alerts are sent via the Twilio API.

---

## Features
- Real-time monitoring of light, sound, and distance values.
- Automatic data logging to `data.log` and error logging to `error.log`.
- Threshold-based alerts with notifications sent via SMS.
- SQLite database integration for storing validated sensor data.
- Modular design for easy scalability and customization.

---

## Requirements

### Hardware
- Arduino Mega 2560
- Ultrasonic Sensor (HC-SR04)
- LDR Sensor (with a voltage divider circuit)
- Sound Sensor
- Breadboard, jumper wires, and power supply

### Software
- Arduino IDE (Version 1.8+)
- Bash (Pre-installed on most Linux/macOS systems)
- SQLite (Version 3.0+)
- Twilio API (Account required for SMS functionality)
- GNU Make (for automation)

---

## Installation

### Arduino Setup
1. Clone this repository:
   ```bash
   git clone https://github.com/dp0912/Alert_and_Monitoring_System.git
