import Foundation
import AppAuth
import KeychainAccess

class AuthService {
    var currentAuthFlow: OIDExternalUserAgentSession?
    
    private let authEndpoint = URL(string: "https://api.engelbrink.dev/hydra/oauth2/auth")!
    private let tokenEndpoint = URL(string: "https://api.engelbrink.dev/hydra/oauth2/token")!
    private let redirectURL = URL(string: "com.se09-user-app:/oauth2/callback")!
    private let clientId = "254ea39f6f1d8a0eb0596336cbe1c3e4"
    private lazy var config = OIDServiceConfiguration(authorizationEndpoint: authEndpoint, tokenEndpoint: tokenEndpoint)
    
    private let keychainKeyAuthState = "keychainKeyAuthState"
    private let keychain = Keychain(service: "com.se09.userapp")
    
    func authorize(from vc: UIViewController, onSuccess: @escaping (OIDAuthState) -> Void, onError: @escaping (Error) -> Void) {
        let request = OIDAuthorizationRequest(
            configuration: config,
            clientId: clientId,
            clientSecret: nil,
            scopes: [OIDScopeOpenID, "offline"],
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

    
    func userLoggedIn() -> Bool {
        var loggedIn = true
        let authStateData: Data? = try? keychain.getData(keychainKeyAuthState)
        if authStateData != nil {
            if let authState = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(authStateData!) as? OIDAuthState {
                if authState.lastTokenResponse != nil && authState.lastTokenResponse!.accessTokenExpirationDate != nil {
                    if authState.lastTokenResponse!.accessTokenExpirationDate!.timeIntervalSince1970 < Date.init().timeIntervalSince1970 {
                        print("REFRESH TOKEN")
                        let request = authState.lastAuthorizationResponse.tokenExchangeRequest()
                        OIDAuthorizationService.perform(request!, callback: { (tokenResponse, error) in
                            if tokenResponse != nil && error == nil {
                                authState.update(with: tokenResponse, error: error)
                                print("REFRESH TOKEN DONE")
                                self.saveAuthState(authState: authState)
                            } else {
                                print("REFRESH FAILED")
                                loggedIn = false
                                try? self.keychain.remove(self.keychainKeyAuthState)
                            }
                        })
                    }
                } else {
                    print("MISSING EXP DATE")
                    loggedIn = false
                    try? keychain.remove(keychainKeyAuthState)
                }
            } else {
                print("INVALID authStateData")
                loggedIn = false
                try? keychain.remove(keychainKeyAuthState)
            }
        } else {
            loggedIn = false
        }
        print("userLoggedIn \(loggedIn)")
        return loggedIn
    }
    
    func logout() {
        do {
            try keychain.remove(keychainKeyAuthState)
            print("LOGGED OUT")
        } catch let error {
            print("error: \(error)")
        }
    }
    
}
