//
//  ViewController.swift
//  Project21-ScheduledNotifications
//
//  Created by Mikhail Medvedev on 18.12.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UserNotifications
import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))

		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Scheduled", style: .plain, target: self, action: #selector(scheduledLocal))
	}

	@objc func registerLocal() {
		let center = UNUserNotificationCenter.current()

		center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
			if granted { print("Granted") }
			else { print("Not granted") }
		}

	}

	@objc func scheduledLocal() {
		registerCategories()

		let center = UNUserNotificationCenter.current()

		/*If you want to test out your notifications, there are two more things that will help.

		First, you can cancel pending notifications – i.e., notifications you have scheduled that have yet to be delivered because their trigger hasn’t been met – using the center.removeAllPendingNotificationRequests() method, like this: */

		center.removeAllPendingNotificationRequests()

		let content = UNMutableNotificationContent()
		content.title = "Время заниматься"
		content.body = "Вы запланировали тренировку на сегодня, пришло время размяться"
		content.categoryIdentifier = "alarm"
		content.userInfo = ["someKey":"some user info"]
		content.sound = .default

		var dateComponents = DateComponents()
		dateComponents.hour = 8
		dateComponents.minute = 14

		let dateTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

		let intervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: intervalTrigger)

		let dateRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: dateTrigger)

		center.add(request)
		center.add(dateRequest)

	}

	func registerCategories() {
		let center = UNUserNotificationCenter.current()
		center.delegate = self

		let showAction = UNNotificationAction(identifier: "show", title: "Tell me more", options: .foreground)
		let remindAction = UNNotificationAction(identifier: "remind", title: "Remind me later", options: [])

		let category = UNNotificationCategory(identifier: "alarm", actions: [showAction, remindAction], intentIdentifiers: [], options: [])

		center.setNotificationCategories([category])
	}

}

extension ViewController: UNUserNotificationCenterDelegate
{
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo

		if let customData = userInfo["someKey"] as? String {
			print("Custom data received: \(customData)")

				switch response.actionIdentifier {
				case UNNotificationDefaultActionIdentifier:
					// the user swiped to unlock
					print("Default identifier")

				case "show":
					// the user tapped our "show more info…" button
					print("Show more information…")
				case "remind":
					scheduledLocal()

				default:
					break
				}
		}

		 // you must call the completion handler when you're done
		completionHandler()
	}
}
