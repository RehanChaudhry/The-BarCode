//
//  Category.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class Category: CoreStoreObject {
    
    var id = Value.Required<String>("id", initial: "")
    var title = Value.Required<String>("title", initial: "")
    var image = Value.Required<String>("image", initial: "")
    
    var level = Value.Required<String>("level", initial: "")
    
    var isSelected = Value.Required<Bool>("is_selected", initial: false)
    
    var hasChildren = Value.Required<Bool>("has_childs", initial:  false)
    
    var parentId = Value.Optional<String>("parent_id")
    
}

extension Category: ImportableUniqueObject {
    
    typealias ImportSource = [String: Any]
    
    class var uniqueIDKeyPath: String {
        return String(keyPath: \Category.id)
    }
    
    var uniqueIDValue: String {
        get { return self.id.value }
        set { self.id.value = newValue }
    }
    
    static func uniqueID(from source: [String : Any], in transaction: BaseDataTransaction) throws -> String? {
        return "\(source["id"]!)"
    }
    
    func didInsert(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func update(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        
        self.id.value = "\(source["id"]!)"
        self.title.value = source["title"] as! String
        self.image.value = source["image"] as? String ?? ""
        
        self.isSelected.value = source["is_user_interested"] as! Bool
        
        if let _ = source["parent_id"] {
            self.parentId.value = "\(source["parent_id"]!)"
        }
        
        if let _ = source["level"] {
            self.level.value = "\(source["level"]!)"
        } else {
            self.level.value = "0"
        }
        
        if let hasChildrens = source["has_children"] as? Bool,
            hasChildrens,
            let childrens = source["children"] as? [[String : Any]],
            childrens.count > 0 {
            
            let _ = try! transaction.importUniqueObjects(Into<Category>(), sourceArray: childrens)
            
            self.hasChildren.value = true
        } else {
            self.hasChildren.value = false
        }
    }
}
