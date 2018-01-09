//
//  RecommendationViewController.swift
//  iOS Example
//
//  Created by Minh Tu Le on 1/9/18.
//  Copyright © 2018 Minh Tu Le. All rights reserved.
//

import UIKit
import PredictionIO

class RecommendationViewController: UIViewController {
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var numberOfItemsTextField: UITextField!
    @IBOutlet weak var resultTableView: UITableView!

    let engineClient = EngineClient()
    var userID = 1
    var numberOfItems = 4
    var recommendation: [RecommendationResponse.ItemScore] = []

    @IBAction func recommendButtonAction(_ sender: UIButton) {
        userID = Int(userIDTextField.text!)!
        numberOfItems = Int(numberOfItemsTextField.text!)!

        let query = [
            "user": userID,
            "num": numberOfItems
        ]

        engineClient.sendQuery(query, responseType: RecommendationResponse.self) { [weak self] response, error in
            if let response = response {
                self?.recommendation = response.itemScores
            } else {
                self?.recommendation = []

                let alertController = UIAlertController(title: "Failed", message: "\(error.debugDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okAction)
                self?.present(alertController, animated: true)
            }

            DispatchQueue.main.async {
                self?.resultTableView.reloadData()
            }
        }
    }
}

extension RecommendationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendation.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendedItemCellIdentifier", for: indexPath)
        let recommendedItem = recommendation[indexPath.row]
        cell.textLabel?.text = "Item ID: \(recommendedItem.itemID),\t score: \(recommendedItem.score)"

        return cell
    }
}

struct RecommendationResponse: Decodable {
    struct ItemScore: Decodable {
        let itemID: String
        let score: Double

        enum CodingKeys: String, CodingKey {
            case itemID = "item"
            case score
        }
    }

    let itemScores: [ItemScore]
}
