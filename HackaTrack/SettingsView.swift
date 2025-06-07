import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkModeEnabled") var darkModeEnabled: Bool = false
    @State private var scanAlertsEnabled = true
    @State private var zoneAlertsEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer()
                Text("Configurações")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            ScrollView {
                VStack(spacing: 24) {
                    // System
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sistema")
                            .font(.title3)
                            .bold()
                        ToggleRow(title: "Modo escuro", description: "Muda o tema do aplicativo para modo escuro", isOn: $darkModeEnabled)
                        ToggleRow(title: "Alerta de scan", description: "Recebe um alerta quando uma mochila é escaneada", isOn: $scanAlertsEnabled)
                        NavigationLinkRow(title: "Reader Settings", description: "Configura o RFID reader e seus parametros.")
                        NavigationLinkRow(title: "Logs do sistema", description: "Mostra os logs de atividade do sistema")
                    }

                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 30) // espaço para tabbar
            }

            // Bottom Navigation
            Divider()
        }
//        .background(Color("BackgroundColor").ignoresSafeArea())
    }
}

class AppSettings: ObservableObject {
    // classe para armazenar configs no appstorage
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            print("Modo escurao alterado para: \(isDarkMode)")
        }
    }
}

// MARK: - Toggle Row
struct ToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(Color("TextColor"))
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color("TextColor"))
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden().tint(Color("ButtonColor"))
        }
        .padding()
        .background(Color.menuBar)
        .cornerRadius(10)
    }
}

// MARK: - Navigation Row
struct NavigationLinkRow: View {
    let title: String
    let description: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(Color("TextColor"))
                Text(description)
                    .font(.caption)
                    .foregroundColor(Color("TextColor"))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.menuBar)
        .cornerRadius(10)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
