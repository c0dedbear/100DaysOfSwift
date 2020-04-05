//
//  TableViewController.swift
//  WhiteHousePetitions
//
//  Created by Mikhail Medvedev on 27.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

	var petitions = [Petition]()
	var filteredPetitions = [Petition]()
	var urlString: String?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		setupBarButtons()
		loadPetitions()
	}

	func setupBarButtons() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(creditsButtonTapped))
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
	}

	func loadPetitions() {

		if navigationController?.tabBarItem.tag == 0 {
			urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
		} else {
			urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
		}

		if let url = URL(string: urlString ?? "") {
			if let data = try? Data(contentsOf: url) {
				parse(data)
				return
			}
		}

		showError()
	}

	func parse(_ data: Data) {
		let decoder = JSONDecoder()

		if let result = try? decoder.decode(Petitions.self, from: data) {
			petitions = result.results
			filteredPetitions = petitions
			tableView.reloadData()
		}
	}

	func showError() {
		let ac = UIAlertController(title: "Failed to load petitions", message: "Error has been occured when try to load data", preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default)

		ac.addAction(action)
		present(ac, animated: true)
	}

	@objc func creditsButtonTapped() {
		let ac = UIAlertController(title: "Credits", message: "Data provided from \(urlString ?? "error")", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default)
		ac.addAction(okAction)
		present(ac, animated: true)
	}

	@objc func searchButtonTapped() {
		guard petitions.isEmpty == false else { return }
		let ac = UIAlertController(title: "Filter", message: "Enter word", preferredStyle: .alert)
		ac.addTextField()
		let searchAction = UIAlertAction(title: "Search", style: .default) { _ in
				if let text = ac.textFields?.first?.text?.lowercased() {
					DispatchQueue.global(qos: .background).async {
					self.filteredPetitions = self.petitions.filter {
						$0.title.contains(text) || $0.body.contains(text)
					}
					DispatchQueue.main.async {
						self.tableView.reloadData()
					}
				}
			}
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(searchAction)
		ac.addAction(cancelAction)

		present(ac, animated: true)
	}

}

extension TableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		filteredPetitions.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let petition = filteredPetitions[indexPath.row]
		cell.textLabel?.text = petition.title
		cell.detailTextLabel?.text = "Signatures: \(petition.signatureCount)"

		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = DetailViewController()
		vc.petition = filteredPetitions[indexPath.row]
		navigationController?.pushViewController(vc, animated: true)
	}
}
