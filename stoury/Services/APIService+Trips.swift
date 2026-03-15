import Foundation

extension APIService {
    func getTrips() async throws -> [Trip] {
        guard let url = URL(string: "\(baseURL)/trips") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope([Trip].self, from: data, context: "trips")
    }

    func getTripItinerary(tripId: UUID) async throws -> TripItinerary {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString)/itinerary") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(TripItinerary.self, from: data, context: "trip itinerary")
    }

    func getAttraction(attractionId: UUID) async throws -> AttractionDetail {
        guard let url = URL(string: "\(baseURL)/attractions/\(attractionId.uuidString)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(AttractionDetail.self, from: data, context: "attraction detail")
    }

    func createTrip(_ body: CreateTripRequest) async throws -> CreatedTrip {
        guard let url = URL(string: "\(baseURL)/trips") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.encodingError
        }

        printRequestBody(request)
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(CreatedTrip.self, from: data, context: "create trip")
    }

    func generateAITripPreview(tripId: UUID) async throws -> GeneratedItineraryPreview {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString)/ai-generate") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(GeneratedItineraryPreview.self, from: data, context: "ai generate preview")
    }

    func saveTripItinerary(tripId: UUID, body: SaveItineraryRequest) async throws {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString.lowercased())/itinerary") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.encodingError
        }

        printRequestBody(request)
        _ = try await authorizedData(for: request)
    }
}
