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
        components.path = "/" + endpoint
        
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        return components.url
    }
    
    // MARK: - Generic GET Request
    
    /// Realiza uma requisição GET genérica e decodifica a resposta.
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
    
    // MARK: - Generic POST Request
    
    /// Realiza uma requisição POST genérica com um corpo (body) e decodifica a resposta.
    func postRequest<T: Encodable, R: Decodable>(body: T, responseType: R.Type, endpoint: String) async throws -> R {
        guard let url = makeURL(endpoint: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
    
    // MARK: - Generic PUT Request
    
    /// Realiza uma requisição PUT genérica com um corpo (body) para atualização.
    /// - Parameters:
    ///   - body: O objeto `Encodable` a ser enviado no corpo da requisição.
    ///   - responseType: O tipo `Decodable` que esperamos como resposta.
    ///   - endpoint: O caminho do recurso na API.
    /// - Returns: Um objeto do tipo da resposta especificada.
    /// - Throws: Um `APIError` se a requisição falhar.
    func putRequest<T: Encodable, R: Decodable>(body: T, responseType: R.Type, endpoint: String) async throws -> R {
        guard let url = makeURL(endpoint: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT" // A principal diferença está aqui
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


// MARK: - Como Usar as Novas Funções

/*
 
 // ** Exemplo de chamada GET **
 func fetchAllBags() async {
     do {
         let bags: [BagModel] = try await APIService.shared.getRequest(type: [BagModel].self, endpoint: "bags")
         print("Mochilas recebidas: \(bags.count)")
     } catch {
         print("Erro ao buscar mochilas: \(error.localizedDescription)")
     }
 }
 

 // ** Exemplo de chamada POST **
 func registerUser(newUser: UserModel) async {
     struct AuthResponse: Decodable { let message: String, userId: String }
     do {
         let response: AuthResponse = try await APIService.shared.postRequest(body: newUser, responseType: AuthResponse.self, endpoint: "users/register")
         print("Usuário registrado com sucesso: \(response.message)")
     } catch {
         print("Erro ao registrar usuário: \(error.localizedDescription)")
     }
 }
 
 
 // ** Exemplo de chamada PUT **
 func updateUserProfile(updatedProfile: UserProfile) async {
    struct UpdateResponse: Decodable { let success: Bool }
    do {
        // Envia o perfil atualizado para o endpoint de update
        let response: UpdateResponse = try await APIService.shared.putRequest(body: updatedProfile, responseType: UpdateResponse.self, endpoint: "profile/update")
        if response.success {
            print("Perfil atualizado com sucesso!")
        }
    } catch {
        print("Erro ao atualizar perfil: \(error.localizedDescription)")
    }
 }

*/
