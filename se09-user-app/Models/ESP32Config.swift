//
//  ESP32Config.swift
//  se09-user-app
//
//  Created by Henrik Engelbrink on 15.03.20.
//  Copyright © 2020 Henrik Engelbrink. All rights reserved.
//

import UIKit

struct ESP32Config: Encodable, Decodable {
    let device: ESP32ConfigDevice
}
