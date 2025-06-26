import Foundation

struct User: Codable {
    let id: String?
    let username: String
    let email: String
    let password: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case password
    }
    
    init(id: String? = nil, username: String, email: String, password: String? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
    }
}


// MARK: - Como Usar o Modelo

/*
 
 // 1. Criando um novo usuário para enviar para o backend (ex: registro)
 let novoUsuario = User(username: "JoaoSilva", email: "joao@exemplo.com", password: "senhaForte123")
 
 do {
     // Codificando o usuário para JSON
     let encoder = JSONEncoder()
     encoder.outputFormatting = .prettyPrinted // Para visualização legível
     let jsonData = try encoder.encode(novoUsuario)
     
     if let jsonString = String(data: jsonData, encoding: .utf8) {
         print("--- JSON para Enviar ---")
         print(jsonString)
         // Agora você enviaria `jsonData` para a sua API Node-RED.
     }
 } catch {
     print("Erro ao codificar o usuário: \(error)")
 }


 // 2. Decodificando um usuário recebido do backend (ex: após login bem-sucedido)
 let jsonStringRecebido = """
 {
     "id": "user_1719253678",
     "username": "JoaoSilva",
     "email": "joao@exemplo.com"
 }
 """
 let jsonDataRecebido = Data(jsonStringRecebido.utf8)
 
 do {
     // Decodificando JSON para um objeto User
     let decoder = JSONDecoder()
     let usuarioLogado = try decoder.decode(User.self, from: jsonDataRecebido)
     
     print("\n--- Usuário Decodificado ---")
     print("ID: \(usuarioLogado.id ?? "N/A")")
     print("Username: \(usuarioLogado.username)")
     print("Email: \(usuarioLogado.email)")
     // Note que a senha é `nil`, pois o servidor não a enviou.
     print("Senha: \(usuarioLogado.password ?? "Não retornada pela API")")

 } catch {
     print("Erro ao decodificar o usuário: \(error)")
 }

*/
