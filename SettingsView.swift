import SwiftUI

struct SettingsView: View {
    @State private var darkModeEnabled = false
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
            .background(Color(.systemGray6))

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
        .background(Color(.systemGray6).ignoresSafeArea())
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
                    .foregroundColor(.black)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color.white)
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
                    .foregroundColor(.black)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
