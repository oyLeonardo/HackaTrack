import SwiftUI

struct InventoryItem: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var status: String
    var icon: String
}

struct InventoryView: View {
    @State private var showRegisterItem = false
    @State private var selectedItem: InventoryItem? = nil
    @State private var search = ""

    @State private var items: [InventoryItem] = (1...20).map { i in
        .init(name: "Mochila \(i)", status: "Emprestada", icon: "backpack")
    }
    
    @State private var colorlol = ""
    
    var filteredItems: [InventoryItem] {
        items.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Spacer()
                Text("Inventário")
                    .font(.title)
                    .bold()
                    .padding(.leading, 24)
                Spacer()
                Button(action: {
                    showRegisterItem = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color("TextColor"))
                        .frame(width: 24, height: 24)
                }
                .frame(width: 48, height: 48)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 12)
                TextField("Search", text: $search)
                    .padding(.vertical, 10)
            }
            .background(Color(UIColor.systemGray4))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 10)


            // Item List
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(filteredItems) { item in
                        Button(action: {
                            selectedItem = item
                        }){
                            InventoryListItem(item: item)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }

        }
        .background(Color("BackgroundColor").ignoresSafeArea())
        .fullScreenCover(isPresented: $showRegisterItem) {
            
            RegisterItemView { newItem in
                items.append(newItem)
                showRegisterItem = false
            }
        }
        .fullScreenCover(item: $selectedItem) { item in
            NavigationView {
                
                DetailItemView(currentItem: item)
            }
        }
    }
}

struct RegisterItemView: View {
    @State private var name = ""
    @State private var status = "Guardada"
    @State private var icon = "backpack"
    @State private var rfid = ""
    
    let statuses = ["Guardada", "Emprestada", "Em Uso"]
    let icons = ["backpack", "bag", "briefcase", "folder"]
    
    var onSave: (InventoryItem) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nome")) {
                    TextField("Nome da mochila", text: $name)
                }
                Section(header: Text("RFID")) {
                    TextField("ID da tag da mochila", text: $rfid)
                }
                Section(header: Text("Status")) {
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Ícone")) {
                    Picker("Ícone", selection: $icon) {
                        ForEach(icons, id: \.self) {
                            Image(systemName: $0).tag($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Cadastrar Mochila")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        let newItem = InventoryItem(name: name.isEmpty ? "Sem Nome" : name, status: status, icon: icon)
                        onSave(newItem)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailItemView: View {
    let currentItem: InventoryItem
    @Environment(\.dismiss) var dismiss
    
    // Exemplo de data para mostrar no detalhe (pode ser passado no model também)
    let lastUpdated = Date()
    
    // Badge color dependendo do status
    var statusColor: Color {
        switch currentItem.status.lowercased() {
        case "guardada": return .green
        case "emprestada": return .orange
        case "em uso": return .blue
        default: return .gray
        }
    }
    
    // Formatador de data simples
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastUpdated)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: currentItem.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding()
                .foregroundColor(Color("TextColor"))
            
            Text(currentItem.name)
                .font(.title)
                .bold()
            
            HStack {
                Text("Status:")
                    .fontWeight(.semibold)
                Text(currentItem.status)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            .font(.headline)
            
            HStack {
                Text("ID:")
                    .fontWeight(.semibold)
                Text(currentItem.id.uuidString)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            HStack {
                Text("Última atualização:")
                    .fontWeight(.semibold)
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                // Exemplo: ação de editar, aqui só fecha
                dismiss()
            }) {
                Text("Editar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("ButtonColor"))
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle(currentItem.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Fechar") {
                    dismiss()
                }
            }
        }
    }
}


struct InventoryListItem: View {
    let item: InventoryItem
    var statusColor: Color {
        switch item.status.lowercased() {
        case "guardada": return .green
        case "emprestada": return .orange
        case "em uso": return .blue
        default: return .gray
        }
    }
    var body: some View {
        ZStack{
            Color.menuBar
            
            HStack(spacing: 12) {
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(statusColor)).opacity(0.2)
                        .frame(width: 48, height: 48)
                    Image(systemName: item.icon)
                        .foregroundColor(Color("TextColor"))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .fontWeight(.medium)
                        .foregroundColor(Color("TextColor"))
                    Text("Status: \(item.status)")
                        .font(.caption)
                        .foregroundColor(Color("TextColor"))
                }
                
                Spacer()
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(statusColor), lineWidth: 3)
            )
            .cornerRadius(10)
        }
    }
}

#Preview {
    InventoryView()
}
