import Foundation
#if canImport(Alamofire)
import Alamofire
#endif
public protocol ApiserviceInterface {
    func login(username: String, password: String) async throws -> Player
    func signUp(email: String, password: String, discordUsername: String, deckSelection: String, commander: String) async throws -> Player
    func fetchAchievements() async throws -> [Achievement]
    func saveAchievementsToLocalFile(_ achievements: [Achievement], fileName: String) async throws
}
public typealias Completion<T> = (_ result: T?,_ error: Error?) -> Void


private enum APIConfig {
    static let baseURL: URL = {
        guard let dict = Bundle.main.infoDictionary,
              let urlString = dict["BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("Missing or invalid BASE_URL in Info.plist")
        }
        return url
    }()
}

let baseURL = APIConfig.baseURL


final class APIService: ApiserviceInterface {
    static let shared = APIService()
    private init() {}
    
    

    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE
    }

    enum APIError: Error, LocalizedError {
        case httpError(statusCode: Int, body: String?)
        case decodeError(statusCode: Int?, body: String?, underlying: Error)
        case networkError(underlying: Error)

        var errorDescription: String? {
            switch self {
            case .httpError(let status, let body):
                return "HTTP error \(status) - \(body ?? "no body")"
            case .decodeError(let status, let body, let underlying):
                return "Decode error (status: \(status.map(String.init) ?? "nil")): \(underlying) - body: \(body ?? "no body")"
            case .networkError(let underlying):
                return "Network error: \(underlying.localizedDescription)"
            }
        }
    }
    
    
    func login(username: String, password: String) async throws -> Player {
        print(baseURL.absoluteString)
        let url = baseURL.appendingPathComponent("/api/player/login")
        let body: [String: String] = ["identifier": username, "password": password]

#if canImport(Alamofire)
        let request = AF.request(url, method: .post, parameters: body, encoder: JSONParameterEncoder.default)

        // Use Alamofire to get full response then decode locally to avoid Sendable constraints
        let afResponse = await request.serializingData().response
        let data = afResponse.data ?? Data()
        let statusCode = afResponse.response?.statusCode

        // If Alamofire returned a transport/error, surface it as networkError
        if let afError = afResponse.error {
            let body = String(data: data, encoding: .utf8)
            print("[APIService] Network error during login: \(afError) - HTTP status: \(statusCode.map(String.init) ?? "nil") - body: \(body ?? "")")
            throw APIError.networkError(underlying: afError)
        }

        // Check HTTP status
        if let status = statusCode, !(200...299).contains(status) {
            let body = String(data: data, encoding: .utf8)
            print("[APIService] Login HTTP error: \(status)\nResponse body:\n\(body ?? "")")
            throw APIError.httpError(statusCode: status, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(Player.self, from: data)
            print("[APIService] Logged in: \(decoded.playerName) (id: \(decoded.id))")
            return decoded
        } catch {
            let body = String(data: data, encoding: .utf8)
            print("[APIService] Failed to decode Player. HTTP status: \(statusCode.map(String.init) ?? "nil") Error: \(error)\nResponse data:\n\(body ?? "(binary: \(data.count) bytes)")")
            throw APIError.decodeError(statusCode: statusCode, body: body, underlying: error)
        }
#else
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[APIService] No HTTP response received when attempting login")
            throw APIError.networkError(underlying: URLError(.badServerResponse))
        }

        // Check HTTP status
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            print("[APIService] Login HTTP error: \(httpResponse.statusCode)\nResponse body:\n\(body ?? "")")
            throw APIError.httpError(statusCode: httpResponse.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(Player.self, from: data)
            print("[APIService] Logged in: \(decoded.playerName) (id: \(decoded.id))")
            return decoded
        } catch {
            let body = String(data: data, encoding: .utf8)
            print("[APIService] Failed to decode Player. HTTP status: \(httpResponse.statusCode) Error: \(error)\nResponse data:\n\(body ?? "(binary: \(data.count) bytes)")")
            throw APIError.decodeError(statusCode: httpResponse.statusCode, body: body, underlying: error)
        }
#endif
    }

    func signUp(email: String, password: String, discordUsername: String, deckSelection: String, commander: String) async throws -> Player {
        let url = baseURL.appendingPathComponent("/api/signups")
        let body: [String: String] = [
            "email": email,
            "password": password,
            "discordUsername": discordUsername,
            "deckSelection": deckSelection,
            "commander": commander
        ]

#if canImport(Alamofire)
        let request = AF.request(url, method: .post, parameters: body, encoder: JSONParameterEncoder.default)
        let afResponse = await request.serializingData().response
        let data = afResponse.data ?? Data()
        let statusCode = afResponse.response?.statusCode

        if let afError = afResponse.error {
            let bodyText = String(data: data, encoding: .utf8)
            print("[APIService] Network error during signup: \(afError) - HTTP status: \(statusCode.map(String.init) ?? "nil") - body: \(bodyText ?? "")")
            throw APIError.networkError(underlying: afError)
        }

        if let status = statusCode, !(200...299).contains(status) {
            let bodyText = String(data: data, encoding: .utf8)
            print("[APIService] Signup HTTP error: \(status)\nResponse body:\n\(bodyText ?? "")")
            throw APIError.httpError(statusCode: status, body: bodyText)
        }

        do {
            let decoded = try JSONDecoder().decode(Player.self, from: data)
            print("[APIService] Signed up: \(decoded.playerName) (id: \(decoded.id))")
            return decoded
        } catch {
            let bodyText = String(data: data, encoding: .utf8)
            print("[APIService] Failed to decode Player on signup. HTTP status: \(statusCode.map(String.init) ?? "nil") Error: \(error)\nResponse data:\n\(bodyText ?? "(binary: \(data.count) bytes)")")
            throw APIError.decodeError(statusCode: statusCode, body: bodyText, underlying: error)
        }
#else
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(underlying: URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8)
            print("[APIService] Signup HTTP error: \(httpResponse.statusCode)\nResponse body:\n\(bodyText ?? "")")
            throw APIError.httpError(statusCode: httpResponse.statusCode, body: bodyText)
        }

        do {
            let decoded = try JSONDecoder().decode(Player.self, from: data)
            print("[APIService] Signed up: \(decoded.playerName) (id: \(decoded.id))")
            return decoded
        } catch {
            let bodyText = String(data: data, encoding: .utf8)
            print("[APIService] Failed to decode Player on signup. HTTP status: \(httpResponse.statusCode) Error: \(error)\nResponse data:\n\(bodyText ?? "(binary: \(data.count) bytes)")")
            throw APIError.decodeError(statusCode: httpResponse.statusCode, body: bodyText, underlying: error)
        }
