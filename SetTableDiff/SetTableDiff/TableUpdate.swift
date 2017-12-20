//
//  TableUpdate.swift
//  Lidl
//
//  Created by Luke Tomlinson on 11/30/17.
//  Copyright © 2017 WillowTree. All rights reserved.
//

import Foundation

public enum TableUpdate {
    
    case insertRows([IndexPath])
    case deleteRows([IndexPath])
    case insertSections(IndexSet)
    case deleteSections(IndexSet)
    case move(oldIndexPath: IndexPath, newIndexPath: IndexPath)
    case reload(IndexPath)
    case reloadData
    case none
    
    struct Move {
        let oldIndexPath: IndexPath
        let newIndexPath: IndexPath
        
        var update: TableUpdate {
            if oldIndexPath == newIndexPath {
                return TableUpdate.reload(oldIndexPath)
            }
            
            return TableUpdate.move(oldIndexPath: oldIndexPath, newIndexPath: newIndexPath)
        }
    }
    
    public static func generateUpdates<T: Hashable>(newElements: [T], oldElements: [T], in section: Int, allowedEmptySections: IndexSet = []) -> [TableUpdate] {
        
        var updates: [TableUpdate] = []
        
        let oldSet = Set<T>(oldElements)
        let newSet = Set<T>(newElements)
        
        //Get deletions and insertions from the old and new
        let deletions = oldSet.subtracting(newSet)
        let insertions = newSet.subtracting(oldSet)
        
        //Map the deletions and insertions to indexPaths, but keep the item so we can calculate moves
        let deletionItemsAndIndexPaths = deletions.flatMap { itemToDelete -> (T, IndexPath)? in
            
            guard let index = oldElements.index(of: itemToDelete) else { return nil }
            return (itemToDelete, IndexPath(row: index, section: section))
        }
        
        let insertionItemsAndIndexPaths = insertions.flatMap { itemToInsert -> (T, IndexPath)? in
            
            guard let index = newElements.index(of: itemToInsert) else { return nil }
            return (itemToInsert, IndexPath(row: index, section: section))
        }
        
        //Calculate moves based on unique hash values
        //Get a Set<Int> of hashes that represent the unique ids of items to be moved
        //"Moves" will be the set of hashes that are both in insertHahes and deleteHashes
        //In our case this will only detect a "move" when the object has changed
        //This will not detect moves where the object is not changing
        let deleteHashes = Set<Int>(deletions.map({$0.hashValue}))
        let insertHashes = Set<Int>(insertions.map({$0.hashValue}))
        let moveHashes = deleteHashes.intersection(insertHashes)
        
        
        //figure out which index paths are moving from where to where
        let moves = moveHashes.flatMap { moveHash -> Move? in
            
            //go back and get the indices to figure out where we are moving from
            //and where we are moving to
            guard let oldIndex = oldElements.index(where: {$0.hashValue == moveHash}),
                let newIndex = newElements.index(where: {$0.hashValue == moveHash}) else {
                    return nil
            }
            
            return Move(oldIndexPath: IndexPath(row: oldIndex, section: section), newIndexPath: IndexPath(row: newIndex, section: section))
        }
        
        //function to apply to remove any items that are truly a "move"
        //from the insert and delete indexPaths
        let indexPathMap: (T, IndexPath) -> IndexPath? = { item, indexPath in
            moveHashes.contains(item.hashValue) ? nil : indexPath
        }
        
        //remove the "move" index paths from the deletions and insertions
        let deletionIndexPaths = deletionItemsAndIndexPaths.flatMap(indexPathMap)
        let insertionIndexPaths = insertionItemsAndIndexPaths.flatMap(indexPathMap)
        
        //see if any of our inserts and deletes are causing a section to be deleted or inserted
        let (sectionsToInsert, sectionsToDelete) = sectionInsertsAndDeletes(old: oldElements, new: newElements, section: section, allowedEmptySections: allowedEmptySections)
        
        moves.forEach { move in
            updates.append(move.update)
        }
        
        if !deletionIndexPaths.isEmpty {
            updates.append(.deleteRows(deletionIndexPaths))
        }
        
        if !insertionIndexPaths.isEmpty {
            updates.append(.insertRows(insertionIndexPaths))
        }
        
        if !sectionsToInsert.isEmpty {
            updates.append(.insertSections(sectionsToInsert))
        }
        
        if !sectionsToDelete.isEmpty {
            updates.append(.deleteSections(sectionsToDelete))
        }
        
        return updates
    }
    
    static func sectionInsertsAndDeletes<T>(old oldItems: [T],
                                            new newItems: [T],
                                            section: Int,
                                            allowedEmptySections: IndexSet) -> (inserts: IndexSet, deletes: IndexSet) {
        
        var sectionsToInsert: IndexSet = []
        var sectionsToDelete: IndexSet = []
        
        switch (oldItems.isEmpty, newItems.isEmpty) {
        case (true, false) where !allowedEmptySections.contains(section):
            sectionsToInsert.insert(section)
        case (false, true) where !allowedEmptySections.contains(section):
            sectionsToDelete.insert(section)
        default:
            break
        }
        
        return (sectionsToInsert, sectionsToDelete)
        
    }
    
}
