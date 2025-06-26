import SwiftUI

// MARK: - Views
struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings // Recebe as configurações do ambiente
    @EnvironmentObject var authManager: AuthenticationManager // Recebe o gerenciador de autenticação
    @State private var scanAlertsEnabled = true
    @State private var zoneAlertsEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer()
                Text("Configurações").font(.title).bold()
                Spacer()
            }
            .padding(.horizontal).padding(.vertical, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sistema").font(.title3).bold().foregroundColor(Color("TextColor"))
                        // O Toggle agora usa a propriedade do appSettings
                        ToggleRow(title: "Modo escuro", description: "Muda o tema do aplicativo para modo escuro", isOn: $appSettings.isDarkMode)
                        // Ação de Logout
                        ActionRow(title: "Logout", description: "Sair do aplicativo") {
                            withAnimation {
                                authManager.isAuthenticated = false
                            }
                        }
                    }
                }
                .padding(.horizontal).padding(.top)
                .padding(.bottom, 30)
            }
            Spacer()
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
    }
}


// MARK: - Componentes da SettingsView
struct ToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).fontWeight(.medium).foregroundColor(Color("TextColor"))
                Text(description).font(.caption).foregroundColor(Color("TextColor").opacity(0.8))
            }
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().tint(Color("ButtonColor"))
        }
        .padding().background(Color("MenuBar")).cornerRadius(10)
    }
}

// Componente genérico para uma linha que executa uma ação
struct ActionRow: View {
    let title: String
    let description: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).fontWeight(.medium).foregroundColor(Color("TextColor"))
                    Text(description).font(.caption).foregroundColor(Color("TextColor").opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray)
            }
        }
        .buttonStyle(.plain) // Remove o estilo padrão do botão para que o HStack seja clicável
        .padding().background(Color("MenuBar")).cornerRadius(10)
    }
}
