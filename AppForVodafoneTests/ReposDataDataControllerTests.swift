//
//  ReposDataDataControllerTests.swift
//  AppForVodafoneTests
//
//  Created by Dk on 2/16/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import XCTest
@testable import AppForVodafone

class ReposDataDataControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testInitDataController(){
        let controller = ReposDataController()
        
        XCTAssertNotNil(controller)

    }
    
    func testCountDataCntrl(){
   
        let repo = RepoItem(name: "facebook", full_name: "facebook/codemod", created_at: "", stars: 5, forks: 5, description: "")
        let data = [repo,repo]
        
        let controller = ReposDataController(data)
        
        XCTAssertTrue(controller.count == 2,  "We should get count == 2.")
    }
    
    
    func testRepoFor(){
        let repo1 = RepoItem(name: "facebook", full_name: "facebook/codemod", created_at: "", stars: 5, forks: 5, description: "")
        let repo2 = RepoItem(name: "dmitry-dk", full_name: "dmitry-dk/repos", created_at: "", stars: 5, forks: 5, description: "")
        let data = [repo1,repo2]
        
        let controller = ReposDataController(data)
        
        let repoValue = controller.repoFor(IndexPath(row: 1, section: 1))
        
        XCTAssertTrue(repoValue.name == repo2.name,  "We should get name: \(repo2.name), not: \(repoValue.name).")
    }

    
    func testNewSearch(){
        class FakeGitHubMng: GitHubRequestManager{
            override  func searchReposFor(_ userName: String, completion : @escaping (_ results: SearchResults?, _ error : NSError?) -> Void){
                let APIError = NSError(domain: "GitHub Search", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Incorrect repository name string"])
                completion(nil, APIError)
            }
        }
        let repo = RepoItem(name: "facebook", full_name: "facebook/codemod", created_at: "", stars: 5, forks: 5, description: "")
        let data = [repo,repo]
        
        let fakeMng = FakeGitHubMng.init("https://api.github.com")
        let controller = ReposDataController(data, fakeMng)
        
        let preCount = controller.count
        
        controller.newSearch("testName")
        
        XCTAssertTrue(preCount != controller.count && controller.count == 0,  "We should get count = 0")
    }
    
}
