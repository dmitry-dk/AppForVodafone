//
//  GitHubRequestManager.swift
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

 class GitHubRequestManager{
    
    let baseURLAddress:String
        
    init(_ apiAddress:String) {
        baseURLAddress = apiAddress
    }

    func searchReposFor(_ userName: String, completion : @escaping (_ results: SearchResults?, _ error : NSError?) -> Void){
 
        guard let searchURL = searchURLReposFor(userName) else {
            let APIError = NSError(domain: "GitHub Search", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Incorrect repository name string"])
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
    
    func searchURLReposFor(_ userName:String) -> URL? {
        
        guard let term = userName.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = baseURLAddress+"/orgs/\(term)/repos"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
    
    func loginGitHub(_ login:String, _ password:String, completion : @escaping (_ result: String?, _ error : NSError?)->Void ) {

        guard let url = URL(string: baseURLAddress+"/user") else {
            let APIError = NSError(domain: "GitHub Login", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Incorrect URL for API connection"])
            completion(nil, APIError)
            return;
        }
        
        var request = URLRequest(url: url)

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


    func loadCommits(_ full_name:String, _ completion: @escaping (_ value:NSInteger, _ error: NSError?) -> Void) {
        
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

    
    func loadBranches(_ full_name:String, _ completion: @escaping (_ value:NSInteger, _ error: NSError?) -> Void) {
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
