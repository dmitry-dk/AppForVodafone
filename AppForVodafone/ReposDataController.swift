//
//  ReposDataController.swift
//  AppForVodafone
//
//  Created by Dk on 2/15/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import Foundation


let reloadDataWillStartNotification =  "ReloadDataWillStartNotification"
let reloadDataDidEndNotification = "ReloadDataDidEndNotification"

class ReposDataController{
    
    fileprivate var dataArray:[RepoItem]
    weak var apiManager: GitHubRequestManager?
    
    
    init() {
        dataArray = [RepoItem]()
        apiManager = gitHubMng
    }
    
    init(_ data:[RepoItem] ) {
        dataArray = data
    }
    
    init(_ data:[RepoItem], _ mngr:GitHubRequestManager ) {
        dataArray = data
        apiManager = mngr
    }

    
    var count:Int {
        return dataArray.count
    }
    
    fileprivate func postWillStartNotification(){
        NotificationCenter.default.post( Notification(name: Notification.Name(rawValue: reloadDataWillStartNotification), object: nil, userInfo: nil) )
    }
    
    fileprivate func postDidEndNotification(_ error: NSError? ){
        NotificationCenter.default.post( Notification(name: Notification.Name(rawValue: reloadDataDidEndNotification), object: error, userInfo:nil ) )
    }
    
    
    func repoFor(_ indexPath: IndexPath) -> RepoItem {
        return dataArray[indexPath.row]
    }

    
    func newSearch(_ repoName:String ){
        
        postWillStartNotification()

        self.dataArray.removeAll()
        
        apiManager?.searchReposFor(repoName){ [weak self] results, error in
            
            guard let selfy = self else { return }
            if let retValues = results, error == nil {
                debugPrint("Found \(retValues.results.count) matching \(retValues.repoUserName)")
                selfy.dataArray = retValues.results
            }
            
            selfy.postDidEndNotification( error )
        }
    }
}
