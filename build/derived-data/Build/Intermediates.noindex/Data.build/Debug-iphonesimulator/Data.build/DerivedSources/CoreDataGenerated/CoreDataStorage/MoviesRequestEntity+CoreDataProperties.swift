//
//  MoviesRequestEntity+CoreDataProperties.swift
//  
//
//  Created by Regis Araujo Melo on 28/11/2025.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MoviesRequestEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoviesRequestEntity> {
        return NSFetchRequest<MoviesRequestEntity>(entityName: "MoviesRequestEntity")
    }

    @NSManaged public var page: Int32
    @NSManaged public var query: String?
    @NSManaged public var response: MoviesResponseEntity?

}

extension MoviesRequestEntity : Identifiable {

}
