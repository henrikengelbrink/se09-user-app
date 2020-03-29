//
//  DeviceCell.swift
//  se09-user-app
//
//  Created by Henrik Engelbrink on 27.03.20.
//  Copyright © 2020 Henrik Engelbrink. All rights reserved.
//

import UIKit
import CocoaMQTT

class DeviceCell: UITableViewCell, CocoaMQTTDelegate {
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        
    }
    

    @IBOutlet var deviceIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let clientID = "CocoaMQTT-App"
//        let mqtt = CocoaMQTT(clientID: clientID, host: "localhost", port: 1883)
//        mqtt.username = "test"
//        mqtt.password = "public"
//        mqtt.clientID
//        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
//        mqtt.keepAlive = 60
//        mqtt.delegate = self
//        mqtt.connect()
//        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
