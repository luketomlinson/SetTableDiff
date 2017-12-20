//
//  TableUpdateTests.swift
//  LidlTests
//
//  Created by Luke Tomlinson on 12/1/17.
//  Copyright © 2017 WillowTree. All rights reserved.
//

import XCTest
@testable import Lidl
@testable import LidlModel

class TableUpdateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func createEmptyList(_ title: String) -> List {
     
        let list = List(entries: [], title: title, id: nil, createdDate: Date(), createdBy: "me", members: [], isDummyList: false, complete: false, persistenceID: URL.init(fileURLWithPath: UUID().uuidString), allMembersString: "")
        
        return list
    }
    
    func testDeletes() {
        
        let titles = ["list1", "list2", "list3", "list4"]
        let old = titles.map(createEmptyList)
        
        var new = old
        new.removeLast()
        
        let updates = TableUpdate.generateUpdates(newElements: new, oldElements: old, in: 0)
        
        XCTAssertEqual(updates.count, 1)
        
        switch (updates[0]) {
        case .deleteRows(let indexPath):
            XCTAssertEqual(indexPath[0], IndexPath(row: 3, section: 0))
        default:
            XCTFail("should have been a delete")
        }
        
    }
    
    func testInserts() {
        
        let titles = ["list1", "list2", "list3", "list4"]
        let old = titles.map(createEmptyList)
        
        var new = old
        new.append(createEmptyList("list5"))
        
        let updates = TableUpdate.generateUpdates(newElements: new, oldElements: old, in: 0)
        
        XCTAssertEqual(updates.count, 1)
        
        switch (updates[0]) {
        case .insertRows(let indexPaths):
            XCTAssertEqual(indexPaths[0], IndexPath(row: 4, section: 0))
        default:
            XCTFail("should have been an insert")
        }
        
    }
    
    func testMoves() {
        let titles = ["list1", "list2", "list3", "list4"]
        let old = titles.map(createEmptyList)
        
        var new = old
        var first = new.removeFirst()
        first.members.append("joe@test.com")
        new.append(first)
        
        let updates = TableUpdate.generateUpdates(newElements: new, oldElements: old, in: 0)
        
        XCTAssertEqual(updates.count, 1)
        
        switch (updates[0]) {
        case .move(let oldIndexPath, let newIndexPath):
            XCTAssertEqual(oldIndexPath, IndexPath(row: 0, section: 0))
            XCTAssertEqual(newIndexPath, IndexPath(row: 3, section: 0))

        default:
            XCTFail("should have been a move")
        }
    }
    
    func testInsertSection() {
        let titles = ["list1", "list2", "list3", "list4"]
        let old: [List] = []
        let new = titles.map(createEmptyList)
        
        let updates = TableUpdate.generateUpdates(newElements: new, oldElements: old, in: 0)
        
        XCTAssertEqual(updates.count, 2)
        updates.forEach { update in
            switch (update) {
            case .insertRows(let indexPaths):
                XCTAssertTrue(indexPaths.contains(IndexPath(row: 0, section: 0)))
                XCTAssertTrue(indexPaths.contains(IndexPath(row: 1, section: 0)))
                XCTAssertTrue(indexPaths.contains(IndexPath(row: 2, section: 0)))
                XCTAssertTrue(indexPaths.contains(IndexPath(row: 3, section: 0)))
                
            case .insertSections(let indexSet):
                XCTAssertTrue(indexSet.contains(0))
                XCTAssertEqual(indexSet.count, 1)
            default:
                XCTFail("should not get here")
            }
        }
    }
    
    func testDeleteSection() {
        let titles = ["list1", "list2", "list3", "list4"]
        let old = titles.map(createEmptyList)
        let new: [List] = []

        
        let updates = TableUpdate.generateUpdates(newElements: new, oldElements: old, in: 0)
        
        XCTAssertEqual(updates.count, 2)
        updates.forEach { update in
            switch (update) {
            case .deleteRows(let indexPaths):
                XCTAssertTrue(indexPaths.contains(IndexPath(row: 0, section: 0)))
                XCTAssertTrue(indexPaths.contains(IndexPath(row: 1, section: 0)))
                XCTAssertTrue(indexPaths.contains(IndexPath(row: 2, section: 0)))
                XCTAssertTrue(indexPaths.contains(IndexPath(row: 3, section: 0)))
                
            case .deleteSections(let indexSet):
                XCTAssertTrue(indexSet.contains(0))
                XCTAssertEqual(indexSet.count, 1)
            default:
                XCTFail("should not get here")
            }
        }
    }
    
    func testReload() {
        
        let titles = ["list1", "list2", "list3", "list4"]
        let old = titles.map(createEmptyList)
        
        var new = old
        new[0].title = "ListModified"
        
        let updates = TableUpdate.generateUpdates(newElements: new, oldElements: old, in: 0)
        
        XCTAssertEqual(updates.count, 1)
        
        switch (updates[0]) {
        case .reload(let indexPath):
            XCTAssertEqual(indexPath, IndexPath(row: 0, section: 0))
        default:
            XCTFail("should have been a reload")
        }
        
    }
    
}
