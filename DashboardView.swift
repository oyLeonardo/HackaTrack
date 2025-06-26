import SwiftUI
import Foundation

// MARK: - Modelos (Apenas o necessário para esta View)

// Modelo para decodificar os dados de notificação
struct NotificationModel: Codable, Identifiable {
    let id: String
    let rev: String
    let uid: String
    let hour: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rev = "_rev"
        case uid, hour, status
    }
}


// MARK: - Dashboard View
struct DashboardView: View {
    // Recebe o ViewModel compartilhado como um @ObservedObject.
    @ObservedObject var viewModel: InventoryViewModel
    // Recebe o @Binding para poder alterar a aba programaticamente.
    @Binding var selectedTab: Int
    
    @Environment(\.colorScheme) var colorScheme
    @State private var activitySearch = ""

    // Propriedades computadas para contar os itens dinamicamente
    private var storedCount: String { "\(viewModel.bags.filter { $0.state == .guardada }.count)" }
    private var inUseCount: String { "\(viewModel.bags.filter { $0.state == .emUso }.count)" }
    private var lostCount: String { "\(viewModel.bags.filter { $0.state == .perdida }.count)" }
    private var interdictedCount: String { "\(viewModel.bags.filter { $0.state == .interditada }.count)" }
    
    // ** AQUI ESTÁ A MUDANÇA **
    // Propriedade computada que ordena e depois filtra as notificações
    private var sortedAndFilteredActivities: [NotificationModel] {
        // 1. Ordena as notificações pela hora, da mais recente para a mais antiga
        let sorted = viewModel.notifications.sorted { $0.hour > $1.hour }
        
        // 2. Se a busca estiver vazia, retorna a lista ordenada
        if activitySearch.isEmpty {
            return sorted
        }
        
        // 3. Se houver texto na busca, filtra a lista já ordenada
        return sorted.filter {
            $0.status.localizedCaseInsensitiveContains(activitySearch) ||
            $0.hour.localizedCaseInsensitiveContains(activitySearch) ||
            $0.uid.localizedCaseInsensitiveContains(activitySearch)
        }
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 0) {
                HStack {
                    Button(action: { Task { await viewModel.fetchInitialData() } }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color("TextColor"))
                            .frame(width: 24, height: 24)
                            .frame(width: 48, height: 48)
                    }
                    Spacer()
                    if colorScheme == .dark {
                        Image("logodark").resizable().scaledToFit().frame(height: 80)
                    } else {
                        Image("logonormal").resizable().scaledToFit().frame(height: 80)
                    }
                    Spacer()
                    Text("").frame(width: 24, height: 24).frame(width: 48, height: 48)
                }
                .padding(.horizontal).padding(.top, 10)
                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 16) {
                        Button(action: { viewModel.selectedStateFilter = .guardada; selectedTab = 1 }) {
                            StatCard(title: "Mochilas guardadas", value: storedCount)
                                .padding(.leading,15)
                        }.buttonStyle(.plain)
                        Button(action: { viewModel.selectedStateFilter = .emUso; selectedTab = 1 }) {
                            StatCard(title: "Mochilas em Uso", value: inUseCount)
                        }.buttonStyle(.plain)
                        Button(action: { viewModel.selectedStateFilter = .perdida; selectedTab = 1 }) {
                            StatCard(title: "Mochilas Perdidas", value: lostCount)
                        }.buttonStyle(.plain)
                        Button(action: { viewModel.selectedStateFilter = .interditada; selectedTab = 1 }) {
                            StatCard(title: "Mochilas Interditadas", value: interdictedCount)
                                .padding(.trailing,15)
                        }.buttonStyle(.plain)
                    }
                }.padding(.vertical,10)
                
                Text("Atividade recente")
                    .font(.title3).bold().frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal).padding(.vertical, 4).padding(.bottom, 5)
            
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray).padding(.leading, 12)
                    TextField("Buscar atividade...", text: $activitySearch).padding(.vertical, 10)
                }
                .background(Color(UIColor.systemGray4)).cornerRadius(12)
                .padding(.horizontal).padding(.bottom, 10)
                
                ZStack {
                    if viewModel.isLoading { ProgressView().padding(.top, 10) }
                    else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 10) {
                            Text(errorMessage).foregroundColor(.red).multilineTextAlignment(.center).padding(.horizontal)
                            Button("Tentar Novamente") { Task { await viewModel.fetchInitialData() } }
                                .buttonStyle(.borderedProminent).tint(.red)
                        }
                    } else {
                        // A lista agora usa a nova propriedade ordenada e filtrada
                        VStack(spacing: 12) {
                            ForEach(sortedAndFilteredActivities) { notification in
                                ActivityItem(notification: notification)
                            }
                        }.padding(.horizontal).padding(.bottom)
                    }
                }
                Spacer()
                Divider()
            }
        }.background(Color("BackgroundColor").ignoresSafeArea())
    }
}

// MARK: - Subviews do Dashboard
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline).fontWeight(.medium).foregroundColor(Color(.black)).fixedSize(horizontal: false, vertical: true)
            Text(value).font(.title).fontWeight(.bold).foregroundColor(Color(.black))
        }
        .padding().frame(maxWidth: 240,minHeight: 90, alignment: .topLeading)
        .background(Color("ButtonColor")).cornerRadius(12)
    }
}

enum ActivityIconType {
    case check, xmark, returned, picked
    
    var systemName: String {
        switch self {
        case .check: "checkmark"
        case .xmark: "xmark"
        case .returned: "square.and.arrow.down.fill"
        case .picked: "square.and.arrow.up"
        }
    }
    var color: Color {
        switch self {
        case .check: .green
        case .xmark: .red
        case .returned: .blue
        case .picked: .orange
        }
    }
}

// ActivityItem agora é mais inteligente e recebe um NotificationModel
struct ActivityItem: View {
    let notification: NotificationModel
    
    private var iconType: ActivityIconType {
        switch notification.status.lowercased() {
        case "negado": return .xmark
        case "devolvida": return .returned
        case "emprestada": return .picked
        default: return .check
        }
    }
    
    private var title: String {
        switch notification.status.lowercased() {
        case "negado": return "Acesso Negado"
        case "devolvida": return "Mochila Devolvida"
        case "emprestada": return "Mochila Emprestada"
        default: return notification.status.capitalized
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(iconType.color).opacity(0.3).frame(width: 48, height: 48)
                Image(systemName: iconType.systemName).foregroundColor(Color("TextColor"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).fontWeight(.medium).foregroundColor(Color("TextColor"))
                Text(notification.hour).font(.caption).foregroundColor(.gray)
                Text("Tag ID: \(notification.uid)").font(.caption).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding().background(Color("MenuBar"))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(iconType.color, lineWidth: 3))
        .cornerRadius(10)
    }
}

#Preview {
    MainTabView()
//    // Mock ViewModel para o preview funcionar isoladamente
//    class MockInventoryViewModel: InventoryViewModel {
//        override init() {
//            super.init()
//            self.notifications = [
//                NotificationModel(id: "1", rev: "1", uid: "F4CECBF0", hour: "10:30:02", status: "Negado"),
//                NotificationModel(id: "2", rev: "1", uid: "F4CECBF1", hour: "10:35:15", status: "Devolvida"),
//                NotificationModel(id: "3", rev: "1", uid: "F4CECBF2", hour: "10:25:00", status: "Emprestada")
//            ]
//        }
//    }
//    
//    return DashboardView(viewModel: MockInventoryViewModel(), selectedTab: .constant(0))
}
