// Pin Definitions for Arduino Mega
const int LDR_PIN = A0;         // LDR connected to Analog Pin A0
const int SOUND_PIN = A1;       // Sound sensor connected to Analog Pin A1
const int TRIG_PIN = 2;         // Ultrasonic sensor TRIG pin connected to Digital Pin 2
const int ECHO_PIN = 4;         // Ultrasonic sensor ECHO pin connected to Digital Pin 4

// Arduino setup function
void setup() {
    // Initialize Serial communication at 9600 baud
    Serial.begin(9600);
    
    // Wait for Serial port to connect (necessary for some devices)
    while (!Serial) {}

    // Configure Ultrasonic sensor pins
    pinMode(TRIG_PIN, OUTPUT);  // TRIG pin set as OUTPUT
    pinMode(ECHO_PIN, INPUT);   // ECHO pin set as INPUT

    // Initialize sensors and handle errors
    if (!initializeSensors()) {
        Serial.println("Error: Sensor initialization failed!");
        while (true) {}  // Halt the program if sensors fail
    }
}

// Arduino main loop function
void loop() {
    // Read data from sensors
    int ldrValue = analogRead(LDR_PIN);        // Read LDR sensor value
    int soundValue = analogRead(SOUND_PIN);    // Read sound sensor value
    float distanceValue = getDistance();       // Calculate distance from ultrasonic sensor

    // Error handling: Check if LDR value is out of range
    if (ldrValue < 0 || ldrValue > 1023) {
        Serial.print("Error: LDR value out of range: ");
        Serial.println(ldrValue);
        delay(5000);  // Retry after 5 seconds
        return;
    }

    // Error handling: Check if sound value is out of range
    if (soundValue < 0 || soundValue > 1023) {
        Serial.print("Error: Sound value out of range: ");
        Serial.println(soundValue);
        delay(5000);  // Retry after 5 seconds
        return;
    }

    // Error handling: Check if distance value is out of range
    if (distanceValue < 0 || distanceValue > 400) {
        Serial.print("Error: Distance value out of range: ");
        Serial.println(distanceValue);
        delay(5000);  // Retry after 5 seconds
        return;
    }

    // Log valid sensor data to Serial Monitor
    Serial.print("LDR=");
    Serial.print(ldrValue);
    Serial.print(",Sound=");
    Serial.print(soundValue);
    Serial.print(",Distance=");
    Serial.println(distanceValue);

    // Delay before the next iteration
    delay(5000);
}

// Function to initialize sensors
bool initializeSensors() {
    // Placeholder for sensor initialization logic
    // Returns true if all sensors are initialized successfully
    return true;
}

// Function to calculate distance using the ultrasonic sensor
float getDistance() {
    long duration;

    // Trigger the ultrasonic sensor
    digitalWrite(TRIG_PIN, LOW);
    delayMicroseconds(2);
    digitalWrite(TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG_PIN, LOW);

    // Measure the echo duration
    duration = pulseIn(ECHO_PIN, HIGH, 30000);  // Timeout after 30ms
    if (duration == 0) {
        Serial.println("Error: Timeout occurred, no echo received.");
        return -1;  // Error value
    }

    // Calculate and return distance in centimeters
    return (duration * 0.034 / 2);
}
