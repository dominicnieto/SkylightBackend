import Vapor

/// Service responsible for communicating with the Sunsethue API
struct SunsethueService {
    let apiKey: String
    let client: Client

    /// Fetches sunrise/sunset forecast from Sunsethue API
    /// - Parameters:
    ///   - latitude: Location latitude (-90 to 90)
    ///   - longitude: Location longitude (-180 to 180)
    ///   - days: Number of days to fetch (default: 1, max: 3)
    /// - Returns: The complete Sunsethue API response
    func getForecast(latitude: Double, longitude: Double, days: Int = 1) async throws -> SunsethueResponse {
        // Build the API URL with query parameters
        let baseURL = "https://api.sunsethue.com/forecast"
        var uri = URI(string: baseURL)

        // Add query parameters (latitude and longitude are required)
        uri.query = "latitude=\(latitude)&longitude=\(longitude)&days=\(days)"

        // Make the HTTP request
        let response = try await client.get(uri) { request in
            // Add API key to request headers (lowercase as per API docs)
            request.headers.add(name: "x-api-key", value: apiKey)
        }

        // Decode the JSON response into our Swift models
        return try response.content.decode(SunsethueResponse.self)
    }

    /// Fetches today's sunrise and sunset in a simplified format
    /// - Parameters:
    ///   - latitude: Location latitude
    ///   - longitude: Location longitude
    /// - Returns: Simplified response with just today's sunrise/sunset
    func getTodaysSunEvents(latitude: Double, longitude: Double) async throws -> SimplifiedSunResponse {
        // Get the full forecast (just 1 day)
        let forecast = try await getForecast(latitude: latitude, longitude: longitude, days: 1)

        // TODO(human): Extract today's sunrise and sunset from forecast.data
        // The data array contains events for today. Find the sunrise and sunset events.
        // Hint: Use filter or first(where:) to find events where type == "sunrise" or "sunset"

        let sunrise: SunEvent? = forecast.data.first(where: { $0.type == "sunrise" })
        let sunset: SunEvent? = forecast.data.first(where: { $0.type == "sunset" })

        // Return simplified response
        return SimplifiedSunResponse(
            location: forecast.location,
            sunrise: sunrise,
            sunset: sunset,
            fetchedAt: ISO8601DateFormatter().string(from: Date())
        )
    }
}
