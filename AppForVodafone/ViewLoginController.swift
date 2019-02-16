//
//  ViewLoginController.swift
//  VodafoneTestApp
//
//  Created by Dk on 2/2/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import UIKit

class ViewLoginController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var spinIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    fileprivate var keyboardShown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.spinIndicator.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if keyboardShown {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            let keyboardHeight = keyboardSize.height
            let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            let origin = self.stackView.frame.origin.y
            let ht = self.stackView.frame.size.height
            let diff = self.view.frame.size.height - origin - ht
            
            if diff < keyboardHeight {
                UIView.animate(withDuration: animationDuration, animations: { [weak self] () -> Void in
                    guard let selfy = self else { return }
                    selfy.view.frame = CGRect(x:selfy.view.frame.origin.x, y:-(keyboardHeight-diff), width:selfy.view.bounds.width, height:selfy.view.bounds.height)
                }, completion: nil)
            }
        }

        keyboardShown = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let animationDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double

        UIView.animate(withDuration: animationDuration, animations: {[weak self] () -> Void in
            guard let selfy = self else { return }
            selfy.view.frame = CGRect(x:selfy.view.frame.origin.x, y:0.0, width:selfy.view.bounds.width, height:selfy.view.bounds.height)
        }, completion: nil)

        keyboardShown = false
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

        gitHubMng.loginGitHub(login, secret){ results, error in
            
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




