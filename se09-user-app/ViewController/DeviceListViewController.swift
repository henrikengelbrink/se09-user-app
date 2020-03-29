//
//  DeviceListViewController.swift
//  se09-user-app
//
//  Created by Henrik Engelbrink on 12.03.20.
//  Copyright © 2020 Henrik Engelbrink. All rights reserved.
//

import UIKit
import Alamofire

class DeviceListViewController: UITableViewController {

    private var deviceSearchAlertController: UIAlertController?
    private let deviceService = DeviceService()
    private let authService = AuthService()
    
    private var devices = [ListDeviceDTO]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewDevice))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadDevices()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell") as! DeviceCell
        let device = self.devices[indexPath.row]
        cell.deviceIdLabel.text = device.deviceId
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    @objc private func addNewDevice() {
//        let hotspotConfig = NEHotspotConfiguration(ssid: "ISDN", passphrase: "wilano1337@", isWEP: false)
//        NEHotspotConfigurationManager.shared.apply(hotspotConfig) {[unowned self] (error) in
//           if let error = error {
//              print("error = ",error)
//           }
//           else {
//              print("Success!")
//           }
//        }
        // https://forums.developer.apple.com/thread/127834
        // https://forums.developer.apple.com/thread/67613
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraConfigCaptureViewController") as! CameraConfigCaptureViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func loadDevices() {
        let token = authService.getAccessToken()
        if token != nil {
            let headers: HTTPHeaders = [
              "Authorization": "Bearer \(token!)"
            ]
            AF.request("https://api.engelbrink.dev/device-service/devices", method : .get, encoding : JSONEncoding.default, headers: headers).responseDecodable(of:Array<ListDeviceDTO>.self) { response in
                let list = response.value! as Array<ListDeviceDTO>
                self.devices = list
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } else {
            print("INVALID TOKEN AUTH")
        }
        
    }

}
