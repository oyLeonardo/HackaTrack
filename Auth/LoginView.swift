import SwiftUI


// MARK: - Tela de Login
struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var user = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isShowingSignUp = false

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 50)
                    
                    if colorScheme == .dark {
                        Image("logodark").resizable().scaledToFit().frame(height: 80)
                    } else {
                        Image("logonormal").resizable().scaledToFit().frame(height: 80)
                    }
                    
                    Spacer()

                    VStack(spacing: 16) {
                        CustomTextField(iconName: "person.fill", placeholder: "Digite seu usuário", text: $user)
                        CustomSecureField(iconName: "lock.fill", placeholder: "Digite sua senha", text: $password)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red).font(.caption).padding(.top, 10).transition(.opacity)
                    } else if let successMessage = successMessage {
                         Text(successMessage)
                            .foregroundColor(.green).font(.caption).fontWeight(.semibold).padding(.top, 10).transition(.opacity)
                    }
                    
                    Spacer()
                    
                    VStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("TextColor")))
                                .frame(maxWidth: .infinity).padding()
                        } else {
                            Button(action: handleLogin) {
                                Text("Logar")
                                    .font(.headline).fontWeight(.semibold).foregroundColor(.black)
                                    .frame(maxWidth: .infinity).padding()
                                    .background(Color("ButtonColor"))
                                    .cornerRadius(12).shadow(color: .black.opacity(0.1), radius: 5, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .frame(height: 50)
                    
                    Button("Não tem uma conta? Registre-se") {
                        isShowingSignUp = true
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 15)

                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 30)
            }
        }
        // ** AQUI ESTÁ A MUDANÇA **
        // Apresenta a tela de cadastro em tela cheia
        .fullScreenCover(isPresented: $isShowingSignUp) {
            SignUpView(onSuccess: {
                isShowingSignUp = false
                successMessage = "Conta criada com sucesso!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    successMessage = nil
                }
            })
        }
    }
    
    private func handleLogin() {
        errorMessage = nil
        successMessage = nil
        if user.isEmpty || password.isEmpty {
            errorMessage = "Por favor, preencha todos os campos."
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if !user.isEmpty && !password.isEmpty {
                withAnimation {
                    authManager.isAuthenticated = true
                }
            }
        }
    }
}

// MARK: - Componentes Customizados
struct CustomTextField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .foregroundColor(Color("TextColor"))
        }
        .padding()
        .background(Color("LoginColor"))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .autocapitalization(.none)
        .disableAutocorrection(true)
    }
}

struct CustomSecureField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            SecureField(placeholder, text: $text)
                .foregroundColor(Color("TextColor"))
        }
        .padding()
        .background(Color("LoginColor"))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// Efeito de escala para botões
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
        .environmentObject(AppSettings())
}
