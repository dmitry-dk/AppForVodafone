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
    
    var commits:NSInteger = -1
    var branches:NSInteger = -1

    init ( name:String, full_name:String, created_at:String, stars:NSInteger, forks:NSInteger, description:String ) {
        self.name = name
        self.full_name = full_name
        self.created_at = created_at
        self.stars = stars
        self.forks = forks
        self.description = description
    }
    
    func countCommitsAndBranches(){

        loadCommits({ [weak self] (value, error) in
            if let error = error {
                debugPrint("Error searching : \(error.description)")
            }
            self?.commits = value
        })

        loadBranches({ [weak self] (value, error) in
            if let error = error {
                debugPrint("Error searching : \(error.description)")
            }
            self?.branches = value
        })
    }
    
    
    func loadCommits(_ completion: @escaping (_ value:NSInteger, _ error: NSError?) -> Void) {
        guard let loadURL = URL(string: "https://api.github.com/repos/\(full_name)/stats/contributors") else {
            DispatchQueue.main.async {
                completion(-1, nil)
            }
            return
        }
        
        let loadRequest = URLRequest(url:loadURL)
        
        URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
            if let _ = error {
                let APIError = NSError(domain: "GitHubSearchRepoInfo_Commits", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response:\(error!.localizedDescription)"])
                DispatchQueue.main.async {
                    completion(-1, APIError)
                }
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "GitHubSearchRepoInfo_Commits", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(-1, APIError)
                    })
                    return
            }

            do {
                guard let resultsArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [AnyObject] else{

                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String:AnyObject]
                    let message = dict?["message"]
                    
                    let APIError = NSError(domain: "GitHubSearchRepoInfo_Commits", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: message ?? "No repo stats was found"])
                    OperationQueue.main.addOperation({
                        completion(-1, APIError)
                    })
                    return
                }
                
                var result = 0
                for repoObject in resultsArray{
                    
                    guard let total = repoObject["total"] as? NSInteger else {
                        break
                    }
                     result += total
                }
                
                OperationQueue.main.addOperation({
                    completion(result, nil)
                })
                
            } catch _ {
                let APIError = NSError(domain: "GitHubSearchRepoInfo_Commits", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:  "Catch an Error while is parsing response data"])
                OperationQueue.main.addOperation({
                    completion(-1, APIError)
                })
                return
            }
        }).resume()
    }
    
    
    func loadBranches(_ completion: @escaping (_ value:NSInteger, _ error: NSError?) -> Void) {
        guard let loadURL = URL(string: "https://api.github.com/repos/\(full_name)/branches") else {
            DispatchQueue.main.async {
                completion(-1, nil)
            }
            return
        }
        
        let loadRequest = URLRequest(url:loadURL)
        
        URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
            if let _ = error {
                let APIError = NSError(domain: "GitHubSearchRepoInfo_Branches", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response:\(error!.localizedDescription)"])
                DispatchQueue.main.async {
                    completion(-1, APIError)
                }
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "GitHubSearchRepoInfo_Branches", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(-1, APIError)
                    })
                    return
            }
            
            do {
                guard let resultsArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [AnyObject] else{

                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String:AnyObject]
                    let message = dict?["message"]

                    let APIError = NSError(domain: "GitHubSearchRepoInfo_Branches", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: message ?? "No repo branches was found"])
                    OperationQueue.main.addOperation({
                        completion(-1, APIError)
                    })
                    return
                }
                
                OperationQueue.main.addOperation({
                    completion(resultsArray.count, nil)
                })
                
            } catch _ {
                let APIError = NSError(domain: "GitHubSearchRepoInfo_Branches", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:  "Catch an Error while is parsing response data"])
                OperationQueue.main.addOperation({
                    completion(-1, APIError)
                })
                return
            }
        }).resume()
    }
    
}
