import Foundation

// MARK: - APIError Enum
// Um enum personalizado para tratar erros de rede de forma mais específica.
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A URL da requisição é inválida."
        case .invalidResponse:
            return "A resposta do servidor foi inválida."
        case .requestFailed(let statusCode):
            return "A requisição falhou com o código de status: \(statusCode)."
        case .decodingError(let error):
            return "Falha ao decodificar a resposta: \(error.localizedDescription)"
        }
    }
}

class Endpoints {
    let show: String = "/show"; // Lista uma bag
    let create: String = "/create/bag"; // Cria uma bag
    let delete: String = "/delete/bag"; // Deletar bag
    let update: String = "/update/bag"; // Atualizar bag
    let getAll: String = "/bags"; // Lista todas as bags
    let getUIDS: String = "/bags/uids"; // lista todos os uids
    let getNot: String = "/bags/notifications"
}

/*
 {
    "_id": "03ce46233e0e8d66c62fa50e5dd1ee20",
    "_rev": "1-68abeb65aa740e06f90873346e1dd07a",
    "uid": "F4CECBF0",
    "hour": "00:00:02",
    "status": "Negado"
  },
 */

class UserTemplate {
    let username: String = "Teste";
    let email: String = "teste@gmail.com";
    let password: String = "teste123";
}


enum RequestType: String, Decodable, Identifiable, CaseIterable {
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    
    var id: String {
        return self.rawValue
    }
}


class APIService {
    static let shared = APIService()
    private let scheme: String = "http"
    private let host: String = "192.168.128.91"
    private let port: Int = 1880
    private init() {}
    
    func makeURL(endpoint: String, queryItems: [URLQueryItem]? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = endpoint
        
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        return components.url
    }
    
    // MARK: - Generic GET Request
    
    func getRequest<T: Decodable>(type: T.Type, endpoint: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        guard let url = makeURL(endpoint: endpoint, queryItems: queryItems) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 // Adapte se seu backend usar outro formato de data
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Generic POST, PUT, DELETE Requests
    func sendDataRequest<T: Encodable, R: Decodable>(body: T, responseType: R.Type, endpoint: String, method: RequestType) async throws -> R {
        guard let url = makeURL(endpoint: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue // Usa o método especificado
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(R.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
