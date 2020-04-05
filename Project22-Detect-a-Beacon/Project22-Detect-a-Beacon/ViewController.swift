//
//  ViewController.swift
//  Project22-Detect-a-Beacon
//
//  Created by Mikhail Medvedev on 22.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

	@IBOutlet var label: UILabel!
	@IBOutlet var circle: UIView!
	

	var coreLocationManager: CLLocationManager?
	var isFirstIbeaconDetected = false

	override func viewDidLoad() {
		super.viewDidLoad()
		coreLocationManager = CLLocationManager()
		coreLocationManager?.delegate = self
		coreLocationManager?.requestAlwaysAuthorization()

		view.backgroundColor = .gray
		addCircle()
	}

	func addCircle() {
		circle.layer.cornerRadius = circle.frame.width / 2
		circle.layer.borderWidth = 3
		circle.layer.borderColor = UIColor.white.cgColor
	}

	func startScanning() {
		 let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
		 let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")

		coreLocationManager?.startMonitoring(for: beaconRegion)
		coreLocationManager?.startRangingBeacons(in: beaconRegion)
	}

	func update(distance: CLProximity) {
		UIView.animate(withDuration: 0.8) {
			switch distance {
			case .far:
				self.view.backgroundColor = UIColor.blue
				self.label.text = "FAR"
				self.circle.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)

			case .near:
				self.view.backgroundColor = UIColor.orange
				self.label.text = "NEAR"
				self.circle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

			case .immediate:
				self.view.backgroundColor = UIColor.red
				self.label.text = "RIGHT HERE"
				self.circle.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

			default:
				self.view.backgroundColor = UIColor.gray
				self.label.text = "UNKNOWN"
				self.circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
			}
		}
	}


}
extension ViewController: CLLocationManagerDelegate
{
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedAlways {
			if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self),
				CLLocationManager.isRangingAvailable() {
				startScanning()
			}
		}

	}

	func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		if let beacon = beacons.first {
			if isFirstIbeaconDetected {
			update(distance: beacon.proximity)
			}
			let ac = UIAlertController(title: "Detect an a Beacon", message: "Info: proximity id: \(beacon.proximityUUID), major: \(beacon.major), minor: \(beacon.minor)", preferredStyle: .alert)
			let detectAction = UIAlertAction(title: "Detect", style: .default) { [weak self] _ in
				self?.isFirstIbeaconDetected = true
			}
			let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
				self?.update(distance: .unknown)
				self?.isFirstIbeaconDetected = false
			}

			ac.addAction(detectAction)
			ac.addAction(cancel)
			if isFirstIbeaconDetected == false {
				present(ac, animated: true)
			}
		}
		else {
			update(distance: .unknown)
		}
	}

}

