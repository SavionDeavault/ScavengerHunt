//
//  TableViewController.swift
//  ScavengerHunt
//
//  Created by Savion DeaVault on 11/6/19.
//  Copyright © 2019 Savion DeaVault. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
   override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return ""
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        cell.imageView?.image = UIImage(named: "image-1")
        return cell
    }
    
    @IBAction func returnToMapViewButton(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let showViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //show window
        appDelegate.window?.rootViewController = showViewController
    }
    
}
