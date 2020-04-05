//
//  ViewController.swift
//  ConstraintsInCode
//
//  Created by Mikhail Medvedev on 23.10.2019.
//  Copyright © 2019 Mikhail Medvedev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label1 = UILabel()
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.text = "THESE"
        label1.backgroundColor = .red
        label1.sizeToFit()
        
        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.text = "ARE"
        label2.backgroundColor = .green
        label2.sizeToFit()
        
        let label3 = UILabel()
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.text = "SOME"
        label3.backgroundColor = .blue
        label3.sizeToFit()
        
        let label4 = UILabel()
        label4.translatesAutoresizingMaskIntoConstraints = false
        label4.text = "AWESOME"
        label4.backgroundColor = .yellow
        label4.sizeToFit()
        
        let label5 = UILabel()
        label5.translatesAutoresizingMaskIntoConstraints = false
        label5.text = "LABELS"
        label5.backgroundColor = .orange
        label5.sizeToFit()
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        view.addSubview(label4)
        view.addSubview(label5)
        
//        let viewDict = [
//            "label1":label1,
//            "label2":label2,
//            "label3":label3,
//            "label4":label4,
//            "label5":label5
//        ]
//
//        for label in viewDict.keys {
//            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: viewDict))
//        }
//
//        let metrics = ["labelHeight":180]
//
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==36)-[label1(>=labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: metrics, views: viewDict))
//
//
        var previous: UILabel?
        
        for label in [label1, label2, label3, label4, label5] {
          //  label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true

            
            if let previous = previous {
                label.topAnchor.constraint(greaterThanOrEqualTo: previous.bottomAnchor, constant: 4).isActive = true
                label.heightAnchor.constraint(equalTo: previous.heightAnchor).isActive = true
            } else {
                label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/5, constant: 0).isActive = true
            }
            
            previous = label
            
        }
    
}

}
