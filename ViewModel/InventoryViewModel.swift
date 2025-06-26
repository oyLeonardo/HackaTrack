import Foundation

// MARK: - ViewModels
@MainActor
class InventoryViewModel: ObservableObject {
    @Published var bags: [BagModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var search = ""
    @Published var selectedStateFilter: BagState? = nil // Filtro de estado
    
    var filteredBags: [BagModel] {
        bags.filter { bag in
            let stateMatches = (selectedStateFilter == nil || bag.state == selectedStateFilter)
            let searchMatches = (search.isEmpty || bag.name.localizedCaseInsensitiveContains(search))
            return stateMatches && searchMatches
        }
    }
    
    func fetchBgs() async {
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
            // ** AQUI ESTÁ A MUDANÇA **
            _ = try await APIService.shared.sendDataRequest(
                body: payload,
                responseType: CreateResponse.self,
                endpoint: "create/bag",
                method: .post
            )
            await fetchBgs()
        } catch {
            self.errorMessage = "Erro ao criar a mochila: \(error.localizedDescription)"
        }
    }
    
    func updateBag(bag: BagModel) async {
        errorMessage = nil
        
        struct UpdateResponse: Codable { let ok: Bool, id: String, rev: String }
        
        do {
            // ** AQUI ESTÁ A MUDANÇA **
            _ = try await APIService.shared.sendDataRequest(
                body: bag,
                responseType: UpdateResponse.self,
                endpoint: "update/bag",
                method: .put
            )
            await fetchBgs()
        } catch {
            self.errorMessage = "Erro ao atualizar a mochila: \(error.localizedDescription)"
        }
    }
    
    func deleteBag(bag: BagModel) async {
        errorMessage = nil
        struct DeleteResponse: Codable { let ok: Bool? }
        
        do {
            // ** AQUI ESTÁ A MUDANÇA **
            _ = try await APIService.shared.sendDataRequest(
                body: bag,
                responseType: DeleteResponse.self,
                endpoint: "delete/bag",
                method: .delete
            )
            await fetchBgs() // Recarrega a lista após a exclusão
        } catch {
            self.errorMessage = "Erro ao deletar a mochila: \(error.localizedDescription)"
        }
    }
}