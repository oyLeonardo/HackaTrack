import SwiftUI

struct LoginView: View {
    @State private var user = ""
    @State private var password = ""
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Color("BackgrounColor")
                .ignoresSafeArea()

            VStack(spacing: 70) {
                Spacer()
                if colorScheme == .dark {
                    Image("logodark").resizable().frame(width: 350,height: 150)
                } else {
                    Image("logonormal").resizable().frame(width: 350,height: 150)
                }
                
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                VStack(spacing: 16) {
                    TextField("Usuário", text: $user)
                        .padding()
                        .background(Color.loginColors)
                        .cornerRadius(8)

                    TextField("Senha", text: $password)
                        .padding()
                        .background(Color.loginColors)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Botão Next
                Button(action: {
                    // ação de continuar
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.black))
                        .cornerRadius(20)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
}
