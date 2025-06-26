import SwiftUI

// MARK: - Nova SettingsView
struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings // Recebe as configurações do ambiente
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
                        Text("Sistema").font(.title3).bold()
                        // O Toggle agora usa a propriedade do appSettings
                        ToggleRow(title: "Modo escuro", description: "Muda o tema do aplicativo para modo escuro", isOn: $appSettings.isDarkMode)
                        ToggleRow(title: "Alerta de scan", description: "Recebe um alerta quando uma mochila é escaneada", isOn: $scanAlertsEnabled)
                        NavigationLinkRow(title: "Reader Settings", description: "Configura o RFID reader e seus parametros.")
                        NavigationLinkRow(title: "Logs do sistema", description: "Mostra os logs de atividade do sistema")
                    }
                }
                .padding(.horizontal).padding(.top)
                .padding(.bottom, 30)
            }
            Spacer()
            Divider()
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

struct NavigationLinkRow: View {
    let title: String
    let description: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).fontWeight(.medium).foregroundColor(Color("TextColor"))
                Text(description).font(.caption).foregroundColor(Color("TextColor").opacity(0.8))
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }
        .padding().background(Color("MenuBar")).cornerRadius(10)
    }
}
