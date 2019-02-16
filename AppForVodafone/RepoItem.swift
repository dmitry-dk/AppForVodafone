//
//  RepoItem.swift
//  VodafoneTestApp
//
//  Created by Dk on 2/2/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import Foundation

class RepoItem{
    let name:String        // "name": "codemod",
    let full_name:String   // "full_name": "facebook/codemod"
    let created_at:String  // "created_at": "2009-04-02T04:51:54Z",
    let stars:NSInteger    // "stargazers_count": 2706,
    let forks:NSInteger    // "forks_count": 145,
    let description:String // "description": "......."
    
    weak var apiManager: GitHubRequestManager?

    var commits:NSInteger = -1
    var branches:NSInteger = -1

    init ( name:String, full_name:String, created_at:String, stars:NSInteger, forks:NSInteger, description:String ) {
        self.name = name
        self.full_name = full_name
        self.created_at = created_at
        self.stars = stars
        self.forks = forks
        self.description = description
        apiManager = gitHubMng
    }
    
    init( _ mngr:GitHubRequestManager ) {
        self.name = "test"
        self.full_name = "test"
        self.created_at = "test"
        self.stars = 5
        self.forks = 5
        self.description = "test"
        apiManager = mngr
    }

    func loadCommits(){
        apiManager?.loadCommits( full_name ) { [weak self] (value, error) in
            if let error = error {
                debugPrint("Error searching : \(error.description)")
            }
            self?.commits = value
        }
    }

    func loadBranches(){
        apiManager?.loadBranches( full_name ){ [weak self] (value, error) in
            if let error = error {
                debugPrint("Error searching : \(error.description)")
            }
            self?.branches = value
        }
    }

    func countCommitsAndBranches(){
        loadCommits()
        loadBranches()
    }
}
