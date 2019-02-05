//
//  ViewListController.swift
//  VodafoneTestApp
//
//  Created by Dk on 2/2/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import Foundation
import UIKit

class ViewListController: UITableViewController, UITextFieldDelegate {

    fileprivate let reuseIdentifier =  "RepoCell"
    fileprivate var dataArray = [RepoItem]()
    
    // MARK: - DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    // MARK: Delegates

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell =  tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) 
        
        let repoItem = repoFor(indexPath)
        cell.textLabel?.text = repoItem.name
        
        return cell
    }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 40.0;
//    }
    
    // MARK: TextField

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        self.dataArray.removeAll()
        
        repositories.searchReposFor(textField.text!){
            results, error in

            activityIndicator.removeFromSuperview()

            if let error = error {

                self.tableView?.reloadData()
                
                let alert = UIAlertController(title: error.domain, message: error.userInfo[NSLocalizedFailureReasonErrorKey] as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    debugPrint("Error searching : \(error)")
                }))
                self.present(alert, animated: true, completion: nil)
                
                return
            }

            if let retValues = results {
                debugPrint("Found \(retValues.results.count) matching \(retValues.repoUserName)")
                self.dataArray = retValues.results
                self.tableView?.reloadData()
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC =  segue.destination as? ViewItemController else {
            return
        }
        
        if let indexPath = self.tableView?.indexPathForSelectedRow {
            let repo = repoFor(indexPath)
            nextVC.repo = repo
        }
    }
}

extension ViewListController {
    
    func repoFor(_ indexPath: IndexPath) -> RepoItem {
        return dataArray[indexPath.row]
    }
}
