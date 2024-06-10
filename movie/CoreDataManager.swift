//
//  CoreDataManager.swift
//  movie
//
//  Created by oscar perdana on 07/06/24.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "movie")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    func saveUser(username: String, password: String) -> Bool {
        guard !checkUsernameExists(username: username) else {
            return false
        }
        
        let context = persistentContainer.viewContext
        let newUser = User(context: context)
        newUser.username = username
        newUser.password = password
        
        do {
            try context.save()
            print("User saved to CoreData.")
            return true
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func checkUsernameExists(username: String) -> Bool {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        
        let context = persistentContainer.viewContext
        do {
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            let nsError = error as NSError
            fatalError("Failed to fetch user: \(nsError), \(nsError.userInfo)")
        }
    }
    
    func checkUsernameAndPassword(username: String, password: String) -> Bool {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        
        let context = persistentContainer.viewContext
        do {
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            let nsError = error as NSError
            fatalError("Failed to fetch user: \(nsError), \(nsError.userInfo)")
        }
    }
    
    func saveMovie(_ movie: Movie) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imdbID == %@", movie.imdbID)
        
        do {
            let cdMovies = try context.fetch(fetchRequest)
            if let cdMovie = cdMovies.first {
                // Update the existing movie
                cdMovie.title = movie.Title
                cdMovie.year = movie.Year
                cdMovie.poster = movie.Poster
            } else {
                // Save a new movie
                let cdMovie = CDMovie(context: context)
                cdMovie.title = movie.Title
                cdMovie.year = movie.Year
                cdMovie.imdbID = movie.imdbID
                cdMovie.poster = movie.Poster
            }
            
            try context.save()
        } catch {
            print("Failed to save movie: \(error)")
        }
    }
    
    func fetchMovies() -> [Movie] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        
        do {
            let cdMovies = try context.fetch(fetchRequest)
            return cdMovies.map { Movie(Title: $0.title ?? "", Year: $0.year ?? "", imdbID: $0.imdbID ?? "", Poster: $0.poster ?? "") }
        } catch {
            print("Failed to fetch movies: \(error)")
            return []
        }
    }

    func deleteMovie(by imdbID: String) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imdbID == %@", imdbID)
        
        do {
            let cdMovies = try context.fetch(fetchRequest)
            if let cdMovie = cdMovies.first {
                context.delete(cdMovie)
                try context.save()
                print("Movie deleted from CoreData.")
            }
        } catch {
            print("Failed to delete movie: \(error)")
        }
    }
}
