//
//  TableViewController.swift
//  FlagsViewer
//
//  Created by Mikhail Medvedev on 16.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var countries = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadFlags()
        title = "FLAGS"
        navigationController?.navigationBar.prefersLargeTitles = true
        print(countries)
    }

    func loadFlags() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasSuffix("png") {
                countries.append(item)
            }
        }
        
    }

}

//MARK: - UITableViewDataSource
extension TableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
}

//MARK: - UITableViewDelegate
extension TableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell", for: indexPath)
        let country = countries[indexPath.row]

    
        cell.imageView?.image = UIImage(named: country)
        cell.imageView?.layer.cornerRadius = 6
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.layer.borderColor = UIColor.black.cgColor
        cell.textLabel?.text = country.dropLast(4).capitalized
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController else { return }
        detailVC.selectedFlag = countries[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
