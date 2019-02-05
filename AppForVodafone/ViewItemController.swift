//
//  ViewItemController.swift
//  VodafoneTestApp
//
//  Created by Dk on 2/2/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import Foundation

import UIKit

class ViewItemController: UIViewController {
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var forkLabel: UILabel!
    @IBOutlet weak var commitsLabel: UILabel!
    @IBOutlet weak var branchesLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    
    var repo:RepoItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let _ = repo else {
            return
        }
        
        self.navigationItem.title = repo!.name
        starLabel.text = "\(repo!.stars)"
        forkLabel.text = "\(repo!.forks)"
        commitsLabel.text = "\(repo!.commits < 0 ? 0: repo!.commits) commit" + (repo!.commits > 1 ? "s": "" )
        branchesLabel.text = "\(repo!.branches < 0 ? 0: repo!.branches) branch" + (repo!.branches > 1 ? "es": "" )
        descriptionText.text = repo!.description
    }
    
    
}

