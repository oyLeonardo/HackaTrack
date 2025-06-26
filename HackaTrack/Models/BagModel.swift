import Foundation
import SwiftUI

enum BagState: String, CaseIterable, Codable, Identifiable {
    var id: String { self.rawValue }
    case guardada = "Guardada"
    case emUso = "Em Uso"
    case perdida = "Perdida"
    case interditada = "Interditada"
//    case emprestada = "Emprestada"
    
    // Cores alinhadas com o estilo da UI antiga
    var associatedColor: Color {
        switch self {
        case .guardada: .green
        case .emUso: .blue
        case .perdida: .red
//        case .emprestada: .orange
        case .interditada: .yellow
        }
    }
    
    init?(fromRawValue: String) {
        self.init(rawValue: fromRawValue.capitalized)
    }
}

enum BagType: String, CaseIterable, Codable, Identifiable {
    var id: String { self.rawValue }
    case mochila = "Mochila"
    case generico = "Genérico"
    
    var iconName: String {
        switch self {
        case .mochila: "backpack.fill"
        case .generico: "bag.fill"
        }
    }
}

struct BagModel: Identifiable, Codable, Equatable {
    var id: String { uid }
    let uid: String
    var rev: String
    var name: String
    var state: BagState
    var type: BagType
    var hour: String

    enum CodingKeys: String, CodingKey {
        case uid = "_id"
        case rev = "_rev"
        case name, hour, state, type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.rev = try container.decode(String.self, forKey: .rev)
        self.name = try container.decode(String.self, forKey: .name)
        self.hour = try container.decode(String.self, forKey: .hour)
        
        let stateString = try container.decode(String.self, forKey: .state)
        // Se o valor do JSON for "emprestada", ele será mapeado para o enum corretamente
        self.state = BagState(fromRawValue: stateString) ?? .interditada
        
        let typeString = try container.decode(String.self, forKey: .type)
        self.type = (typeString == "1") ? .mochila : .generico
    }
    
    init(uid: String, rev: String, name: String, state: BagState, type: BagType, hour: String) {
        self.uid = uid
        self.rev = rev
        self.name = name
        self.state = state
        self.type = type
        self.hour = hour
    }
    
    static func == (lhs: BagModel, rhs: BagModel) -> Bool {
        return lhs.id == rhs.id
    }
}
