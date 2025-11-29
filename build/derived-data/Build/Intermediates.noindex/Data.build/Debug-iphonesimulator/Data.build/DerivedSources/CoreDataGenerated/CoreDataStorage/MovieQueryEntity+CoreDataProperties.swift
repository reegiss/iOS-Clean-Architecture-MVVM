//
//  MovieQueryEntity+CoreDataProperties.swift
//  
//
//  Created by Regis Araujo Melo on 28/11/2025.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MovieQueryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieQueryEntity> {
        return NSFetchRequest<MovieQueryEntity>(entityName: "MovieQueryEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var query: String?

}

extension MovieQueryEntity : Identifiable {

}
