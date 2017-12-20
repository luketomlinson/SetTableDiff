//
//  UITableView.swift
//  Lidl Pilot
//
//  Created by Andrew Carter on 8/3/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation
import UIKit

typealias CellUpdateHandler = (UITableViewCell, IndexPath) -> Void
extension UITableView {
    
    func applyUpdates(updates: [TableUpdate], cellUpdateHandler: CellUpdateHandler? = nil) {
        
        updates.forEach { reloadOrMove in
            
            switch reloadOrMove {
            case .move(let oldIndexPath, let newIndexPath):
                moveRow(at: oldIndexPath, to: newIndexPath)
                
                if let handler = cellUpdateHandler, let cell = cellForRow(at: newIndexPath) {
                    handler(cell, newIndexPath)
                }
                
            case .reload(let indexPath):
                
                if let handler = cellUpdateHandler, let cell = cellForRow(at: indexPath) {
                    handler(cell, indexPath)
                }
                
            case .reloadData:
                
                reloadData()
                
            default:
                break
            }
        }
        
        
        beginUpdates()
        
        updates.forEach { update in
            switch update {
            case .insertRows(let indexPaths):
                insertRows(at: indexPaths, with: .automatic)
                
            case .deleteRows(let indexPaths):
                deleteRows(at: indexPaths, with: .automatic)
                
            case .insertSections(let indexSet):
                insertSections(indexSet, with: .top)
                
            case .deleteSections(let indexSet):
                deleteSections(indexSet, with: .fade)
                
            default:
                break
            }
        }
        
        endUpdates()
        
        
        
    }
    
}
