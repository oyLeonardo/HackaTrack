import SwiftUI
import Foundation

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

// MARK: - ViewModels
@MainActor
class InventoryViewModel: ObservableObject {
    @Published var bags: [BagModel] = []
    @Published var notifications: [NotificationModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var search = ""
    @Published var activitySearch = ""
    @Published var selectedStateFilter: BagState? = nil // Filtro de estado
    
    private let endpoints = Endpoints()

    var filteredBags: [BagModel] {
        bags.filter { bag in
            let stateMatches = (selectedStateFilter == nil || bag.state == selectedStateFilter)
            let searchMatches = (search.isEmpty || bag.name.localizedCaseInsensitiveContains(search))
            return stateMatches && searchMatches
        }
    }
    
    var filteredNotifications: [NotificationModel] {
        if activitySearch.isEmpty { return notifications }
        return notifications.filter {
            $0.uid.localizedCaseInsensitiveContains(activitySearch) ||
            $0.hour.localizedCaseInsensitiveContains(activitySearch) ||
            $0.status.localizedCaseInsensitiveContains(activitySearch)
        }
    }
    
    // Função unificada para buscar todos os dados iniciais
    func fetchInitialData() async {
        isLoading = true
        errorMessage = nil
        // Executa as duas chamadas de rede em paralelo para maior eficiência
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchBgs() }
            group.addTask { await self.fetchNotifications() }
        }
        isLoading = false
    }

    func fetchBgs() async {
        isLoading = true
        errorMessage = nil

        // Não reseta isLoading aqui para permitir que fetchInitialData controle o estado geral
        do {
            self.bags = try await APIService.shared.getRequest(type: [BagModel].self, endpoint: endpoints.getAll)
        } catch {
            self.errorMessage = "Erro ao carregar o inventário: \(error.localizedDescription)"
        }
    }
    
    // Função para buscar notificações
    func fetchNotifications() async {
        do {
            self.notifications = try await APIService.shared.getRequest(type: [NotificationModel].self, endpoint: endpoints.getNot)
        } catch {
             self.errorMessage = "Erro ao carregar atividades: \(error.localizedDescription)"
        }
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
            _ = try await APIService.shared.sendDataRequest(
                body: payload,
                responseType: CreateResponse.self,
                endpoint: endpoints.create,
                method: .post
            )
            // ** AQUI ESTÁ A MUDANÇA **
            await fetchInitialData()
        } catch {
            self.errorMessage = "Erro ao criar a mochila: \(error.localizedDescription)"
            
            await fetchInitialData()
        }
    }
    
    func updateBag(bag: BagModel) async {
        errorMessage = nil
        
        struct UpdateResponse: Codable { let ok: Bool, id: String, rev: String }
        
        do {
            _ = try await APIService.shared.sendDataRequest(
                body: bag,
                responseType: UpdateResponse.self,
                endpoint: endpoints.update,
                method: .put
            )
            // ** AQUI ESTÁ A MUDANÇA **
            await fetchInitialData()
        } catch {
            self.errorMessage = "Erro ao atualizar a mochila: \(error.localizedDescription)"
            await fetchInitialData()
        }
    }
    
    func deleteBag(bag: BagModel) async {
        errorMessage = nil
        struct DeleteResponse: Codable { let ok: Bool? }
        
        do {
            _ = try await APIService.shared.sendDataRequest(
                body: bag,
                responseType: DeleteResponse.self,
                endpoint: endpoints.delete,
                method: .delete
            )
            // ** AQUI ESTÁ A MUDANÇA **
            await fetchInitialData() // Recarrega a lista após a exclusão
        } catch {
            self.errorMessage = "Erro ao deletar a mochila: \(error.localizedDescription)"
        }
    }
}

@MainActor
class RegisterItemViewModel: ObservableObject {
    @Published var availableUIDs: [AvailableUID] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let endpoints = Endpoints()
    
