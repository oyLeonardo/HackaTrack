import SwiftUI
import Foundation

import SwiftUI

// MARK: - Gerenciadores de Estado Global
class AppSettings: ObservableObject {
    @AppStorage("isDarkModeEnabled") var isDarkMode: Bool = false
}

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
}


// MARK: - Main View (Ponto de Entrada Principal)
struct MainTabView: View {
    @StateObject private var inventoryViewModel = InventoryViewModel()
    @StateObject private var appSettings = AppSettings()
    @StateObject private var authManager = AuthenticationManager()
    
    @State private var selectedTab = 0

    var body: some View {
        Group {
             if authManager.isAuthenticated {
                TabView(selection: $selectedTab) {
                    DashboardView(viewModel: inventoryViewModel, selectedTab: $selectedTab)
                        .tabItem { Label("Dashboard", systemImage: "house") }.tag(0)
                    
                    InventoryView(viewModel: inventoryViewModel)
                        .tabItem { Label("Inventário", systemImage: "list.bullet") }.tag(1)
                    
                    SettingsView()
                        .tabItem { Label("Configurações", systemImage: "gear") }.tag(2)
                }
                .tint(Color("TextColor"))
                .task {
                    // Chama a função unificada que busca todos os dados
                    await inventoryViewModel.fetchInitialData()
                }
                .onReceive(Timer.publish(every: 180, on: .main, in: .common).autoconnect()) { _ in
                    Task {
                        await inventoryViewModel.fetchInitialData()
                    }
                }
             } else {
                 LoginView()
             }
        }
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .environmentObject(appSettings)
        .environmentObject(authManager)
    }
}



#Preview {
    MainTabView()
}
