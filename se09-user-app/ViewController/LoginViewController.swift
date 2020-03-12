//
//  ViewController.swift
//  se09-user-app
//
//  Created by Henrik Engelbrink on 11.03.20.
//  Copyright © 2020 Henrik Engelbrink. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    let authService = AuthService()
    
    @IBAction func authorize(_ sender: Any) {
        self.authService.authorize(from: self, onSuccess: { [weak self] authState in
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            viewController.modalPresentationStyle = .fullScreen
            self?.present(viewController, animated: true, completion: nil)

        }, onError: { error in
            print(error)
        })
    }
}