    func fetchAvailableUIDs() async {
        isLoading = true
        errorMessage = nil
        do {
            self.availableUIDs = try await APIService.shared.getRequest(type: [AvailableUID].self, endpoint: endpoints.getUIDS)
        } catch {
            self.errorMessage = "Erro ao buscar UIDs: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

// MARK: - Views
struct InventoryView: View {
    @ObservedObject var viewModel: InventoryViewModel // Agora recebe o ViewModel
    @State private var showRegisterItem = false
    @State private var selectedItem: BagModel? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: { Task {await viewModel.fetchBgs()} }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color("TextColor"))
                        .frame(width: 24, height: 24)
                        .frame(width: 48, height: 48)
                }
                Spacer()
                Text("Inventário")
                    .font(.title).bold()
                Spacer()
                Button(action: { showRegisterItem = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color("TextColor"))
                        .frame(width: 24, height: 24)
                        .frame(width: 48, height: 48)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            // Search Field
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    .padding(.leading, 12)
                TextField("Search", text: $viewModel.search)
                    .padding(.vertical, 10)
            }
            .background(Color(UIColor.systemGray4))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Filter Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: { viewModel.selectedStateFilter = nil }) {
                        Text("Todos")
                            .font(.subheadline).fontWeight(.semibold)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(viewModel.selectedStateFilter == nil ? Color.black : Color(UIColor.systemGray5))
                            .foregroundColor(viewModel.selectedStateFilter == nil ? .white : Color("TextColor"))
                            .cornerRadius(10)
                    }
                    ForEach(BagState.allCases) { state in
                        Button(action: { viewModel.selectedStateFilter = state }) {
                            Text(state.rawValue)
                                .font(.subheadline).fontWeight(.semibold)
                                .padding(.horizontal, 16).padding(.vertical, 8)
                                .background(viewModel.selectedStateFilter == state ? state.associatedColor : Color(UIColor.systemGray5))
                                .foregroundColor(viewModel.selectedStateFilter == state ? .white : Color("TextColor"))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 10)

            ZStack {
                if viewModel.isLoading {
                    ProgressView("Carregando...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage).foregroundColor(.red).multilineTextAlignment(.center)
                        Button("Tentar Novamente") { Task { await viewModel.fetchBgs() } }.padding(.top)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.filteredBags) { item in
                                Button(action: { selectedItem = item }) {
                                    InventoryListItem(item: item)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            Spacer()
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        // A task foi removida daqui, pois agora é gerenciada pela MainTabView
        .fullScreenCover(isPresented: $showRegisterItem) {
            RegisterItemView { name, rfid, state, type in
                showRegisterItem = false
                Task {
                    await viewModel.addBag(name: name, rfid: rfid, state: state, type: type)
                }
            }
        }
        .fullScreenCover(item: $selectedItem) { item in
            DetailItemView(itemToEdit: item, viewModel: viewModel)
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
            VStack {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(state.associatedColor.opacity(0.2))
                        .frame(width: 48, height: 48)
                        .overlay(Image(systemName: type.iconName).foregroundColor(Color("TextColor")))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name.isEmpty ? "Nova Mochila" : name)
                            .fontWeight(.medium).foregroundColor(Color("TextColor"))
                        Text("Status: \(state.rawValue)").font(.caption).foregroundColor(Color("TextColor"))
                    }
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(state.associatedColor, lineWidth: 3))
                .cornerRadius(12).padding([.horizontal, .top])
                
                Form {
                    Section(header: Text("Nome")) { TextField("Nome da mochila", text: $name) }
                    Section(header: Text("RFID (UID)")) {
                        if viewModel.isLoading { ProgressView() }
                        else if let errorMessage = viewModel.errorMessage { Text(errorMessage).foregroundColor(.red) }
                        else {
                            Picker("Selecione o UID", selection: $selectedRfid) {
                                Text("Nenhum").tag("")
                                ForEach(viewModel.availableUIDs) { Text($0.uid).tag($0.uid) }
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
                .scrollContentBackground(.hidden)
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
            .navigationTitle("Cadastrar Mochila")
            .task { await viewModel.fetchAvailableUIDs() }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { onSave(name, selectedRfid, state, type) }.disabled(name.isEmpty || selectedRfid.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
            }
        }
    }
}

struct DetailItemView: View {
    let itemToEdit: BagModel
    @ObservedObject var viewModel: InventoryViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var state: BagState
    @State private var type: BagType
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var showingDeleteAlert = false

    init(itemToEdit: BagModel, viewModel: InventoryViewModel) {
        self.itemToEdit = itemToEdit
        self.viewModel = viewModel
        _name = State(initialValue: itemToEdit.name)
        _state = State(initialValue: itemToEdit.state)
        _type = State(initialValue: itemToEdit.type)
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(state.associatedColor.opacity(0.2))
                            .frame(width: 48, height: 48)
                            .overlay(Image(systemName: type.iconName).foregroundColor(Color("TextColor")))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name.isEmpty ? "Sem Nome" : name)
                                .fontWeight(.medium).foregroundColor(Color("TextColor"))
                            Text("Status: \(state.rawValue)").font(.caption).foregroundColor(Color("TextColor"))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(state.associatedColor, lineWidth: 3))
                    .cornerRadius(12).padding([.horizontal, .top])
                    
                    Form {
                        Section(header: Text("Informações Editáveis")) {
                            TextField("Nome", text: $name)
                            Picker("Tipo", selection: $type) {
                                ForEach(BagType.allCases) { Text($0.rawValue).tag($0) }
                            }.pickerStyle(.segmented)
                            Picker("Status", selection: $state) {
                                ForEach(BagState.allCases) { Text($0.rawValue).tag($0) }
                            }.pickerStyle(.segmented)
                        }
                        Section(header: Text("Informações do Sistema")) {
                            VStack(alignment: .leading) {
                                Text("ID do Documento:").fontWeight(.semibold)
                                Text(itemToEdit.uid).font(.caption).foregroundColor(.gray)
                            }
                            VStack(alignment: .leading) {
                                Text("Revisão:").fontWeight(.semibold)
                                Text(itemToEdit.rev).font(.caption).foregroundColor(.gray)
                            }
                            VStack(alignment: .leading) {
                                Text("Última Atualização (Hora):").fontWeight(.semibold)
                                Text(itemToEdit.hour)
                            }.font(.caption).foregroundColor(.gray)
                        }
                        
                        Section {
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                                Task { await viewModel.fetchBgs() }
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "trash")
                                    Text("Deletar Mochila")
                                    Spacer()
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .background(Color("BackgroundColor").ignoresSafeArea())
                .navigationTitle("Detalhes da Mochila")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Fechar") { dismiss() }.disabled(isDeleting || isSaving) }
                    ToolbarItem(placement: .confirmationAction) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Button("Salvar") {
                                Task {
                                    isSaving = true
                                    let updatedBag = BagModel(uid: itemToEdit.uid, rev: itemToEdit.rev, name: name, state: state, type: type, hour: Date().formatted(.dateTime.hour().minute()))
                                    await viewModel.updateBag(bag: updatedBag)
                                    dismiss()
                                }
                            }.disabled(isDeleting)
                        }
                    }
                }
                .alert("Confirmar Exclusão", isPresented: $showingDeleteAlert) {
                    Button("Deletar", role: .destructive) {
                        Task {
                            isDeleting = true
                            await viewModel.deleteBag(bag: itemToEdit)
                            dismiss()
                        }
                    }
                    Button("Cancelar", role: .cancel) {}
                } message: {
                    Text("Tem certeza de que deseja deletar a mochila \"\(itemToEdit.name)\"? Esta ação não pode ser desfeita.")
                }
                .disabled(isDeleting || isSaving)

                if isDeleting {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    ProgressView("Deletando...")
                        .padding(25)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        }
    }
}

struct InventoryListItem: View {
    let item: BagModel

    var body: some View {
        ZStack {
            Color("menuBar")
            
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(item.state.associatedColor.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: item.type.iconName)
                        .foregroundColor(Color("TextColor"))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name).fontWeight(.medium).foregroundColor(Color("TextColor"))
                    Text("Status: \(item.state.rawValue)").font(.caption).foregroundColor(Color("TextColor").opacity(0.8))
                }
                Spacer()
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(item.state.associatedColor, lineWidth: 3))
        }
        .cornerRadius(10)
    }
}

#Preview {
    MainTabView()
}
