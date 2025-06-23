import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let time: String
}

struct AlertsView: View {
    private let todayAlerts = [
        AlertItem(title: "Unauthorized Movement Detected", time: "10:30 AM"),
        AlertItem(title: "System Anomaly Detected", time: "9:15 AM")
    ]

    private let yesterdayAlerts = [
        AlertItem(title: "Bag Removed from Designated Area", time: "4:45 PM"),
        AlertItem(title: "RFID Tag Malfunction", time: "2:00 PM")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Top
            HStack {
                Spacer()
                Text("Alertas")
                    .font(.title)
                    .bold()
                    .padding(.leading, 24)
                Spacer()
                Button(action: {
                    print("ViewAlerts")
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                }
                .frame(width: 48, height: 48)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))

            // Today Section
            SectionHeader("Today")
            VStack(spacing: 8) {
                ForEach(todayAlerts) { alert in
                    AlertListItem(alert: alert)
                }
            }
            .padding(.horizontal)

            // Yesterday Section
            SectionHeader("Yesterday")
            VStack(spacing: 8) {
                ForEach(yesterdayAlerts) { alert in
                    AlertListItem(alert: alert)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Bottom Navigation
            Divider()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }

    @ViewBuilder
    func SectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .bold()
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AlertListItem: View {
    let alert: AlertItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray4))
                    .frame(width: 48, height: 48)
                Image(systemName: "bell")
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                Text(alert.time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

#Preview {
    AlertsView()
}
