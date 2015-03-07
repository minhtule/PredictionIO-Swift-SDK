//
//  DataCollectorViewController.swift
//  iOS Example
//
//  Created by Minh Tu Le on 3/6/15.
//  Copyright (c) 2015 PredictionIO. All rights reserved.
//

import UIKit
import PredictionIOSDK

// NOTE: replace with your app's access key here!
let accessKey = ""

class DataCollectorViewController: UIViewController {

    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var movieIDTextField: UITextField!
    @IBOutlet var starButtons: [UIButton]!
    
    let eventClient = EventClient(accessKey: accessKey)
    var userID = ""
    var movieID = ""
    var rating = 0
    
    @IBAction func starButtonAction(sender: UIButton) {
        if sender.tag == rating {
            rating = 0
        } else {
            rating = sender.tag
        }
        
        starButtons.map { $0.selected = ($0.tag <= self.rating) }
    }
    
    @IBAction func rateButtonAction(sender: UIButton) {
        userID = userIDTextField.text
        movieID = movieIDTextField.text
        
        eventClient.recordAction("rate", byUserID: userID, itemID: movieID, properties: ["rating": rating], completionHandler: { (_, response, JSON, error) in
            var alertView: UIAlertView!
            
            if let data = JSON as? [String: AnyObject] {
                if response?.statusCode == 201 {
                    // Successful!
                    let eventID = data["eventId"] as String
                    alertView = UIAlertView(title: "Successful", message: "EventID: \(eventID)", delegate: nil, cancelButtonTitle: "OK!")
                } else {
                    // Invalid access key.
                    alertView = UIAlertView(title: "Failed", message: data["message"] as? String, delegate: nil, cancelButtonTitle: "OK!")
                }
            } else {
                // Other connection error e.g. event server is not running.
                alertView = UIAlertView(title: "Error", message: error?.description, delegate: nil, cancelButtonTitle: "OK!")
            }
            
            alertView.show()
        })
    }
}
