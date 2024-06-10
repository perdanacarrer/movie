//
//  movieTests.swift
//  movieTests
//
//  Created by oscar perdana on 07/06/24.
//

import XCTest
import Alamofire
import CoreData
@testable import movie

class AuthManagerTests: XCTestCase {
    
    func testValidLogin() {
        let authManager = AuthManager()
        XCTAssertTrue(authManager.validateLogin(username: "VVVBB", password: "@bcd1234"), "Valid login failed")
    }
    
    func testInvalidLogin() {
        let authManager = AuthManager()
        XCTAssertFalse(authManager.validateLogin(username: "invalid", password: "password"), "Invalid login passed")
    }
}

class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
        clearUserData()
        clearMovieData()
    }
    
    override func tearDown() {
        clearUserData()
        clearMovieData()
        coreDataManager = nil
        super.tearDown()
    }
    
    func clearUserData() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let context = coreDataManager.persistentContainer.viewContext
        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                context.delete(user)
            }
            try context.save()
        } catch {
            print("Failed to clear user data: \(error)")
        }
    }
    
    func clearMovieData() {
        let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        let context = coreDataManager.persistentContainer.viewContext
        do {
            let movies = try context.fetch(fetchRequest)
            for movie in movies {
                context.delete(movie)
            }
            try context.save()
        } catch {
            print("Failed to clear movie data: \(error)")
        }
    }
    
    func testSaveUser() {
        XCTAssertTrue(coreDataManager.saveUser(username: "testUser", password: "testPassword"), "Failed to save user")
        XCTAssertFalse(coreDataManager.saveUser(username: "testUser", password: "testPassword"), "User with same username saved again")
    }
    
    func testCheckUsernameExists() {
        let savedSuccessfully = coreDataManager.saveUser(username: "testUser", password: "testPassword")
        XCTAssertTrue(savedSuccessfully, "Failed to save user")
        
        XCTAssertTrue(coreDataManager.checkUsernameExists(username: "testUser"), "Username should exist after saving")
    }
    
    func testCheckUsernameAndPassword() {
        let savedSuccessfully = coreDataManager.saveUser(username: "testUser", password: "testPassword")
        XCTAssertTrue(savedSuccessfully, "Failed to save user")
        
        XCTAssertTrue(coreDataManager.checkUsernameAndPassword(username: "testUser", password: "testPassword"), "Valid username and password check failed")
        XCTAssertFalse(coreDataManager.checkUsernameAndPassword(username: "testUser", password: "invalidPassword"), "Invalid password check passed")
        XCTAssertFalse(coreDataManager.checkUsernameAndPassword(username: "invalidUser", password: "testPassword"), "Invalid username check passed")
    }
    
    func testSaveMovie() {
        let movie = Movie(Title: "Test Movie", Year: "2023", imdbID: "tt1234567", Poster: "testPosterURL")
        
        coreDataManager.saveMovie(movie)
        
        let movies = coreDataManager.fetchMovies()
        XCTAssertEqual(movies.count, 1, "Failed to save movie")
        
        let savedMovie = movies.first!
        XCTAssertEqual(savedMovie.Title, "Test Movie", "Incorrect movie title")
        XCTAssertEqual(savedMovie.Year, "2023", "Incorrect movie year")
        XCTAssertEqual(savedMovie.imdbID, "tt1234567", "Incorrect IMDb ID")
        XCTAssertEqual(savedMovie.Poster, "testPosterURL", "Incorrect poster URL")
    }
    
    func testFetchMovies() {
        let movie1 = Movie(Title: "Movie 1", Year: "2021", imdbID: "tt1111111", Poster: "poster1URL")
        let movie2 = Movie(Title: "Movie 2", Year: "2022", imdbID: "tt2222222", Poster: "poster2URL")
        
        coreDataManager.saveMovie(movie1)
        coreDataManager.saveMovie(movie2)
        
        let movies = coreDataManager.fetchMovies()
        XCTAssertEqual(movies.count, 2, "Failed to fetch movies")
    }
}

class APITests: XCTestCase {
    
    func testFetchMovies() {
        let promise = expectation(description: "Fetch movies expectation")
        
        let url = "http://www.omdbapi.com/?apikey=6fc87060&s=Marvel"
        
        AF.request(url).responseDecodable(of: MovieResponse.self) { response in
            switch response.result {
            case .success(let movieResponse):
                XCTAssertNotNil(movieResponse, "Response should not be nil")
                XCTAssertNotNil(movieResponse.Search, "Search results should not be nil")
                XCTAssertTrue(movieResponse.Search.count > 0, "Search results should not be empty")
                promise.fulfill()
            case .failure(let error):
                XCTFail("Failed to fetch movies: \(error.localizedDescription)")
            }
        }
        
        wait(for: [promise], timeout: 10)
    }
}
