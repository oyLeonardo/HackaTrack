import SwiftUI

struct ProfileView: View {
    @State private var user = "teste1231"
    @State private var name = "nometeste"
    @State private var showchangeview = false
    var body: some View {
        VStack(spacing:0){
            HStack {
                Spacer()
                Text("Perfil")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            ZStack {
                Circle()
                    .fill(Color("TextColor").opacity(0.2))
                    .frame(width: 200, height: 200)

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color("TextColor"))
            }
            
            Text(name)
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
                .padding(.vertical, 4)
            Text(name)
                .font(.title2)
                .padding(.horizontal)
                .padding(.bottom, 50)
            NavigationLinkRow(title: "Alterar senha", description: "Alterar senha cadastrada no sistema")
            Spacer()
        }
    }
}

#Preview {
    ProfileView()
}
