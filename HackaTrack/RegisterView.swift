import SwiftUI

struct RegisterView: View {
    @State private var user = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirm_password = ""
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Color("BackgrounColor")
                .ignoresSafeArea()

            VStack(spacing: 70) {
                Spacer()
                    Image("registrarsvg").resizable().frame(width: 370,height: 100)
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nome Completo")
                            .font(.subheadline)
                            .foregroundColor(Color("TextColor"))

                        TextField(
                            text: $name,
                            prompt: Text("Digite seu nome").foregroundColor(.gray)
                        ) {
                            Text("Nome")
                        }
                        .padding()
                        .background(Color.loginColors)
                        .cornerRadius(8)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Usuário")
                            .font(.subheadline)
                            .foregroundColor(Color("TextColor"))

                        TextField(
                            text: $user,
                            prompt: Text("Digite seu usuário").foregroundColor(.gray)
                        ) {
                            Text("Usuário")
                        }
                        .padding()
                        .background(Color.loginColors)
                        .cornerRadius(8)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Senha")
                            .font(.subheadline)
                            .foregroundColor(Color("TextColor"))

                        TextField(
                            text: $password,
                            prompt: Text("Digite sua senha").foregroundColor(.gray)
                        ) {
                            Text("Senha")
                        }
                        .padding()
                        .background(Color.loginColors)
                        .cornerRadius(8)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirmar Senha")
                            .font(.subheadline)
                            .foregroundColor(Color("TextColor"))

                        TextField(
                            text: $confirm_password,
                            prompt: Text("Confirme sua senha").foregroundColor(.gray)
                        ) {
                            Text("Usuário")
                        }
                        .padding()
                        .background(Color.loginColors)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    // ação de continuar
                }) {
                    Text("Registrar")
                        .font(.headline)
                        .foregroundColor(Color(.black))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("ButtonColor"))
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
    RegisterView()
}

