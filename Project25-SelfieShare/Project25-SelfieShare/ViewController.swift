//
//  ViewController.swift
//  Project25-SelfieShare
//
//  Created by Mikhail Medvedev on 04.01.2020.
//  Copyright © 2020 Mikhail Medvedev. All rights reserved.
//

import MultipeerConnectivity
import UIKit

final class ViewController: UICollectionViewController
{

	var peerID = MCPeerID(displayName: UIDevice.current.name)
	var mcSession: MCSession?
	var mcAdvertizerAssistant: MCAdvertiserAssistant?

	private var images = [UIImage]()

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Selfie Share"
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
		navigationItem.leftBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showPeers)))
		navigationItem.leftBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sendMessage)))

		mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
		mcSession?.delegate = self
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		images.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)

		if let imageView = cell.viewWithTag(1000) as? UIImageView {
			imageView.image = images[indexPath.item]
		}

		return cell
	}

	@objc func showPeers() {
		guard let mcSession = mcSession else { return }
		let ac = UIAlertController(title: "Peers", message: "\(mcSession.connectedPeers)", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .cancel))
		present(ac, animated: true)
	}

	@objc func showConnectionPrompt() {
		let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
		ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		present(ac, animated: true)
	}

	private func startHosting(action: UIAlertAction) {
		guard let mcSession = mcSession else { return }
		mcAdvertizerAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
		mcAdvertizerAssistant?.start()

	}

	private func joinSession(action: UIAlertAction) {
		guard let mcSession = mcSession else { return }
		let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
		mcBrowser.delegate = self
		present(mcBrowser, animated: true)
	}

	private func sendImage(image: UIImage) {
		guard let mcSession = mcSession else { return }

		if mcSession.connectedPeers.count > 0 {
			if let imageData = image.pngData() {
				do {
					try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
				}
				catch {
					let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
					ac.addAction(UIAlertAction(title: "OK", style: .default))
					present(ac, animated: true)
				}
			}
		}
	}

	@objc private func sendMessage() {
		guard let mcSession = mcSession else { return }
		let message = "Hello World!"
		if mcSession.connectedPeers.count > 0 {
			do {
				try mcSession.send(Data(message.utf8), toPeers: mcSession.connectedPeers, with: .reliable)
			}
			catch {
				let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "OK", style: .default))
				present(ac, animated: true)
			}
		}
	}

	@objc private func importPicture() {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		present(picker, animated: true)
	}

}

extension ViewController: UINavigationControllerDelegate {}

extension ViewController: UIImagePickerControllerDelegate
{
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.editedImage] as? UIImage else { return }

		dismiss(animated: true)
		images.insert(image, at: 0)
		collectionView.reloadData()

		sendImage(image: image)
	}
}

extension ViewController: MCSessionDelegate
{
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		DispatchQueue.main.async { [weak self] in
			if let image = UIImage(data: data) {
				self?.images.insert(image, at: 0)
				self?.collectionView.reloadData()
			}
			let message = String(decoding: data, as: UTF8.self)
			if message.isEmpty == false {
				let ac = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "OK", style: .default))
				self?.present(ac, animated: true)
			}
		}
	}

	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		switch state {
		case .connected:
			print("Connected: \(peerID.displayName)")
		case .connecting:
			print("Connecting: \(peerID.displayName)")
		case .notConnected:
			DispatchQueue.main.async { [weak self] in
				let ac = UIAlertController(title: "Disconnection", message: "\(peerID.displayName) was disconnected", preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "OK", style: .default))
				self?.present(ac, animated: true)
			}
			print("Not Connected: \(peerID.displayName)")
		@unknown default:
			print("Unknown state received: \(peerID.displayName)")
		}
	}

	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

}
extension ViewController: MCBrowserViewControllerDelegate
{
	func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
		dismiss(animated: true)
	}

	func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
		dismiss(animated: true)
	}
}
