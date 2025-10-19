import AuthenticationServices
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import SwiftUI

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

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var authState: AuthState = .unauthenticated
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    enum AuthState {
        case unauthenticated
        case authenticating
        case guest
        case authenticated(User)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
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
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = SignInViewController()
        delegate.viewModel = self
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        controller.performRequests()
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
    
    func openAsGuest() {
        authState = .guest
    }

    func handleAppleSignInFailure(_ error: Error) {
        errorMessage = error.localizedDescription
        authState = .unauthenticated
    }
}

class SignInViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    weak var viewModel: AuthenticationViewModel?

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let connectedScene = UIApplication.shared.connectedScenes
        let windowScene = connectedScene.first { $0.activationState == .foregroundActive } as? UIWindowScene
        let keyWindow = windowScene?.windows.first { $0.isKeyWindow }
        return keyWindow ?? UIWindow()
    }

    private func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) async {
        do {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
               let identityToken = appleIDCredential.identityToken,
               let idTokenString = String(data: identityToken, encoding: .utf8)
            {
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email

                let credential = OAuthProvider.credential(
                    providerID: .apple,
                    idToken: idTokenString
                )

                let authResult = try await Auth.auth().signIn(with: credential)
            } else {
                throw AuthError.invalidCredentials
            }
        } catch {
            viewModel?.handleAppleSignInFailure(error)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
    }
}
