# Smart Backpack 🎒

A solar-powered smart backpack with GPS tracking, remote buzzer alert, and a live web app dashboard — built with an ESP32.

## Features
- 📍 Live GPS location on a map
- 🔔 Remote buzzer anti-theft alert from the app
- 🗺️ One-tap "Open in Google Maps"
- 🔋 Powered by solar panels + powerbank
- 📶 Web app hosted directly on the ESP32

---

## Setup

### 1. Install Arduino IDE
Download from: https://www.arduino.cc/en/software

### 2. Add ESP32 Board Support
- File → Preferences → paste into "Additional boards manager URLs":
  ```
  https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
  ```
- Tools → Board → Boards Manager → search "esp32" → Install "esp32 by Espressif Systems"
- Select: Tools → Board → ESP32 Arduino → "ESP32 Dev Module"

### 3. Install Libraries
Tools → Manage Libraries → search and install:
- **TinyGPSPlus** by Mikal Hart
- **ArduinoJson** by Benoit Blanchon

### 4. Add your WiFi credentials
```
cp config.example.h config.h
```
Then open `config.h` and fill in your WiFi name and password.
> ⚠️ `config.h` is gitignored — it will never be pushed to GitHub.

### 5. Upload & Test
- Set `SIMULATE_GPS true` in the sketch (no hardware needed)
- Upload to ESP32
- Open Serial Monitor at 115200 baud
- Copy the IP address shown → open it in your phone browser

---

## Wiring (for when components arrive)

### GPS Module (NEO-6M) → ESP32
| GPS Pin | ESP32 Pin |
|---------|-----------|
| VCC     | 3.3V      |
| GND     | GND       |
| TX      | GPIO 16   |
| RX      | GPIO 17   |

### Buzzer → ESP32
| Buzzer Pin | ESP32 Pin |
|------------|-----------|
| +          | GPIO 25   |
| -          | GND       |

### Solar Panels → Powerbank
Solar panels → Buck converter (set to 5V output) → Powerbank USB-C input

### Powerbank → ESP32
Powerbank USB-A → ESP32 micro-USB

---

## Switching from Simulation to Real GPS
1. Wire the GPS module as above
2. In the sketch change:
   ```cpp
   #define SIMULATE_GPS false
   ```
3. Re-upload — GPS takes 1-2 minutes outdoors to get a first fix

---

## File Structure
```
smart_backpack/
├── smart_backpack.ino   # Main code
├── config.h             # YOUR WiFi credentials (gitignored, not on GitHub)
├── config.example.h     # Template — safe to push, fill in and rename
├── .gitignore           # Keeps config.h off GitHub
└── README.md
```

## Components
- ESP32 Dev Module
- NEO-6M GPS Module
- Active Buzzer
- 2× Solar Panels
- Buck converter (panels → 5V)
- 20000mAh Powerbank (USB-C input, LCD display)
