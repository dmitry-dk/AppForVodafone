//
//  ViewLoginController.swift
//  VodafoneTestApp
//
//  Created by Dk on 2/2/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import UIKit

class ViewLoginController: UIViewController {

    @IBOutlet weak var spinIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinIndicator.isHidden = true
    }

    @IBAction func loginPressed(_ sender: Any) {
        if loginField.text?.count == 0  || passwordField.text?.count == 0 {
            //            SysBeep
            return
        }
        
        loginButton.isEnabled = false
        spinIndicator.isHidden = false
        spinIndicator.startAnimating()
        
        let login = loginField.text!
        let secret = passwordField.text!

        repositories.loginGitHub(login, secret){ results, error in
            
            self.loginButton.isEnabled = true
            self.spinIndicator.isHidden = true
            self.spinIndicator.stopAnimating()
            
            if let error = error {
                let alert = UIAlertController(title: error.domain, message: error.userInfo[NSLocalizedFailureReasonErrorKey] as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    debugPrint("Error searching : \(error)")
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if results == login {
                self.performSegue(withIdentifier: "showListView", sender: self)
            }
        }
    }
 }

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}


