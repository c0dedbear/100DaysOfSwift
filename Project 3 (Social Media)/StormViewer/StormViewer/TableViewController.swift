//
//  ViewController.swift
//  StormViewer
//
//  Created by Mikhail Medvedev on 10.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    private var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findPictures()
        setupView()
    }
    
    func setupView() {
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    fileprivate func findPictures() {
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fileManager.contentsOfDirectory(atPath: path)
        
        for item in items.sorted() {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
    }

}

// UITableViewDataSource
extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        return cell
    }
}
// UITableViewDelegate
extension TableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            detailVC.selectedImageName = pictures[indexPath.row]
            detailVC.descriptionForTitle = "Picture \(indexPath.row + 1) from \(pictures.count)"
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

