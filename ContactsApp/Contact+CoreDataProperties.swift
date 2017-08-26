//
//  Contact.swift
//  ContactsApp
//
//  Created by Michael Haley on 8/14/17.
//  Copyright © 2017 Michael Haley. All rights reserved.
//

import Foundation
import CoreData

class Contact: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass

    @NSManaged var location: String
    @NSManaged var name: String
    
}
