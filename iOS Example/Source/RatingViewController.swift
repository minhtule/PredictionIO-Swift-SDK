//
//  RatingViewController.swift
//  iOS Example
//
//  Created by Minh Tu Le on 1/9/18.
//  Copyright © 2018 Minh Tu Le. All rights reserved.
//

import UIKit
import PredictionIO

let accessKey = "Your app's access key"

class RatingViewController: UIViewController {
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var movieIDTextField: UITextField!
    @IBOutlet var starButtons: [UIButton]!

    let eventClient = EventClient(accessKey: accessKey)
    var userID = ""
    var movieID = ""
    var rating = 0

    @IBAction func starButtonAction(_ sender: UIButton) {
        if sender.tag == rating {
            rating = 0
        } else {
            rating = sender.tag
        }

        starButtons.forEach { $0.isSelected = ($0.tag <= self.rating) }
    }

    @IBAction func rateButtonAction(_ sender: UIButton) {
        userID = userIDTextField.text ?? ""
        movieID = movieIDTextField.text ?? ""

        eventClient.recordAction("rate", byUserID: userID, onItemID: movieID, properties: ["rating": rating]) { response, error in
            let alertController: UIAlertController
            if let response = response {
                alertController = UIAlertController(title: "Successful", message: "EventID: \(response.eventID)", preferredStyle: .alert)
            } else {
                alertController = UIAlertController(title: "Failed", message: "\(error.debugDescription)", preferredStyle: .alert)
            }
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)

            DispatchQueue.main.async {
                self.present(alertController, animated: true)
            }
        }
    }
}
