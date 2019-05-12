//
//  DataController.swift
//  TouristApp
//
//  Created by Hazem on 5/11/19.
//  Copyright © 2019 Hazem. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    static let shared = DataController(modelName: "TouristApp")
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init(modelName:String) {
        persistentContainer = NSPersistentContainer(name:modelName)
    }
    
    func load(completion:(()->Void)? = nil ){
        persistentContainer.loadPersistentStores{ storeDescription,error in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?	()
        }
    }
}
