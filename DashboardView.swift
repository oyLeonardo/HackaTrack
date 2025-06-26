import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    @State private var activitySearch = ""
    
    private let allActivities: [ActivityItem] = [
        ActivityItem(type: .returned, title: "Mochila devolvida", time: "10:30 AM", tagID: "1234567890"),
        ActivityItem(type: .picked, title: "Mochila emprestada", time: "10:25 AM", tagID: "9876543210"),
        ActivityItem(type: .returned, title: "Mochila devolvida", time: "10:20 AM", tagID: "4567890123"),
        ActivityItem(type: .returned, title: "Mochila devolvida", time: "10:15 AM", tagID: "7890123456")
    ]

    private var storedCount: String { "\(viewModel.bags.filter { $0.state == .guardada }.count)" }
    private var inUseCount: String { "\(viewModel.bags.filter { $0.state == .emUso || $0.state == .emprestada }.count)" }
    private var lostCount: String { "\(viewModel.bags.filter { $0.state == .perdida }.count)" }
    private var interdictedCount: String { "\(viewModel.bags.filter { $0.state == .interditada }.count)" }
    
    private var filteredActivities: [ActivityItem] {
        if activitySearch.isEmpty { return allActivities }
        return allActivities.filter {
            $0.title.localizedCaseInsensitiveContains(activitySearch) ||
            $0.time.localizedCaseInsensitiveContains(activitySearch) ||
            $0.tagID.localizedCaseInsensitiveContains(activitySearch)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if colorScheme == .dark {
                    Image("logodark").resizable().scaledToFit().frame(height: 80)
                } else {
                    Image("logonormal").resizable().scaledToFit().frame(height: 80)
                }
                Spacer()
            }
            .padding(.horizontal).padding(.top, 10)
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Button(action: { viewModel.selectedStateFilter = .guardada; selectedTab = 1 }) {
                        StatCard(title: "Mochilas guardadas", value: storedCount)
                    }.buttonStyle(.plain)
                    Button(action: { viewModel.selectedStateFilter = .emUso; selectedTab = 1 }) {
                        StatCard(title: "Mochilas em Uso", value: inUseCount)
                    }.buttonStyle(.plain)
                }
                HStack(spacing: 16) {
                    Button(action: { viewModel.selectedStateFilter = .perdida; selectedTab = 1 }) {
                        StatCard(title: "Mochilas Perdidas", value: lostCount)
                    }.buttonStyle(.plain)
                    Button(action: { viewModel.selectedStateFilter = .interditada; selectedTab = 1 }) {
                        StatCard(title: "Mochilas Interditadas", value: interdictedCount)
                    }.buttonStyle(.plain)
                }
            }.padding()
            
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
                if viewModel.isLoading { ProgressView() }
                else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Text(errorMessage).foregroundColor(.red).multilineTextAlignment(.center).padding(.horizontal)
                        Button("Tentar Novamente") { Task { await viewModel.fetchBgs() } }
                            .buttonStyle(.borderedProminent).tint(.red)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredActivities) { $0 }
                        }.padding(.horizontal).padding(.bottom)
                    }
                }
            }
            Spacer()
            Divider()
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
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
        .padding().frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
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

struct ActivityItem: View, Identifiable {
    let id = UUID()
    let type: ActivityIconType
    let title: String
    let time: String
    let tagID: String
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(type.color).opacity(0.3).frame(width: 48, height: 48)
                Image(systemName: type.systemName).foregroundColor(Color("TextColor"))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).fontWeight(.medium).foregroundColor(Color("TextColor"))
                Text(time).font(.caption).foregroundColor(.gray)
                Text("Tag ID: \(tagID)").font(.caption).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding().background(Color("MenuBar"))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(type.color, lineWidth: 3))
        .cornerRadius(10)
    }
}

#Preview {
    MainTabView()
}