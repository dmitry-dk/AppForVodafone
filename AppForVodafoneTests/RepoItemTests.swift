//
//  RepoItemTests.swift
//  AppForVodafoneTests
//
//  Created by Dk on 2/16/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import XCTest

class RepoItemTests: XCTestCase {
    
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
    
    func testInitRepoItem(){
        let repo = RepoItem(name: "facebook", full_name: "facebook/codemod", created_at: "", stars: 5, forks: 5, description: "")
        
        XCTAssertNotNil(repo)
    }

    
    func testLoadCommits(){
        class FakeGitHubMng: GitHubRequestManager{
            override func loadCommits(_ full_name:String, _ completion: @escaping (_ value:NSInteger, _ error: NSError?) -> Void) {
                let APIError = NSError(domain: "GitHub Search", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Incorrect repository name string"])
                completion(10, APIError)
            }
        }

        let fakeMng = FakeGitHubMng.init("https://api.github.com")
        let item = RepoItem( fakeMng)

        item.loadCommits()
        
        XCTAssertTrue(item.commits == 10,  "We should get commits = 10")
    }
    
    func testLoadBranches(){
        class FakeGitHubMng: GitHubRequestManager{
            override func loadBranches(_ full_name:String, _ completion: @escaping (_ value:NSInteger, _ error: NSError?) -> Void) {
                let APIError = NSError(domain: "GitHub Search", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Incorrect repository name string"])
                completion(10, APIError)
            }
        }
        
        let fakeMng = FakeGitHubMng.init("https://api.github.com")
        let item = RepoItem( fakeMng)
        
        item.loadBranches()
        
        XCTAssertTrue(item.branches == 10,  "We should get branches = 10")
    }
}
