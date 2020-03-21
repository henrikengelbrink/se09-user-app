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
    private let authService = AuthService()
    
    @IBAction func authorize(_ sender: Any) {
        self.authService.authorize(from: self, onSuccess: { [weak self] authState in
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
            viewController.modalPresentationStyle = .fullScreen
            self?.present(viewController, animated: true, completion: nil)

        }, onError: { error in
            print(error)
        })
    }
}

/*
 Refresh ExbYuOUmqzNbwjJlZD6fkwA8z_gpoxLxO8YiMEVsqW0.heNxtqbGD5hzY9wr7R-G6_qk4BtxO0SRsSJPU4OyQjM
 Scope openid offline
 AccessToken ukEQ9vl8mkruR-rl3mx8dTVrlcqWRTFZjakSNFBTVk4.PVQx4pvQ0eC9QmqmEHohzQ58Lpd-m5S0qgAHUdzO1_I
 ExpDate 2020-03-14 17:37:01 +0000
 */
