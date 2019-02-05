//
//  Repositories.swift
//  VodafoneTestApp
//
//  Created by Dk on 2/2/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import Foundation

struct SearchResults {
    let repoUserName : String
    let results : [RepoItem]
}


 class Repositories{
    
    func searchReposFor(_ userName: String, completion : @escaping (_ results: SearchResults?, _ error : NSError?) -> Void){
 
        guard let searchURL = searchURLForUser(userName) else {
            let APIError = NSError(domain: "GitHub Search", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                let APIError = NSError(domain: "GitHub Search", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response:\(error!.localizedDescription)"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "GitHub Search", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
            }
            
            do {
                guard let resultsArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [AnyObject] else{
                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String:AnyObject]
                    let message = dict?["message"]
                    let APIError = NSError(domain: "GitHub Search", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: message ?? "No repos was found"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                var repos = [RepoItem]()
                for repoObject in resultsArray{
                    
                    guard let name = repoObject["name"] as? String,
                        let full_name = repoObject["full_name"] as? String,
                        let created_at = repoObject["created_at"] as? String,
                        let stars = repoObject["stargazers_count"] as? NSInteger,
                        let forks = repoObject["forks_count"] as? NSInteger else {
                            break
                    }
                    
                    let description = repoObject["description"] as? String

                    let item = RepoItem( name:name, full_name:full_name, created_at:created_at, stars:stars, forks:forks, description:description ?? "" )
                    repos.append(item)
                    item.countCommitsAndBranches()
                }
                
                OperationQueue.main.addOperation({
                    completion(SearchResults(repoUserName: userName, results: repos), nil)
                })
                
            } catch _ {
                OperationQueue.main.addOperation({
                    completion(nil, nil)
                })
                return
            }
 
            
        }).resume()
    }
    
    func searchURLForUser(_ userName:String) -> URL? {
        
        guard let term = userName.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.github.com/orgs/\(term)/repos"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
    
    func loginGitHub(_ login:String, _ password:String, completion : @escaping (_ result: String?, _ error : NSError?)->Void ) {

        let url = URL(string: "https://api.github.com/user")

        var request = URLRequest(url: url!)

        request.addValue("Basic \("\(login):\(password)".toBase64())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                let APIError = NSError(domain: "GitHub Login", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response:\(error!.localizedDescription)"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            
            guard let data = data else {
                let APIError = NSError(domain: "GitHub Login", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"No data was found, error."])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                let APIError = NSError(domain: "GitHub Login", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"No json data, error."])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard  let dataLogin = json["login"] as? String else {
                let message = json["message"] as? String
            
                DispatchQueue.main.async(){
                    let APIError = NSError(domain: "GitHub Login", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Error message : \(String(describing: message))"])
                    completion(nil, APIError)
                }
                return
            }
            
            OperationQueue.main.addOperation({
                completion(dataLogin, nil)
            })
        }).resume()
    }
}
