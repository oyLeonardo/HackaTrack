import SwiftUI

struct MainTabView: View {
    var body: some View {
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
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(.black)
    }
}

#Preview {
    MainTabView()
}
// Animation, transition
