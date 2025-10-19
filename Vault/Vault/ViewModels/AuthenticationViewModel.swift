import SwiftUI
import GoogleSignIn
import FirebaseAuth
import AuthenticationServices
import Combine
import FirebaseCore

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var authState: AuthState = .unauthenticated
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    enum AuthState {
        case unauthenticated
        case authenticating
        case authenticated(User)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.authState = .authenticated(user)
                    self?.currentUser = user
                } else {
                    self?.authState = .unauthenticated
                    self?.currentUser = nil
                }
            }
        }
    }
    
    func signInWithApple() async {
        authState = .authenticating
        
//        let request = ASAuthorizationAppleIDProvider().createRequest()
//        request.requestedScopes = [.email, .fullName]
//        
//        do {
//            let result = try await ASAuthorizationController(
//                authorizationRequests: [request]
//            ).performRequests()
//            
//            guard let appleIDCredential = result.first?.credential as? ASAuthorizationAppleIDCredential,
//                  let identityToken = appleIDCredential.identityToken,
//                  let idTokenString = String(data: identityToken, encoding: .utf8) else {
//                throw AuthError.invalidCredentials
//            }
//            
//            let credential = OAuthProvider.credential(
//                withProviderID: "apple.com",
//                idToken: idTokenString,
//                rawNonce: nil
//            )
//            
//            let authResult = try await Auth.auth().signIn(with: credential)
//            // Auth state will be updated via listener
//            
//        } catch {
//            errorMessage = error.localizedDescription
//            authState = .unauthenticated
//        }
    }
    
    func signInWithGoogle() async {
        authState = .authenticating
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase configuration error"
            authState = .unauthenticated
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            errorMessage = "No presenting view controller"
            authState = .unauthenticated
            return
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let user = result.user
            
            guard let idToken = user.idToken?.tokenString else {
                throw AuthError.invalidCredentials
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            // Auth state will be updated via listener
            
        } catch {
            errorMessage = error.localizedDescription
            authState = .unauthenticated
        }
    }
    
    func signInWithEmail(email: String, password: String) async {
        authState = .authenticating
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            // Auth state will be updated via listener
        } catch {
            errorMessage = error.localizedDescription
            authState = .unauthenticated
        }
    }
    
    func signUpWithEmail(email: String, password: String) async {
        authState = .authenticating
        
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            // Auth state will be updated via listener
        } catch {
            errorMessage = error.localizedDescription
            authState = .unauthenticated
        }
    }
    
    func signOut() async {
        do {
            try Auth.auth().signOut()
            // Auth state will be updated via listener
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials provided"
        case .networkError:
            return "Network connection error"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}
