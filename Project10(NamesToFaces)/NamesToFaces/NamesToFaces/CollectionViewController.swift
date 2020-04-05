//
//  CollectionViewController.swift
//  NamesToFaces
//
//  Created by Mikhail Medvedev on 08.11.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

final class CollectionViewController: UICollectionViewController
{
	var people = [Person]()

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .add,
			target: self,
			action: #selector(addButtonTapped))
	}

	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}

	@objc private func addButtonTapped() {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}
}

extension CollectionViewController
{
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return people.count
	}

	override func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: PersonCell.identifier,
			for: indexPath
			) as? PersonCell else { fatalError("Can't casting to PersonCell") }

		let person = people[indexPath.item]
		cell.nameLabel.text = person.name

		let path = getDocumentsDirectory().appendingPathComponent(person.image)
		cell.imageView.image = UIImage(contentsOfFile: path.path)

		cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
		cell.imageView.layer.borderWidth = 1
		cell.imageView.layer.cornerRadius = 3
		cell.layer.cornerRadius = 7

		return cell
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let commonAc = UIAlertController(title: "Choose option", message: nil, preferredStyle: .actionSheet)
		let renameAction = UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
			self?.showRenameAlertController(at: indexPath)
		}
		commonAc.addAction(renameAction)
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
		changeNameAc.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
			guard let newName = changeNameAc.textFields?.first?.text else { return }
			person.name = newName
			self?.collectionView.reloadData()
		}
		)

		changeNameAc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(changeNameAc, animated: true)
	}

	private func deletePerson(at indexPath: IndexPath) {
		people.remove(at: indexPath.item)
		collectionView.reloadData()
	}
}

extension CollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
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
		collectionView.reloadData()

		dismiss(animated: true)
	}
}
