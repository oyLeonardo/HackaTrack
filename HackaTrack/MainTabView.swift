import SwiftUI

struct MainTabView: View {

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
            TabView {
                DashboardView()
                    .safeAreaInset(edge: .bottom) {
                        Spacer().frame(height: 10)
                    }
                    .tabItem {
                        Label("Dashboard", systemImage: "house")
                    }
                
                InventoryView()
                    .safeAreaInset(edge: .bottom) {
                        Spacer().frame(height: 10)
                    }
                    .tabItem {
                        Label("Inventário", systemImage: "list.bullet")
                    }
                
                SettingsView()
                    .safeAreaInset(edge: .bottom) {
                        Spacer().frame(height: 10)
                    }
                    .tabItem {
                        Label("Configurações", systemImage: "gear")
                    }
                ProfileView()
                    .safeAreaInset(edge: .bottom) {
                        Spacer().frame(height: 10)
                    }
                    .tabItem {
                        Label("Perfil", systemImage: "person.crop.circle.fill")
                    }
            }
            .tint(Color("TextColor"))
        }
    }
}


#Preview {
    MainTabView()
}
// Animation, transition
