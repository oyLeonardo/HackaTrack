import SwiftUI

// MARK: - Main Tab View (Ponto de Entrada Principal)
struct MainTabView: View {
    @StateObject private var inventoryViewModel = InventoryViewModel()
    @StateObject private var appSettings = AppSettings()
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                DashboardView(viewModel: inventoryViewModel, selectedTab: $selectedTab)
                    .safeAreaInset(edge: .bottom) {
                        Spacer().frame(height: 10)
                    }
                    .tabItem {
                        Label("Dashboard", systemImage: "house")
                    }
                    .tag(0)
                
                InventoryView(viewModel: inventoryViewModel)
                    .safeAreaInset(edge: .bottom) {
                        Spacer().frame(height: 10)
                    }
                    .tabItem {
                        Label("Inventário", systemImage: "list.bullet")
                    }
                    .tag(1)
                
                SettingsView()
                    .safeAreaInset(edge: .bottom) {
                        Spacer().frame(height: 10)
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
            }
            .tint(Color("TextColor"))

            .task {
                await inventoryViewModel.fetchBgs()
            }
            // O tema do aplicativo agora reage às mudanças na configuração.
            .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
            // Fornece o objeto de configurações para todas as views filhas.
            .environmentObject(appSettings)
        }
    }
}

#Preview {
    MainTabView()
}
