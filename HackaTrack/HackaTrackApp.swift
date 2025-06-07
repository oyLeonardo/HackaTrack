import SwiftUI

@main
struct HackaTrackApp: App {
    // Lendo o valor do AppStorage aqui também para reagir a ele
    @AppStorage("isDarkModeEnabled") var darkModeEnabled: Bool = false

    var body: some Scene {
        WindowGroup {
            MainTabView() // Sua view principal, onde você navega para SettingsView
                .accentColor(Color("TextColor"))
                // Aplica o esquema de cores preferido com base em darkModeEnabled
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
