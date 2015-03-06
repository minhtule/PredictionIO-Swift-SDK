//
//  DataCollectorViewController.swift
//  iOS Example
//
//  Created by Minh Tu Le on 3/6/15.
//  Copyright (c) 2015 PredictionIO. All rights reserved.
//

import PredictionIOSDK

let accessKey = "9CQhFdGrLDgYkez9cwFkGAEU0Krfup3GLkdQ8r3pkOjO61BhL4BkjJ1F8CuShJey"

class DataCollectorViewController: UIViewController {

    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var movieIDTextField: UITextField!
    @IBOutlet var startButtons: [UIButton]!
    
    let eventClient = EventClient(accessKey: accessKey)
    var userID = ""
    var movieID = ""
    var rating = 0
    
    @IBAction func startButtonAction(sender: UIButton) {
        if sender.tag == rating {
            rating = 0
        } else {
            rating = sender.tag
        }
        
        startButtons.map { $0.selected = ($0.tag <= self.rating) }
    }
    
    @IBAction func rateButtonAction(sender: UIButton) {
        userID = userIDTextField.text
        movieID = movieIDTextField.text
        
        eventClient.recordAction("rate", byUserID: userID, itemID: movieID, properties: ["rating": rating], completionHandler: { (_, _, JSON, error) in
            var alertView: UIAlertView!
            
            if let data = JSON as? [String: AnyObject] {
                let eventID = data["eventId"] as String
                alertView = UIAlertView(title: "Successful", message: "EventID: \(eventID)", delegate: nil, cancelButtonTitle: "OK!")
            } else {
                alertView = UIAlertView(title: "Error", message: error?.description, delegate: nil, cancelButtonTitle: "OK!")
            }
            
            alertView.show()
        })
    }
}
