//
//  UICollectionView.swift
//  Lidl
//
//  Created by Luke Tomlinson on 12/7/17.
//  Copyright © 2017 WillowTree. All rights reserved.
//

import Foundation

extension UICollectionView {
    
    func apply(updates: [TableUpdate]) {
        
        let updateBlock = {
            
            for update in updates {
                
                switch update {
                case .insertSections(let indexSet):
                    self.insertSections(indexSet)
                
                case .deleteSections(let indexSet):
                    self.deleteSections(indexSet)
                
                case .insertRows(let indexPaths):
                    self.insertItems(at: indexPaths)
                
                case .deleteRows(let indexPaths):
                    self.deleteItems(at: indexPaths)
                
                case .move(let oldIndexPath, let newIndexPath):
                    self.moveItem(at: oldIndexPath, to: newIndexPath)
    
                case .reload(let indexPath):
                    self.reloadItems(at: [indexPath])
                    
                case .reloadData:
                    self.reloadData()
    
                case .none:
                    break
                }
                
            }
        }
        
        
        performBatchUpdates(updateBlock, completion: nil)
        
    }
    
}