#endif
    }
}
// MARK: - Achievements API and saving

extension APIService {
    /// Fetches achievements from the API and returns them as an array
    func fetchAchievements() async throws -> [Achievement] {
        let url = baseURL.appendingPathComponent("/api/achievements")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

#if canImport(Alamofire)
        let request = AF.request(url, method: .get).validate()
        let data = try await request.serializingData().value
        let achievements = try decoder.decode([Achievement].self, from: data)
        try await self.saveAchievementsToLocalFile(achievements) // Save to local file
        return achievements
#else
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode([Achievement].self, from: data)
#endif
    }

    /// Saves a list of achievements to a file in the Documents directory as JSON
    func saveAchievementsToLocalFile(_ achievements: [Achievement], fileName: String = "achievements.json") async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(achievements)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        try data.write(to: url)
    }
    
    func completeAchievement(playerID: String, achievementID: String, result: @escaping (Result<String, Error>) -> Void) async throws {
        let url = baseURL.appendingPathComponent("/api/player/\(playerID)/achievements")
        let body: [String: String] = ["achievementId": achievementID]

#if canImport(Alamofire)
        let request = AF.request(url,
                                 method: .post,
                                 parameters: body,
                                 encoder: JSONParameterEncoder.default)
            .response(completionHandler: { data in
                switch data.result {
                case .success:
                    if let statusCode = data.response?.statusCode, statusCode == 200 {
                        result(.success("Achievement completed successfully"))
                    } else {
                        let body = data.data.flatMap { String(data: $0, encoding: .utf8) }
                        let error = data.error
                        result(.failure(APIError.httpError(statusCode: data.response?.statusCode ?? -1, body: body)))
                    }
                case .failure(let error):
                    let statusCode = data.response?.statusCode ?? -1
                    result(.failure(APIError.networkError(underlying: error)))
                }
            })
#else
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
#endif
    }
}

// Usage Example (call from your view model or somewhere appropriate):
// let achievements = try await APIService.shared.fetchAchievements()
// try APIService.shared.saveAchievementsToLocalFile(achievements)

import SwiftData

extension APIService {
    /// Fetches achievements from the API and persists them into Swift Data.
    /// Call this after a successful login, passing your app's ModelContext.
    func syncAchievementsToSwiftData(using context: ModelContext) async throws {
        let achievements = try await fetchAchievements()

        // Clear existing achievements (simple strategy). Alternatively, implement upsert.
        let existing = try? context.fetch(FetchDescriptor<AchievementEntity>())
        existing?.forEach { context.delete($0) }

        for a in achievements {
            let entity = AchievementEntity(
                id: a.id,
                title: a.title,
                achievementDescription: a.description,
                rarity: a.rarity,
                category: a.category,
                points: a.points
            )
            context.insert(entity)
        }

        try context.save()
    }
}

