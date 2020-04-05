//
//  ViewController.swift
//  Project16-CapitalCities
//
//  Created by Mikhail Medvedev on 01.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

	@IBOutlet var mapView: MKMapView!

	override func viewDidLoad() {
		super.viewDidLoad()
		let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
		let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
		let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
		let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
		let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")

		mapView.addAnnotations([london, oslo, paris, rome, washington])
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
	}

	@objc func editButtonTapped() {
		let ac = UIAlertController(title: "Choose map style", message: nil, preferredStyle: .actionSheet)
		let satelliteAction = UIAlertAction(title: "Satellite", style: .default) { [weak self] action in
			self?.mapView.mapType = .satellite
		}
		ac.addAction(satelliteAction)

		let standardAction = UIAlertAction(title: "Standard", style: .default) { [weak self] action in
			self?.mapView.mapType = .standard
		}
		ac.addAction(standardAction)

		let hybrydAction = UIAlertAction(title: "Hybrid", style: .default) { [weak self] action in
			self?.mapView.mapType = .hybrid
		}
		ac.addAction(hybrydAction)

		present(ac, animated: true)

	}
}

extension ViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard annotation is Capital else { return nil }

		let identifier = "Capital"

		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

		if annotationView == nil {
			annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			annotationView?.canShowCallout = true
			annotationView?.pinTintColor = .green

			let button = UIButton(type: .detailDisclosure)
			annotationView?.rightCalloutAccessoryView = button
		} else {
			annotationView?.annotation = annotation
		}

		return annotationView
	}

	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		guard let capital = view.annotation as? Capital else { return }

		let ac = UIAlertController(title: capital.title, message: capital.info, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}
}

