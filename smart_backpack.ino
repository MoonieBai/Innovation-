// ============================================================
//  SMART BACKPACK - ESP32 Main Sketch
//  Components: ESP32, NEO-6M GPS, Buzzer, Solar + Powerbank
// ============================================================
//  HOW TO USE:
//  1. Copy config.example.h → rename to config.h
//  2. Fill in your WiFi details inside config.h
//  3. Install libraries (Arduino IDE > Tools > Manage Libraries):
//     - TinyGPSPlus  by Mikal Hart
//     - ArduinoJson  by Benoit Blanchon
//  4. Set SIMULATE_GPS true until your GPS module arrives
//  5. Upload to ESP32, open Serial Monitor at 115200 baud
//  6. Connect phone to same WiFi, open the IP shown in Serial
// ============================================================

#include <WiFi.h>
#include <WebServer.h>
#include <TinyGPSPlus.h>
#include <ArduinoJson.h>
#include <HardwareSerial.h>
#include "config.h"   // ← WiFi credentials live here (not on GitHub)

// ─────────────────────────────────────────
//  PIN DEFINITIONS  ← adjust after wiring
// ─────────────────────────────────────────
#define BUZZER_PIN   25   // GPIO pin connected to buzzer
#define GPS_RX_PIN   16   // ESP32 RX2 ← GPS TX
#define GPS_TX_PIN   17   // ESP32 TX2 → GPS RX (often unused)
#define GPS_BAUD     9600

// ─────────────────────────────────────────
//  SIMULATION MODE
//  Set to true if GPS module not yet connected
// ─────────────────────────────────────────
#define SIMULATE_GPS true

// ─────────────────────────────────────────
//  GLOBALS
// ─────────────────────────────────────────
TinyGPSPlus gps;
HardwareSerial gpsSerial(2);   // UART2 on ESP32
WebServer server(80);

// Simulated GPS coords (set to your school/home for testing)
const double SIM_LAT = 52.4862;
const double SIM_LNG = -1.8904;

// State
bool  buzzerActive  = false;
float lastLatitude  = 0.0;
float lastLongitude = 0.0;
bool  gpsFixed      = false;

// ─────────────────────────────────────────
//  SETUP
// ─────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  Serial.println("\n=== Smart Backpack Booting ===");

  // Buzzer pin
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  // GPS serial
  if (!SIMULATE_GPS) {
    gpsSerial.begin(GPS_BAUD, SERIAL_8N1, GPS_RX_PIN, GPS_TX_PIN);
    Serial.println("[GPS] Serial started");
  } else {
    Serial.println("[GPS] SIMULATION MODE - using fake coordinates");
    lastLatitude  = SIM_LAT;
    lastLongitude = SIM_LNG;
    gpsFixed      = true;
  }

  // Connect to WiFi
  connectWiFi();

  // Register web routes
  server.on("/",         handleRoot);
  server.on("/data",     handleData);
  server.on("/buzz",     handleBuzz);
  server.on("/stopbuzz", handleStopBuzz);
  server.onNotFound([]() {
    server.send(404, "text/plain", "Not found");
  });

  server.begin();
  Serial.println("[Server] HTTP server started");
  Serial.print("[Server] Open this in your browser: http://");
  Serial.println(WiFi.localIP());
}

// ─────────────────────────────────────────
//  LOOP
// ─────────────────────────────────────────
void loop() {
  server.handleClient();

  // Read real GPS data when not simulating
  if (!SIMULATE_GPS) {
    while (gpsSerial.available() > 0) {
      char c = gpsSerial.read();
      gps.encode(c);
    }
    if (gps.location.isUpdated()) {
      lastLatitude  = gps.location.lat();
      lastLongitude = gps.location.lng();
      gpsFixed      = gps.location.isValid();
    }
  }
}

// ─────────────────────────────────────────
//  WIFI
// ─────────────────────────────────────────
void connectWiFi() {
  Serial.print("[WiFi] Connecting to ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n[WiFi] Connected!");
    Serial.print("[WiFi] IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n[WiFi] Failed to connect — check credentials in config.h");
    Serial.println("[WiFi] Restarting in 5 seconds...");
    delay(5000);
    ESP.restart();
  }
}

// ─────────────────────────────────────────
//  ROUTES
// ─────────────────────────────────────────

// GET /data  → returns JSON with GPS + status
void handleData() {
  StaticJsonDocument<256> doc;

  doc["latitude"]   = lastLatitude;
  doc["longitude"]  = lastLongitude;
  doc["gps_fixed"]  = gpsFixed;
  doc["buzzer_on"]  = buzzerActive;
  doc["simulated"]  = SIMULATE_GPS;

  if (!SIMULATE_GPS && gps.satellites.isValid()) {
    doc["satellites"] = gps.satellites.value();
    doc["speed_kmh"]  = gps.speed.kmph();
  } else {
    doc["satellites"] = SIMULATE_GPS ? 8 : 0;
    doc["speed_kmh"]  = 0;
  }

  String json;
  serializeJson(doc, json);
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", json);
}

// POST /buzz  → turns buzzer ON
void handleBuzz() {
  buzzerActive = true;
  digitalWrite(BUZZER_PIN, HIGH);
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", "{\"status\":\"buzzer on\"}");
  Serial.println("[Buzzer] ON");
}

// POST /stopbuzz  → turns buzzer OFF
void handleStopBuzz() {
  buzzerActive = false;
  digitalWrite(BUZZER_PIN, LOW);
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", "{\"status\":\"buzzer off\"}");
  Serial.println("[Buzzer] OFF");
}

