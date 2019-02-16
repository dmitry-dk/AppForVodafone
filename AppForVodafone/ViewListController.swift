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

    @IBOutlet weak var userNameTextField: UITextField!
    
    fileprivate let reuseIdentifier = "RepoCell"
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate let dataController = ReposDataController()

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(dataWillStartReload), name: Notification.Name(rawValue: reloadDataWillStartNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidEndReload), name: Notification.Name(rawValue: reloadDataDidEndNotification), object: nil)
    }
    
    fileprivate func reloadData(){
        
        guard let tableView = (self.view as? UITableView) else {
            return
        }
        
        tableView.reloadData()
    }


    
    // MARK: Delegates

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataController.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell =  tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) 
        
        let repoItem = dataController.repoFor(indexPath)
        cell.textLabel?.text = repoItem.name
        
        return cell
    }

    
    // MARK: TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = textField.text, text.count > 0 else {
            return false
        }
        
        dataController.newSearch(text)
        
        textField.resignFirstResponder()

        return true
    }
    
    // MARK: DataController notification

    @objc func dataWillStartReload(notification: NSNotification) {

        userNameTextField.addSubview(activityIndicator)
        activityIndicator.frame = userNameTextField.bounds
        activityIndicator.startAnimating()
    }

    @objc func dataDidEndReload(notification: Notification){
        
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        reloadData()

        if let error = notification.object as? NSError {
            let alert = UIAlertController(title: error.domain, message: error.userInfo[NSLocalizedFailureReasonErrorKey] as? String, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                debugPrint("Error searching : \(error)")
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC =  segue.destination as? ViewItemController else {
            return
        }
        
        if let indexPath = self.tableView?.indexPathForSelectedRow {
            let repo = dataController.repoFor(indexPath)
            nextVC.repo = repo
        }
    }
}
