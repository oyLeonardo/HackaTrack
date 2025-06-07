import SwiftUI

struct Bag: Identifiable {
    let id = UUID()
    let name: String
    let lastSeen: String
}

struct MyBagsView: View {
    @State private var searchQuery = ""
    
    private var bags: [Bag] = [
        .init(name: "Bag 12345", lastSeen: "2024-04-20 10:00 AM"),
        .init(name: "Bag 67890", lastSeen: "2024-04-20 11:30 AM"),
        .init(name: "Bag 11223", lastSeen: "2024-04-20 01:00 PM"),
        .init(name: "Bag 44556", lastSeen: "2024-04-20 02:45 PM"),
        .init(name: "Bag 77889", lastSeen: "2024-04-20 04:15 PM")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Spacer()
                Text("My Bags")
                    .font(.headline)
                    .bold()
                    .padding(.leading, 24)
                Spacer()
                Button(action: {
                    print("Add Bag tapped")
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                }
                .frame(width: 48, height: 48)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))

            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
                TextField("Search bags", text: $searchQuery)
                    .padding(.vertical, 10)
            }
            .background(Color(UIColor.systemGray4))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 8)

            // Bag List
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(bags.filter { searchQuery.isEmpty || $0.name.localizedCaseInsensitiveContains(searchQuery) }) { bag in
                        BagListItem(bag: bag)
                    }
                }
                .padding(.horizontal)
            }

            // Bottom navigation
            Divider()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

struct BagListItem: View {
    let bag: Bag

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray4))
                    .frame(width: 48, height: 48)
                Image(systemName: "briefcase")
                    .foregroundColor(.black)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(bag.name)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                Text("Last seen: \(bag.lastSeen)")
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
    MyBagsView()
}
