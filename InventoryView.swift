import SwiftUI

// MARK: - Modelos

struct CreateBagPayload: Codable {
    let uid: String
    let name: String
    let state: BagState
    let type: BagType
    let hour: String
}

struct AvailableUID: Codable, Identifiable, Hashable {
    let id: String // Corresponds to _id
    let rev: String // Corresponds to _rev
    let uid: String // The actual UID to display and use

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rev = "_rev"
        case uid
    }
}

enum BagState: String, CaseIterable, Codable, Identifiable {
    var id: String { self.rawValue }
    case guardada = "Guardada"
    case emUso = "Em Uso"
    case perdida = "Perdida"
    case interditada = "Interditada"
    case emprestada = "Emprestada"
    
    var associatedColor: Color {
        switch self {
        case .guardada: .green
        case .emUso, .emprestada: .blue
        case .perdida: .red
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

// MARK: - ViewModels
@MainActor
class InventoryViewModel: ObservableObject {
    @Published var bags: [BagModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var search = ""
    
    var filteredBags: [BagModel] {
        bags.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
    }
    
    func fetchBags() async {
        isLoading = true
        errorMessage = nil
        do {
            self.bags = try await APIService.shared.getRequest(type: [BagModel].self, endpoint: "bags")
        } catch {
            self.errorMessage = "Erro ao carregar o inventário: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func addBag(name: String, rfid: String, state: BagState, type: BagType) async {
        errorMessage = nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let hourString = formatter.string(from: Date())

        let payload = CreateBagPayload(uid: rfid, name: name, state: state, type: type, hour: hourString)
        
        struct CreateResponse: Codable {
            let ok: Bool?
            let id: String?
            let rev: String?
        }
        
        do {
            _ = try await APIService.shared.postRequest(
                body: payload,
                responseType: CreateResponse.self,
                endpoint: "create/bag"
            )
            await fetchBags()
        } catch {
            self.errorMessage = "Erro ao criar a mochila: \(error.localizedDescription)"
        }
    }
    
    func updateBag(bag: BagModel) async {
        isLoading = true
        errorMessage = nil
        
        struct UpdateResponse: Codable { let ok: Bool, id: String, rev: String }
        
        do {
            // ** AQUI ESTÁ A MUDANÇA **
            // Trocado de postRequest para putRequest para a atualização.
            _ = try await APIService.shared.putRequest(body: bag, responseType: UpdateResponse.self, endpoint: "update/bag")
            await fetchBags()
        } catch {
            self.errorMessage = "Erro ao atualizar a mochila: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

@MainActor
class RegisterItemViewModel: ObservableObject {
    @Published var availableUIDs: [AvailableUID] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchAvailableUIDs() async {
        isLoading = true
        errorMessage = nil
        do {
            self.availableUIDs = try await APIService.shared.getRequest(type: [AvailableUID].self, endpoint: "bags/uids")
        } catch {
            self.errorMessage = "Erro ao buscar UIDs: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

// MARK: - Views
struct InventoryView: View {
    @StateObject private var viewModel = InventoryViewModel()
    @State private var showRegisterItem = false
    @State private var selectedItem: BagModel? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Inventário").font(.title).bold()
                Spacer()
                Button(action: { showRegisterItem = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.primary)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color(.systemGray6))

            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Buscar...", text: $viewModel.search)
            }
            .padding(10)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 10)

            ZStack {
                if viewModel.isLoading {
                    ProgressView("Carregando...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage).foregroundColor(.red).multilineTextAlignment(.center)
                        Button("Tentar Novamente") { Task { await viewModel.fetchBags() } }.padding(.top)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.filteredBags) { item in
                                Button(action: { selectedItem = item }) {
                                    InventoryListItem(item: item)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .task { await viewModel.fetchBags() }
        .sheet(isPresented: $showRegisterItem) {
            RegisterItemView { name, rfid, state, type in
                showRegisterItem = false
                Task {
                    await viewModel.addBag(name: name, rfid: rfid, state: state, type: type)
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            NavigationView {
                DetailItemView(currentItem: item, viewModel: viewModel)
            }
        }
    }
}

struct RegisterItemView: View {
    @StateObject private var viewModel = RegisterItemViewModel()
    
    @State private var name = ""
    @State private var state: BagState = .guardada
    @State private var type: BagType = .mochila
    @State private var selectedRfid = ""
    
    var onSave: (String, String, BagState, BagType) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nome")) {
                    TextField("Nome da mochila", text: $name)
                }
                
                Section(header: Text("RFID (UID)")) {
                    if viewModel.isLoading { ProgressView() }
                    else if let errorMessage = viewModel.errorMessage { Text(errorMessage).foregroundColor(.red) }
                    else {
                        Picker("Selecione o UID", selection: $selectedRfid) {
                            Text("Nenhum").tag("")
                            ForEach(viewModel.availableUIDs) { uidInfo in
                                Text(uidInfo.uid).tag(uidInfo.uid)
                            }
                        }
                    }
                }
                
                Section(header: Text("Tipo")) {
                    Picker("Tipo", selection: $type) {
                        ForEach(BagType.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                }
                
                Section(header: Text("Status")) {
                    Picker("Status", selection: $state) {
                        ForEach(BagState.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                }
            }
            .navigationTitle("Cadastrar Mochila")
            .task { await viewModel.fetchAvailableUIDs() }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { onSave(name, selectedRfid, state, type) }
                    .disabled(name.isEmpty || selectedRfid.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}

struct DetailItemView: View {
    @State private var currentItem: BagModel
    @ObservedObject var viewModel: InventoryViewModel
    @Environment(\.dismiss) var dismiss

    init(currentItem: BagModel, viewModel: InventoryViewModel) {
        _currentItem = State(initialValue: currentItem)
        self.viewModel = viewModel
    }

    var body: some View {
        Form {
            Section(header: Text("Informações Editáveis")) {
                TextField("Nome", text: $currentItem.name)
                
                Picker("Tipo", selection: $currentItem.type) {
                    ForEach(BagType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                Picker("Status", selection: $currentItem.state) {
                    ForEach(BagState.allCases) { state in
                        Text(state.rawValue).tag(state)
                    }
                }
            }
            
            Section(header: Text("Informações do Sistema")) {
                VStack(alignment: .leading) {
                    Text("ID do Documento:").fontWeight(.semibold)
                    Text(currentItem.uid).font(.caption).foregroundColor(.gray)
                }
                VStack(alignment: .leading) {
                    Text("Revisão:").fontWeight(.semibold)
                    Text(currentItem.rev).font(.caption).foregroundColor(.gray)
                }
                VStack(alignment: .leading) {
                    Text("Última Atualização (Hora):").fontWeight(.semibold)
                    Text(currentItem.hour)
                }.font(.caption).foregroundColor(.gray)
            }
        }
        .navigationTitle("Editar Mochila")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") {
                    Task {
                        await viewModel.updateBag(bag: currentItem)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InventoryListItem: View {
    let item: BagModel

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.type.iconName)
                .font(.title)
                .frame(width: 48, height: 48)
                .background(item.state.associatedColor.opacity(0.2))
                .foregroundColor(item.state.associatedColor)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).fontWeight(.bold).foregroundColor(.primary)
                Text("Status: \(item.state.rawValue)").font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.background)
        .cornerRadius(12)
    }
}

#Preview {
    InventoryView()
}
