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

// GET /  → serves the web app HTML page
void handleRoot() {
  String html = R"rawhtml(
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Smart Backpack</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
           background: #0f0f13; color: #e8e8f0; min-height: 100vh; }
    header { background: #1a1a2e; padding: 16px 20px;
             border-bottom: 1px solid #2d2d4e; display: flex;
             align-items: center; gap: 12px; }
    .logo { width: 36px; height: 36px; background: #4f46e5;
            border-radius: 10px; display: flex; align-items: center;
            justify-content: center; font-size: 18px; }
    h1 { font-size: 20px; font-weight: 600; }
    .subtitle { font-size: 12px; color: #888; }
    .status-bar { background: #1a1a2e; padding: 10px 20px;
                  display: flex; gap: 16px; font-size: 12px;
                  border-bottom: 1px solid #2d2d4e; flex-wrap: wrap; }
    .badge { padding: 3px 10px; border-radius: 20px; font-weight: 500; }
    .badge.green  { background: #14532d; color: #4ade80; }
    .badge.red    { background: #450a0a; color: #f87171; }
    .badge.yellow { background: #422006; color: #fbbf24; }
    .badge.blue   { background: #172554; color: #60a5fa; }
    #map { width: 100%; height: 300px; }
    .panel { padding: 20px; }
    .card { background: #1a1a2e; border: 1px solid #2d2d4e;
            border-radius: 14px; padding: 16px; margin-bottom: 14px; }
    .card-title { font-size: 11px; text-transform: uppercase;
                  letter-spacing: 1px; color: #888; margin-bottom: 10px; }
    .coords { font-size: 15px; font-family: monospace; color: #a5b4fc; }
    .coords span { display: block; margin-bottom: 4px; }
    .stat-row { display: flex; gap: 12px; }
    .stat { flex: 1; background: #12121e; border-radius: 10px;
            padding: 12px; text-align: center; }
    .stat-val { font-size: 22px; font-weight: 700; color: #a5b4fc; }
    .stat-lbl { font-size: 11px; color: #666; margin-top: 2px; }
    .btn { width: 100%; padding: 16px; border: none; border-radius: 14px;
           font-size: 16px; font-weight: 600; cursor: pointer;
           transition: all 0.2s; margin-bottom: 10px; }
    .btn-buzz { background: #ef4444; color: white; }
    .btn-buzz:hover { background: #dc2626; }
    .btn-buzz.active { background: #7f1d1d; animation: pulse 1s infinite; }
    .btn-stop { background: #1e293b; color: #94a3b8; }
    .btn-stop:hover { background: #334155; }
    .btn-map { background: #4f46e5; color: white; font-size: 14px; padding: 12px; }
    @keyframes pulse { 0%,100%{transform:scale(1)} 50%{transform:scale(1.02)} }
    .sim-notice { background: #422006; border: 1px solid #92400e;
                  color: #fbbf24; padding: 10px 14px; border-radius: 10px;
                  font-size: 13px; margin-bottom: 14px; }
  </style>
</head>
<body>
  <header>
    <div class="logo">🎒</div>
    <div>
      <h1>Smart Backpack</h1>
      <div class="subtitle">Live tracking dashboard</div>
    </div>
  </header>

  <div class="status-bar">
    <span id="gps-badge" class="badge yellow">GPS: Waiting...</span>
    <span id="wifi-badge" class="badge green">WiFi: Connected</span>
    <span id="buzz-badge" class="badge blue">Buzzer: Off</span>
    <span id="sim-badge" class="badge yellow" style="display:none">Simulated GPS</span>
  </div>

  <div id="map"></div>

  <div class="panel">
    <div id="sim-notice" class="sim-notice" style="display:none">
      ⚠️ GPS is in simulation mode — showing test coordinates.
    </div>

    <div class="card">
      <div class="card-title">GPS Location</div>
      <div class="coords">
        <span id="lat-display">Latitude: —</span>
        <span id="lng-display">Longitude: —</span>
      </div>
      <br>
      <button class="btn btn-map" onclick="openMaps()">Open in Google Maps</button>
    </div>

    <div class="card">
      <div class="card-title">Stats</div>
      <div class="stat-row">
        <div class="stat">
          <div class="stat-val" id="sat-count">—</div>
          <div class="stat-lbl">Satellites</div>
        </div>
        <div class="stat">
          <div class="stat-val" id="speed-val">—</div>
          <div class="stat-lbl">Speed km/h</div>
        </div>
      </div>
    </div>

    <div class="card">
      <div class="card-title">Anti-theft buzzer</div>
      <button class="btn btn-buzz" id="buzz-btn" onclick="triggerBuzzer()">
        🔔 Sound the Alarm
      </button>
      <button class="btn btn-stop" onclick="stopBuzzer()">
        Stop Buzzer
      </button>
    </div>
  </div>

  <script>
    const map = L.map('map').setView([52.4862, -1.8904], 15);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap'
    }).addTo(map);

    const icon = L.divIcon({
      html: '<div style="font-size:28px;transform:translate(-50%,-50%)">🎒</div>',
      iconSize: [0,0], iconAnchor: [0,0]
    });
    let marker = null;
    let lat = 0, lng = 0;

    async function fetchData() {
      try {
        const res = await fetch('/data');
        const d = await res.json();

        lat = d.latitude;
        lng = d.longitude;

        if (d.gps_fixed || d.simulated) {
          if (!marker) {
            marker = L.marker([lat, lng], { icon }).addTo(map);
            map.setView([lat, lng], 16);
          } else {
            marker.setLatLng([lat, lng]);
          }
        }

        document.getElementById('lat-display').textContent =
          'Latitude:  ' + lat.toFixed(6);
        document.getElementById('lng-display').textContent =
          'Longitude: ' + lng.toFixed(6);

        document.getElementById('sat-count').textContent = d.satellites;
        document.getElementById('speed-val').textContent =
          parseFloat(d.speed_kmh).toFixed(1);

        document.getElementById('gps-badge').textContent =
          d.gps_fixed || d.simulated ? 'GPS: Fixed ✓' : 'GPS: Searching...';
        document.getElementById('gps-badge').className =
          'badge ' + (d.gps_fixed || d.simulated ? 'green' : 'yellow');

        document.getElementById('buzz-badge').textContent =
          d.buzzer_on ? 'Buzzer: ON 🔔' : 'Buzzer: Off';
        document.getElementById('buzz-badge').className =
          'badge ' + (d.buzzer_on ? 'red' : 'blue');

        if (d.simulated) {
          document.getElementById('sim-badge').style.display = 'inline';
          document.getElementById('sim-notice').style.display = 'block';
        }

        document.getElementById('buzz-btn').className =
          'btn btn-buzz' + (d.buzzer_on ? ' active' : '');

      } catch(e) {
        document.getElementById('gps-badge').textContent = 'Offline';
        document.getElementById('gps-badge').className = 'badge red';
      }
    }

    async function triggerBuzzer() {
      await fetch('/buzz');
      fetchData();
    }

    async function stopBuzzer() {
      await fetch('/stopbuzz');
      fetchData();
    }

    function openMaps() {
      if (lat && lng) {
        window.open('https://www.google.com/maps?q=' + lat + ',' + lng);
      }
    }

    fetchData();
    setInterval(fetchData, 3000);
  </script>
</body>
</html>
)rawhtml";

  server.send(200, "text/html", html);
}
