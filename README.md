# Skylight Backend

A Swift Vapor backend server that provides sunrise and sunset forecast data from the Sunsethue API.

## 🚀 Quick Start

### Run the Server

```bash
swift run SkylightBackend serve --port 8080
```

The server will start at `http://127.0.0.1:8080`

### Test the API

```bash
curl "http://127.0.0.1:8080/sunrise?lat=40.7&lon=-74"
```

## 📡 API Endpoints

### GET `/sunrise`

Returns today's sunrise and sunset data for a given location.

**Query Parameters:**
- `lat` (required): Latitude (-90 to 90)
- `lon` (required): Longitude (-180 to 180)

**Example Request:**
```
GET /sunrise?lat=40.7&lon=-74
```

**Example Response:**
```json
{
  "location": {
    "latitude": 40.7,
    "longitude": -74
  },
  "sunrise": {
    "type": "sunrise",
    "model_data": true,
    "quality": 0.6,
    "quality_text": "Good",
    "cloud_cover": 0.57,
    "time": "2025-11-05T11:30:00.000Z",
    "direction": 109.8,
    "magics": {
      "blue_hour": ["2025-11-05T10:53:00.000Z", "2025-11-05T11:06:00.000Z"],
      "golden_hour": ["2025-11-05T11:12:00.000Z", "2025-11-05T11:44:00.000Z"]
    }
  },
  "sunset": {
    "type": "sunset",
    "model_data": true,
    "quality": 0.53,
    "quality_text": "Good",
    "cloud_cover": 0.9,
    "time": "2025-11-05T21:49:00.000Z",
    "direction": 250.2,
    "magics": {
      "blue_hour": ["2025-11-05T22:13:00.000Z", "2025-11-05T22:25:00.000Z"],
      "golden_hour": ["2025-11-05T21:34:00.000Z", "2025-11-05T22:06:00.000Z"]
    }
  },
  "fetchedAt": "2025-11-05T21:58:47Z"
}
```

**Error Responses:**

400 Bad Request - Missing parameters:
```json
{"error": true, "reason": "Missing required parameters: lat and lon"}
```

400 Bad Request - Invalid coordinates:
```json
{"error": true, "reason": "Latitude must be between -90 and 90"}
```

500 Internal Server Error - Missing API key:
```json
{"error": true, "reason": "SUNSETHUE_API_KEY not configured"}
```

## 🔑 Configuration

The server requires a Sunsethue API key set in the environment.

Create a `.env` file in the project root:
```
SUNSETHUE_API_KEY=your_api_key_here
```

## 📱 iOS App Integration

### Step 1: Create Swift Models

Add these models to your iOS app (they match the server response):

```swift
struct SunriseResponse: Codable {
    let location: Location
    let sunrise: SunEvent?
    let sunset: SunEvent?
    let fetchedAt: String
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

struct SunEvent: Codable {
    let type: String
    let modelData: Bool
    let quality: Double?
    let qualityText: String?
    let cloudCover: Double?
    let time: String
    let direction: Double
    let magics: MagicHours

    enum CodingKeys: String, CodingKey {
        case type
        case modelData = "model_data"
        case quality
        case qualityText = "quality_text"
        case cloudCover = "cloud_cover"
        case time, direction, magics
    }
}

struct MagicHours: Codable {
    let blueHour: [String]
    let goldenHour: [String]

    enum CodingKeys: String, CodingKey {
        case blueHour = "blue_hour"
        case goldenHour = "golden_hour"
    }
}
```

### Step 2: Make the API Call

```swift
func fetchSunriseSunset(lat: Double, lon: Double) async throws -> SunriseResponse {
    // When testing locally, use your Mac's IP address
    // When deployed, use your production URL
    let url = URL(string: "http://localhost:8080/sunrise?lat=\(lat)&lon=\(lon)")!

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }

    return try JSONDecoder().decode(SunriseResponse.self, from: data)
}
```

### Step 3: Use the Data

```swift
Task {
    do {
        let sunData = try await fetchSunriseSunset(lat: 40.7, lon: -74)

        if let sunrise = sunData.sunrise {
            print("Sunrise quality: \(sunrise.qualityText ?? "Unknown")")
            print("Sunrise time: \(sunrise.time)")

            // Convert ISO8601 string to Date
            let formatter = ISO8601DateFormatter()
            if let date = formatter.date(from: sunrise.time) {
                // Now you have a Date object to display
                print("Local time: \(date)")
            }
        }
    } catch {
        print("Error fetching sun data: \(error)")
    }
}
```

### Step 4: Testing on Device/Simulator

**When testing on iOS Simulator:**
- Use `http://localhost:8080` (same machine)

**When testing on a physical device:**
- Make sure your device and Mac are on the same Wi-Fi
- Find your Mac's IP address: System Settings → Network
- Use `http://YOUR_MAC_IP:8080` (e.g., `http://192.168.1.5:8080`)
- Add this to your Info.plist to allow local network access:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

## 📦 Project Structure

```
SkylightBackend/
├── Sources/SkylightBackend/
│   ├── entrypoint.swift          # App entry point
│   ├── configure.swift           # Server configuration
│   ├── routes.swift              # API endpoint definitions
│   ├── Models/
│   │   └── SunsethueModels.swift # Data structures
│   └── Services/
│       └── SunsethueService.swift # Sunsethue API client
├── Package.swift
├── .env                          # Environment variables (API keys)
└── README.md                     # This file
```

## 🔧 Development

### Build the project
```bash
swift build
```

### Run tests
```bash
swift test
```

### Run in Xcode
1. Open Package.swift in Xcode
2. Select "My Mac" as the target
3. Press ⌘ + R to run

## 🌐 Deployment (Future)

When you're ready to deploy to production:
1. Choose a hosting provider (Railway, Heroku, AWS, etc.)
2. Update your iOS app to use the production URL
3. Make sure to set the `SUNSETHUE_API_KEY` environment variable on the server
4. Update App Transport Security settings if needed

## 📚 Resources

- [Vapor Documentation](https://docs.vapor.codes)
- [Sunsethue API Docs](https://sunsethue.com/dev-api)
- [Swift on Server](https://swift.org/server)
