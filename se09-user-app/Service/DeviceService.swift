//
//  DeviceService.swift
//  se09-user-app
//
//  Created by Henrik Engelbrink on 15.03.20.
//  Copyright © 2020 Henrik Engelbrink. All rights reserved.
//

import UIKit
import Alamofire

class DeviceService: NSObject {

    private var isSearching: Bool = false
    private var searchTimer: Timer?
    private var completionClosure: () -> Void = {}
    
    func startSearch(completion: @escaping () -> Void) {
        self.completionClosure = completion
        self.isSearching = true
        self.searchTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(checkDevice), userInfo: nil, repeats: true)
    }
    
    func setConfig(wifiSSID: String, wifiPass: String, mqttUser: String, mqttPass: String, completion: @escaping () -> Void) {
        let jsonBody = [
            "config":[
                "wifi": [
                    "sta": [
                        "enable": true,
                        "ssid": wifiSSID,
                        "pass": wifiPass
                    ],
                    "ap": [
                        "enable": false,
                    ]
                ],
                "mqtt": [
                    "enable": true,
                    "client_id": mqttUser,
                    "user": mqttUser,
                    "pass": mqttPass
                ]
            ],
        ]
        let url = URL.init(string: "http://192.168.99.1/rpc/Config.Set")
        AF.request(url!, method: .post, parameters: jsonBody, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            print(response.result)
            self.saveConfig(completion: completion)
        }
    }
    
    private func saveConfig(completion: @escaping () -> Void) {
        let jsonBody = [
            "reboot":true,
        ]
        let url = URL.init(string: "http://192.168.99.1/rpc/Config.Save")
        AF.request(url!, method: .post, parameters: jsonBody, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            print(response.result)
            completion()
        }
    }
    
    @objc private func checkDevice() {
        print("checkDevice")
        let request = AF.request("http://192.168.99.1/rpc/Config.Get")
        request.responseDecodable(of: ESP32Config.self) { (response) in
            guard let config = response.value else { return }
            print(config.device.id)
            self.searchTimer?.invalidate()
            self.completionClosure()
        }
    }
    
}
