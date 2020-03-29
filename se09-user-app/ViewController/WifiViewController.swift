//
//  WifiViewController.swift
//  se09-user-app
//
//  Created by Henrik Engelbrink on 22.03.20.
//  Copyright © 2020 Henrik Engelbrink. All rights reserved.
//

import UIKit
import Alamofire

class WifiViewController: UIViewController {

    @IBOutlet var ssidInput: UITextField!
    @IBOutlet var passwordInput: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    
    private var connectTimer: Timer? = nil
    
    private let authService = AuthService()
    private let deviceService = DeviceService()

    var deviceId: String = ""
    private var mqttAuthConfig: MQTTAuthConfig? = nil
    private var wifiSSID: String = ""
    private var wifiPassword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsButton.isHidden = true
        self.activityIndicator.isHidden = true
    }
    
    @IBAction func configureDevice(_ sender: Any) {
        if self.ssidInput.text != nil && self.passwordInput.text != nil {
            self.connectButton.isHidden = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            self.wifiSSID = self.ssidInput.text!
            self.wifiPassword = self.passwordInput.text!
            self.requestMQTTConfig(id: self.deviceId)
        }
    }
    
    @IBAction func openSettings(_ sender: Any) {
         UIApplication.shared.openURL(NSURL(string:"App-prefs:root=WIFI")! as URL)
        self.deviceService.startSearch {
            print("FOUND")
            self.deviceService.setConfig(wifiSSID: self.wifiSSID, wifiPass: self.wifiPassword, mqttUser: self.mqttAuthConfig!.userDeviceId, mqttPass: self.mqttAuthConfig!.password) {
                DispatchQueue.main.async {
                    print("FINISHED SETUP")
                   self.navigationController?.popToRootViewController(animated: false)
                }
            }
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func requestMQTTConfig(id: String) {
        let token = authService.getAccessToken()
        if token != nil {
            let headers: HTTPHeaders = [
              "Authorization": "Bearer \(token!)",
            ]
            AF.request("https://api.engelbrink.dev/device-service/devices/\(id)", method : .post, parameters : [:], encoding : JSONEncoding.default, headers: headers).responseDecodable(of:MQTTAuthConfig.self) { response in
                if response.value != nil {
                    self.mqttAuthConfig = response.value!
                    print("userDeviceId \(self.mqttAuthConfig!.userDeviceId)")
                    print("password \(self.mqttAuthConfig!.password)")
                    self.activityIndicator.isHidden = true
                    self.settingsButton.isHidden = false
                } else {
                    print(response.error)
                    print(response.debugDescription)
                    print("ERR *****")
                }
            }
        } else {
            print("INVALID TOKEN AUTH")
        }
    }

}
