import Foundation
import AppAuth
import KeychainAccess

class AuthService {
    var currentAuthFlow: OIDExternalUserAgentSession?
    
    private let authEndpoint = URL(string: "https://api.engelbrink.dev/hydra/oauth2/auth")!
    private let tokenEndpoint = URL(string: "https://api.engelbrink.dev/hydra/oauth2/token")!
    private let redirectURL = URL(string: "com.se09-user-app:/oauth2/callback")!
    private let clientId = "XXXX"
    private lazy var config = OIDServiceConfiguration(authorizationEndpoint: authEndpoint, tokenEndpoint: tokenEndpoint)
    
    private let keychainKeyAuthState = "keychainKeyAuthState"
    private let keychain = Keychain(service: "com.se09.userapp")
    
    func authorize(from vc: UIViewController, onSuccess: @escaping (OIDAuthState) -> Void, onError: @escaping (Error) -> Void) {
        let request = OIDAuthorizationRequest(
            configuration: config,
            clientId: clientId,
            clientSecret: nil,
            scopes: [OIDScopeOpenID, "offline", "offline_access"],
            redirectURL: redirectURL,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )
        currentAuthFlow = OIDAuthState.authState(byPresenting: request, presenting: vc, callback: { (authState, error) in
            if let authState = authState {
                self.saveAuthState(authState: authState)
                onSuccess(authState)
            } else if let error = error {
                print(error)
                onError(error)
            }
        })
    }

    private func saveAuthState(authState: OIDAuthState) {
        let authStateData = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: false)
        try? self.keychain.set(authStateData!, key: keychainKeyAuthState)
    }

    
    func userLoggedIn(completion: @escaping (Bool) -> Void) {
        let authStateData: Data? = try? keychain.getData(keychainKeyAuthState)
        if authStateData != nil {
            if let authState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(authStateData!) as? OIDAuthState {
                let oldAT = authState.lastTokenResponse?.accessToken
                authState.performAction() { (accessToken, idToken, error) in
                    if error != nil  {
                        print("Error fetching fresh tokens: \(error?.localizedDescription ?? "Unknown error")")
                        try? self.keychain.remove(self.keychainKeyAuthState)
                        completion(false)
                        return
                    }
                    if oldAT! != accessToken! {
                        print("REFRESHED TOKEN")
                    }
                    self.saveAuthState(authState: authState)
                    print(authState.lastTokenResponse?.accessToken!)
                    completion(true)
                }
            } else {
                print("INVALID authStateData")
                try? keychain.remove(keychainKeyAuthState)
                completion(false)
            }
        } else {
            completion(false)
        }
    }
    
    func logout() {
        do {
            try keychain.remove(keychainKeyAuthState)
            print("LOGGED OUT")
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func getAccessToken() -> String? {
        let authStateData: Data? = try? keychain.getData(keychainKeyAuthState)
        if authStateData != nil {
            if let authState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(authStateData!) as? OIDAuthState {
                print("TOKEN \(authState.lastTokenResponse?.accessToken)")
                return authState.lastTokenResponse?.accessToken
            }
        }
        return nil
    }
    
}
