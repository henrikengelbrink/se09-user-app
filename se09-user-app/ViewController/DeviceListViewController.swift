//
//  DeviceListViewController.swift
//  se09-user-app
//
//  Created by Henrik Engelbrink on 12.03.20.
//  Copyright © 2020 Henrik Engelbrink. All rights reserved.
//

import UIKit
import NetworkExtension

class DeviceListViewController: UITableViewController {

    private var deviceSearchAlertController: UIAlertController?
    private let deviceService = DeviceService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewDevice))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    @objc private func addNewDevice() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CameraConfigCaptureViewController") as! CameraConfigCaptureViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
