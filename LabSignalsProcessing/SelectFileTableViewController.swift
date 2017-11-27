//
//  SelectFileTableViewController.swift
//  LabSignalsProcessing
//
//  Created by Artiom Bastun on 27/11/2017.
//  Copyright © 2017 Artjom Bastun. All rights reserved.
//

import UIKit

class SelectFileTableViewController: UITableViewController {
    
    let files = ["PRIM1", "PRIM2", "PRIM3", "34638_1", "4332_1", "35626_1", "41413_1"]
    var selectFileAction: ((String)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return files.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = files[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectFileAction?(files[indexPath.row])
    }

}
