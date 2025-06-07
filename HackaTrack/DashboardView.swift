import SwiftUI

struct DashboardView: View {
    @State private var showFilter = false
    @State private var showStored = false
    @State private var showBorrowed = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer()
                HStack{
                    if colorScheme == .dark {
                        Image("logodark").resizable().frame(width: 250,height: 100)
                    } else {
                        Image("logonormal").resizable().frame(width: 250,height: 100)
                }
                }
                
                Spacer()
//                Button(action: {
//                    showFilter = true
//                }) {
//                    Image(systemName: "line.3.horizontal.decrease.circle")
//                        .foregroundColor(.black)
//                        .frame(width: 24, height: 24)
//                }
//                .frame(width: 48, height: 48)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Cards
            HStack(spacing: 16) {
                Button(action: {
                    showStored = true
                }) {
                    StatCard(title: "Mochilas guardadas", value: "20")
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    showBorrowed = true
                }) {
                    StatCard(title: "Mochilas emprestadas", value: "5")
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            // Recent Activity
            Text("Atividade recente")
                .font(.title3)
                .bold()
                .padding(.horizontal)
                .padding(.vertical, 4)
                .padding(.bottom, 5)
            
            ScrollView {
                VStack(spacing: 12) {
                    ActivityItem(type: .returned, title: "Mochila devolvida", time: "10:30 AM", tagID: "1234567890")
                    // na integracao vamos enviar o estado .returned ou .picked
                    ActivityItem(type: .picked, title: "Mochila emprestada", time: "10:25 AM", tagID: "9876543210")
                    ActivityItem(type: .returned, title: "Mochila devolvida", time: "10:20 AM", tagID: "4567890123")
                    ActivityItem(type: .returned, title: "Mochila devolvida", time: "10:15 AM", tagID: "7890123456")
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            // Bottom Navigation
            Divider()
        }
        .fullScreenCover(isPresented: $showStored) {
            BackpackListView(title: "Mochilas guardadas", backpacks: mockStored)
            
        }
        .fullScreenCover(isPresented: $showBorrowed) {
            BackpackListView(title: "Mochilas emprestadas", backpacks: mockBorrowed)
        }
    }
}

struct BackpackListView: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let backpacks: [Backpack]

    var body: some View {
        NavigationView {
                List(backpacks) { bag in
                    HStack {
                        Image(systemName: "backpack.fill")
                            .foregroundColor(Color("TextColor"))
                            .frame(width: 32, height: 32)
                        VStack(alignment: .leading) {
                            Text(bag.name)
                                .fontWeight(.medium)
                            Text("Tag ID: \(bag.tagID)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Fechar") {
                            dismiss()
                        }
                        .foregroundColor(Color("TextColor")) // ou .white
                    }
                }
        }
    }
}

struct Backpack: Identifiable {
    let id = UUID()
    let name: String
    let tagID: String
}

// Mock data
func generateRandomTagID(length: Int) -> String {
    let digits = "0123456789"
    return String((0..<length).compactMap { _ in digits.randomElement() })
}

let mockStored: [Backpack] = (1...20).map { i in
    Backpack(name: "Mochila \(i)", tagID: generateRandomTagID(length: 10))
}

let mockBorrowed: [Backpack] = (1...3).map { i in
    Backpack(name: "Mochila \(i)", tagID: generateRandomTagID(length: 10))
}


struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color(.black))
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(.black))
        }
        .padding()
        .frame(minWidth: 158)
        .background(Color("ButtonColor"))
        .cornerRadius(12)
    }
}

enum ActivityIconType {
    case check
    case xmark
    case returned
    case picked
    
    var systemName: String {
        switch self {
        case .check: return "checkmark"
        case .xmark: return "xmark"
        case .returned: return "square.and.arrow.down.fill"
        case .picked: return "square.and.arrow.up"
        }
    }

    var color: Color {
        switch self {
        case .check: return .green
        case .xmark: return .red
        case .returned: return .blue
        case .picked: return .orange
        }
    }
}

struct ActivityItem: View {
    let type: ActivityIconType
    let title: String
    let time: String
    let tagID: String
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(type.color).opacity(0.3)
                    .frame(width: 48, height: 48)
                Image(systemName: type.systemName)
                    .foregroundColor(Color("TextColor"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(Color("TextColor"))
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Tag ID: \(tagID)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color("MenuBar"))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(type.color, lineWidth: 3)
        )
        .cornerRadius(10)
        
    }
}


#Preview {
    DashboardView()
}
