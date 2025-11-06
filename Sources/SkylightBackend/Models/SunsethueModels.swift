import Vapor

// MARK: - Main Response Structure
/// The complete response from the Sunsethue API
struct SunsethueResponse: Content {
    let location: Location
    let gridLocation: Location
    let data: [SunEvent]

    enum CodingKeys: String, CodingKey {
        case location
        case gridLocation = "grid_location"
        case data
    }
}

// MARK: - Location
/// Geographic coordinates for a location
struct Location: Content {
    let latitude: Double
    let longitude: Double
}

// MARK: - Sun Event
/// A single sunrise or sunset event with quality information
struct SunEvent: Content {
    let type: String               // "sunrise" or "sunset"
    let modelData: Bool            // true if forecast data is available
    let quality: Double?           // 0.0-1.0 photography quality score (only if modelData=true)
    let qualityText: String?       // "poor", "fair", "good", "great", "excellent" (only if modelData=true)
    let cloudCover: Double?        // 0.0-1.0 cloud coverage percentage (only if modelData=true)
    let time: String               // ISO 8601 timestamp
    let direction: Double          // Compass direction in degrees
    let magics: MagicHours

    enum CodingKeys: String, CodingKey {
        case type
        case modelData = "model_data"
        case quality
        case qualityText = "quality_text"
        case cloudCover = "cloud_cover"
        case time
        case direction
        case magics
    }
}

// MARK: - Magic Hours
/// Special photography hours (blue hour and golden hour)
struct MagicHours: Content {
    let blueHour: [String]     // [start, end] times in ISO 8601
    let goldenHour: [String]   // [start, end] times in ISO 8601

    enum CodingKeys: String, CodingKey {
        case blueHour = "blue_hour"
        case goldenHour = "golden_hour"
    }
}

// MARK: - Simplified Response for iOS App
/// A cleaner response structure to send to your iOS app
/// Contains just today's sunrise and sunset
struct SimplifiedSunResponse: Content {
    let location: Location
    let sunrise: SunEvent?
    let sunset: SunEvent?
    let fetchedAt: String      // When this data was retrieved
}
