//
//  MoviesResponseEntity+CoreDataProperties.swift
//  
//
//  Created by Regis Araujo Melo on 28/11/2025.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension MoviesResponseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoviesResponseEntity> {
        return NSFetchRequest<MoviesResponseEntity>(entityName: "MoviesResponseEntity")
    }

    @NSManaged public var page: Int32
    @NSManaged public var totalPages: Int32
    @NSManaged public var movies: NSSet?
    @NSManaged public var request: MoviesRequestEntity?

}

// MARK: Generated accessors for movies
extension MoviesResponseEntity {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: MovieResponseEntity)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: MovieResponseEntity)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}

extension MoviesResponseEntity : Identifiable {

}
