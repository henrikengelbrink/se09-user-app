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
