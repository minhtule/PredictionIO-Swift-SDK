//
//  ItemRecommendationViewController.swift
//  iOS Example
//
//  Created by Minh Tu Le on 3/6/15.
//  Copyright (c) 2015 PredictionIO. All rights reserved.
//

import PredictionIOSDK

class ItemRecommendationViewController: UIViewController {

    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var numberOfItemsTextField: UITextField!
    @IBOutlet weak var resultTableView: UITableView!
    
    let engineClient = EngineClient()
    var userID = 0
    var numberOfItems = 4
    var recommendationList: [[String: AnyObject]] = []

    @IBAction func requestButtonAction(sender: UIButton) {
        userID = userIDTextField.text.toInt()!
        numberOfItems = numberOfItemsTextField.text.toInt()!
        
        let query = [
            "user": userID,
            "num": numberOfItems
        ]
        
        engineClient.sendQuery(query) { (_, _, JSON, _) in
            if let data = JSON as? [String: [[String: AnyObject]]] {
                self.recommendationList = data["itemScores"]!
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.resultTableView.reloadData()
            }
        }
    }
}

extension ItemRecommendationViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendationList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecommendedItemCellIdentifier", forIndexPath: indexPath) as UITableViewCell
        let recommendedItem = recommendationList[indexPath.row]
        let itemID = recommendedItem["item"] as String
        let score = recommendedItem["score"] as Double
        cell.textLabel?.text = "ID: \(itemID),\t score: \(score)"
        
        return cell
    }
}
