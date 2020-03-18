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
        print("Add new device")
        let alert = UIAlertController(title: "Add device", message: "Connect to the Device-Wifi to add this device to your account", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in }))
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.cancel, handler: {(_: UIAlertAction!) in
            
            self.deviceSearchAlertController = UIAlertController(title: "\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            let margin:CGFloat = 10.0
            let rect = CGRect(x: margin, y: margin, width: self.deviceSearchAlertController!.view.bounds.size.width - margin * 4.0, height: 80)
            let customView = UIView(frame: rect)
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.frame = CGRect(x: rect.midX - 25, y: rect.midY - 30, width: 50, height: 50)
            customView.addSubview(spinner)
            spinner.startAnimating()
            self.deviceSearchAlertController!.view.addSubview(customView)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
            self.deviceSearchAlertController!.addAction(cancelAction)
            DispatchQueue.main.async {
                self.present(self.deviceSearchAlertController!, animated: true, completion:{
                    self.deviceService.startSearch {
                        self.deviceSearchAlertController?.dismiss(animated: true, completion: nil)
                    }
                    UIApplication.shared.open(NSURL(string:"App-prefs:root=WIFI")! as URL)
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
