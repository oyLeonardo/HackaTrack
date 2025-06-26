import SwiftUI

// MARK: - Tela de Cadastro (SignUp)
@MainActor
class SignUpViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var username = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func handleSignUp(completion: @escaping (Bool) -> Void) {
        errorMessage = nil

        guard !fullName.isEmpty, !username.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, preencha todos os campos."; completion(false); return
        }
        guard password == confirmPassword else {
            errorMessage = "As senhas não coincidem."; completion(false); return
        }
        guard password.count >= 6 else {
            errorMessage = "A senha deve ter pelo menos 6 caracteres."; completion(false); return
        }

        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            completion(true)
        }
    }
}

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss // Para fechar a tela
    
    var onSuccess: () -> Void

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
                        CustomTextField(iconName: "person.text.rectangle.fill", placeholder: "Digite seu nome completo", text: $viewModel.fullName)
                        CustomTextField(iconName: "person.fill", placeholder: "Digite seu nome de usuário", text: $viewModel.username)
                        CustomSecureField(iconName: "lock.fill", placeholder: "Digite sua senha", text: $viewModel.password)
                        CustomSecureField(iconName: "lock.shield.fill", placeholder: "Confirme sua senha", text: $viewModel.confirmPassword)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage).foregroundColor(.red).font(.caption).padding(.top, 5).transition(.opacity)
                    }
                    
                    Spacer()
                    
                    VStack {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color("TextColor"))).frame(maxWidth: .infinity).padding()
                        } else {
                            Button(action: {
                                viewModel.handleSignUp { success in
                                    if success {
                                        onSuccess()
                                    }
                                }
                            }) {
                                Text("Registrar")
                                    .font(.headline).fontWeight(.semibold).foregroundColor(.black)
                                    .frame(maxWidth: .infinity).padding()
                                    .background(Color("ButtonColor"))
                                    .cornerRadius(12).shadow(color: .black.opacity(0.1), radius: 5, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .frame(height: 50)
                    
                    // ** AQUI ESTÁ A MUDANÇA **
                    // Botão para voltar para o login
                    Button("Já tem uma conta? Voltar ao Login") {
                        dismiss()
                    }
                    .font(.caption).foregroundColor(.gray).padding(.top, 15)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 30)
            }
        }
    }
}
