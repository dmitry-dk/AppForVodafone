//
//  AppForVodafonTests.swift
//  AppForVodafonTests
//
//  Created by Dk on 2/5/19.
//  Copyright © 2019 Dmitro Kalmykov. All rights reserved.
//

import XCTest
@testable import AppForVodafone

let gitHubMng = GitHubRequestManager("https://api.github.com")

class AppForVodafonTests: XCTestCase {
    
    var repo:RepoItem!
    let testString = "test string"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        repo = RepoItem(name: "Alamofire", full_name: "Alamofire/Alamofire", created_at: "", stars: 5, forks: 5, description: "")

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        repo = nil
        super.tearDown()
    }
    
    
    func testSearchURLReposFor(){
        
        let theUrl = gitHubMng.searchURLReposFor("Alamofire")
        
        XCTAssertNotNil(theUrl)
    }
    
    
    func testSearchReposFor(){
        
        let exp = expectation(description: "Loading All Repositories for user")
        
        var testDataArray = [RepoItem]()

        gitHubMng.searchReposFor("Alamofire"){ results, error in
            
            exp.fulfill()
            
            if let retValues = results {
                testDataArray = retValues.results
            }
            
        }
        
        waitForExpectations(timeout: 3)
        
        XCTAssertEqual(testDataArray.count, 6, "We should have loaded exactly 6 Alamofire repositories.")
    }
    
    func testCountCommitsForRepoItem(){

        let exp = expectation(description: "Loading Repository Commits")
        
        self.repo.commits = -1
        
        gitHubMng.loadCommits(self.repo.full_name){ (value, error) in
            exp.fulfill()
            self.repo.commits = value
            
        }
        
        waitForExpectations(timeout: 3)
        
        XCTAssertTrue(repo.commits >= 0, "We should have loaded exactly commits >= 0.")
    }
    
    func testCountBranchesForRepoItem(){

        let exp = expectation(description: "Loading Repository Branches")

        self.repo.branches = -1

        gitHubMng.loadBranches(self.repo.full_name){ (value, error) in
            exp.fulfill()
            self.repo.branches = value
        }
        
        waitForExpectations(timeout: 3)
        
        XCTAssertTrue(repo.branches >= 0, "We should have loaded exactly branches >= 0.")
    }
    
    func testLoginToGitHub(){
        let exp = expectation(description: "Loading Pepository Commits")
        
        let login = "username"  //setup valid github username and password for test
        let password = "password"
        var retValues: String?
        
        gitHubMng.loginGitHub(login,password){ result, error in
            
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
        
        let resultTestString = testString.toBase64()
        
 //       print("STR = \(resultTestString)")
        
        XCTAssertTrue(resultTestString.count>0,  "We should get valid string.count > 0.")
    }
    
    func testFromBase64(){
        
        let testEndString = "dGVzdCBzdHJpbmc=".fromBase64()

//        print("STR = \(String(describing: testEndString))")

        XCTAssertNotNil(testEndString)
        XCTAssertTrue(testEndString == testString,  "We should get valid string: \(testString).")
   }
    
 
    
}
