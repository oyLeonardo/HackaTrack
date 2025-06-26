import Foundation

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