//
//  MQTTAuthConfig.swift
//  se09-user-app
//
//  Created by Henrik Engelbrink on 20.03.20.
//  Copyright © 2020 Henrik Engelbrink. All rights reserved.
//

import UIKit

struct MQTTAuthConfig: Decodable {
    var userDeviceId: String
    var password: String
}
