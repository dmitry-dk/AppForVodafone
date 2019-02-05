//
//  AppForVodafonTests.swift
//  AppForVodafonTests
//
//  Created by Dk on 2/5/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import XCTest
@testable import AppForVodafone

let repositories = Repositories()

class AppForVodafonTests: XCTestCase {
    
    var repo:RepoItem!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        repo = RepoItem(name: "facebook", full_name: "facebook/codemod", created_at: "", stars: 5, forks: 5, description: "")

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        repo = nil
        super.tearDown()
    }
    
    
    func testSearchURLForUser(){
        
        let theUrl = repositories.searchURLForUser("facebook")
        
        XCTAssertNotNil(theUrl)
    }
    
    
    func testSearchReposFor(){
        
        let exp = expectation(description: "Loading All Repositories for user")
        
        var testDataArray = [RepoItem]()

        repositories.searchReposFor("facebook"){ results, error in
            
            exp.fulfill()
            
            if let retValues = results {
                testDataArray = retValues.results
            }
            
        }
        
        waitForExpectations(timeout: 3)
        
        XCTAssertEqual(testDataArray.count, 30, "We should have loaded exactly 30 facebook repositories.")
    }
    
    func testCountCommitsForRepoItem(){

        let exp = expectation(description: "Loading Repository Commits")
        
        self.repo.commits = -1
        
        self.repo.loadCommits({ (value, error) in
            exp.fulfill()
            self.repo.commits = value
            
        })
        
        waitForExpectations(timeout: 3)
        
        XCTAssertTrue(repo.commits >= 0, "We should have loaded exactly commits >= 0.")
    }
    
    func testCountBranchesForRepoItem(){

        let exp = expectation(description: "Loading Repository Branches")

        self.repo.branches = -1

        self.repo.loadBranches({ (value, error) in
            exp.fulfill()
            self.repo.branches = value
            
        })
        
        waitForExpectations(timeout: 3)
        
        XCTAssertTrue(repo.branches >= 0, "We should have loaded exactly branches >= 0.")
    }
    
    func testLoginToGitHub(){
        let exp = expectation(description: "Loading Pepository Commits")
        
        let login = "username"  //set valid username and password for test
        let password = "password"
        var retValues: String?
        
        repositories.loginGitHub(login,password){ result, error in
            
            exp.fulfill()
            
            if let _ = error {
                return
            }
            
            retValues = result
        }
        
        waitForExpectations(timeout: 3)
        
        XCTAssertTrue((retValues?.count)! > 0,  "We should get valid login string.")
    }
    
    
    func testToBase64(){
        
        let testString = "test string".toBase64()
        
//        print("STR = \(testString)")
        
        XCTAssertNotNil(testString)
    }
    
    func testFromBase64(){
        
        let testEndString = "dGVzdCBzdHJpbmc=".fromBase64()
        
        XCTAssertNotNil(testEndString)
    }
    
    func testInitRepoItem(){
        let repo = RepoItem(name: "facebook", full_name: "facebook/codemod", created_at: "", stars: 5, forks: 5, description: "")
        
        XCTAssertNotNil(repo)
    }
 
    
}
