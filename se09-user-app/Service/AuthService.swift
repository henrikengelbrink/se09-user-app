import Foundation
import AppAuth
import KeychainAccess

class AuthService {
    var currentAuthFlow: OIDExternalUserAgentSession?
    
    private let authEndpoint = URL(string: "https://hydra.engelbrink.dev/oauth2/auth")!
    private let tokenEndpoint = URL(string: "https://hydra.engelbrink.dev/oauth2/token")!
    private let redirectURL = URL(string: "com.example-app:/oauth2/callback")!
    private let clientId = "test-client"
    private let clientSecret = "test-secret"
    private lazy var config = OIDServiceConfiguration(authorizationEndpoint: authEndpoint, tokenEndpoint: tokenEndpoint)
    
    private let keychainName = "com.se09.userapp"
    private let keychainKeyToken = "keychainKeyToken"
    private let keychainKeyRefresh = "keychainKeyRefresh"
    
    func authorize(from vc: UIViewController, onSuccess: @escaping (OIDAuthState) -> Void, onError: @escaping (Error) -> Void) {
        let request = OIDAuthorizationRequest(configuration: config,
                                              clientId: clientId,
                                              clientSecret: clientSecret,
                                              scopes: [OIDScopeOpenID, "offline"],
                                              redirectURL: redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)
        currentAuthFlow = OIDAuthState.authState(byPresenting: request, presenting: vc, callback: { (authState, error) in
            if let authState = authState {
                print("Refresh \(authState.refreshToken!)")
                print("Scope \(authState.scope!)")
                print("AccessToken \(authState.lastTokenResponse!.accessToken!)")
                print("ExpDate \(authState.lastTokenResponse!.accessTokenExpirationDate!)")
                self.saveLoginData(token: authState.lastTokenResponse!.accessToken!, refresh: authState.refreshToken!)
                onSuccess(authState)
            } else if let error = error {
                print(error)
                onError(error)
            }
        })
    }
    
    private func saveLoginData(token: String, refresh: String) {
        let keychain = Keychain(service: keychainName)
        try? keychain.set(token, key: keychainKeyToken)
        try? keychain.set(refresh, key: keychainKeyRefresh)
    }
    
    func userLoggedIn() -> Bool {
        let keychain = Keychain(service: keychainName)
        let token = try? keychain.get(keychainKeyToken)
        let refresh = try? keychain.get(keychainKeyRefresh)
        if token == nil || refresh == nil {
            return false
        }
        return true
    }
    
    func logout() {
        let keychain = Keychain(service: keychainName)
        do {
            try keychain.remove(keychainKeyToken)
            try keychain.remove(keychainKeyRefresh)
        } catch let error {
            print("error: \(error)")
        }
    }
    
}
