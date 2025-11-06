import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // MARK: - Sunrise/Sunset Endpoints

    /// GET /sunrise?lat=40.7&lon=-74
    /// Returns today's sunrise and sunset data for the given coordinates
    app.get("sunrise") { req async throws -> SimplifiedSunResponse in
        // 1. Get the API key from environment variables
        guard let apiKey = Environment.get("SUNSETHUE_API_KEY") else {
            throw Abort(.internalServerError, reason: "SUNSETHUE_API_KEY not configured")
        }

        // 2. Extract latitude and longitude from query parameters
        guard let lat = req.query[Double.self, at: "lat"],
              let lon = req.query[Double.self, at: "lon"] else {
            throw Abort(.badRequest, reason: "Missing required parameters: lat and lon")
        }

        // 3. Validate coordinates
        guard lat >= -90 && lat <= 90 else {
            throw Abort(.badRequest, reason: "Latitude must be between -90 and 90")
        }
        guard lon >= -180 && lon <= 180 else {
            throw Abort(.badRequest, reason: "Longitude must be between -180 and 180")
        }

        // 4. Create the service and fetch the data
        let service = SunsethueService(apiKey: apiKey, client: req.client)
        let response = try await service.getTodaysSunEvents(latitude: lat, longitude: lon)

        // 5. Return the simplified response (Vapor auto-converts to JSON)
        return response
    }
}
