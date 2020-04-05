//
//  CollectionViewController.swift
//  NamesToFaces
//
//  Created by Mikhail Medvedev on 08.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class TableViewController: UITableViewController
{
	let defaults = UserDefaults.standard
	var people = [Person]() {
		didSet {
			saveToDefaults()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		loadFromDefaults()
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addButtonTapped)
		)
	}

	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}

	private func saveToDefaults() {
		if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
			defaults.set(savedData, forKey: "people")
		}
	}

	private func loadFromDefaults() {
		if let savedPeople = defaults.object(forKey: "people") as? Data {
			if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
				people = decodedPeople
			}
		}
	}

	@objc private func addButtonTapped() {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.sourceType = .camera
		picker.delegate = self
		present(picker, animated: true)
	}
}

extension TableViewController
{
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return people.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "Person",
			for: indexPath
		)

		let person = people[indexPath.row]
		cell.textLabel?.text = person.name

		let path = getDocumentsDirectory().appendingPathComponent(person.image)
		cell.imageView?.image = UIImage(contentsOfFile: path.path)

		cell.imageView?.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
		cell.imageView?.layer.borderWidth = 1
		cell.imageView?.layer.cornerRadius = 3
		cell.layer.cornerRadius = 7

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let commonAc = UIAlertController(title: "Choose option", message: nil, preferredStyle: .actionSheet)
		let renameAction = UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
			self?.showRenameAlertController(at: indexPath)
		}
		commonAc.addAction(renameAction)

		let showImageAction = UIAlertAction(title: "View Image", style: .default) { [weak self] _ in
			guard let indexPath = self?.tableView.indexPathForSelectedRow else { return }
			if let detailVC = self?.storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
				if let path = self?.getDocumentsDirectory()
					.appendingPathComponent(self?.people[indexPath.row].image ?? "") {
					detailVC.imageName = path.path
					self?.navigationController?.pushViewController(detailVC, animated: true)
				}
			}
		}
		commonAc.addAction(showImageAction)
		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
			self?.deletePerson(at: indexPath)
		}
		commonAc.addAction(deleteAction)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		commonAc.addAction(cancelAction)

		present(commonAc, animated: true)
	}

	private func showRenameAlertController(at indexPath: IndexPath) {
		let person = people[indexPath.item]
		let changeNameAc = UIAlertController(title: "Change name", message: nil, preferredStyle: .alert)
		changeNameAc.addTextField()
		changeNameAc.addAction(UIAlertAction(title: "OK", style: .default)
		{ [weak self] _ in
			guard let newName = changeNameAc.textFields?.first?.text else { return }
			person.name = newName
			self?.saveToDefaults()
			self?.tableView.reloadData()
		}
		)

		changeNameAc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(changeNameAc, animated: true)
	}
	private func deletePerson(at indexPath: IndexPath) {
		people.remove(at: indexPath.item)
		tableView.reloadData()
	}
}

extension TableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		guard let image = info[.editedImage] as? UIImage else { return }
		let imageName = UUID().uuidString
		let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

		if let jpegData = image.jpegData(compressionQuality: 0.8) {
			try? jpegData.write(to: imagePath)
		}

		let person = Person(name: "Unknown", image: imageName)
		people.append(person)
		tableView.reloadData()

		dismiss(animated: true)
	}
}
