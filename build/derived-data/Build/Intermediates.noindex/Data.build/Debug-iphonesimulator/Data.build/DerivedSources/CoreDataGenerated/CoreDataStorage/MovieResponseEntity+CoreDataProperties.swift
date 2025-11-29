//
//  MovieResponseEntity+CoreDataProperties.swift
//  
//
//  Created by Regis Araujo Melo on 28/11/2025.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MovieResponseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieResponseEntity> {
        return NSFetchRequest<MovieResponseEntity>(entityName: "MovieResponseEntity")
    }

    @NSManaged public var genre: String?
    @NSManaged public var id: Int64
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var title: String?
    @NSManaged public var moviesResponse: MoviesResponseEntity?

}

extension MovieResponseEntity : Identifiable {

}
