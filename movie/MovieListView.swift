//
//  MovieListView.swift
//  movie
//
//  Created by oscar perdana on 07/06/24.
//

import SwiftUI
import Alamofire

struct MovieListView: View {
    @State private var movies: [Movie] = []
    @State private var searchQuery = ""
    @State private var showLogoutAlert = false
    @State private var showingDeleteAlert = false
    @State private var movieToDelete: Movie?
    @EnvironmentObject private var appRootManager: AppRootManager

    var body: some View {
        NavigationView {
            VStack {
                HeaderView(showLogoutAlert: $showLogoutAlert)
                SearchField(searchQuery: $searchQuery, fetchMovies: fetchMovies)
                MovieList(movies: movies, searchQuery: searchQuery, deleteAction: deleteMovie, showingDeleteAlert: $showingDeleteAlert, movieToDelete: $movieToDelete)
                    .onAppear(perform: fetchMovies)
            }
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Do you want to logout?"),
                    primaryButton: .destructive(Text("Yes")) {
                        logout()
                    },
                    secondaryButton: .cancel(Text("No"))
                )
            }
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Movie"),
                message: Text("Are you sure you want to delete this movie?"),
                primaryButton: .destructive(Text("Yes")) {
                    if let movie = movieToDelete {
                        deleteMovie(movie: movie)
                    }
                },
                secondaryButton: .cancel(Text("No"))
            )
        }
    }
    
    func fetchMovies() {
        if searchQuery.isEmpty {
            self.movies = CoreDataManager.shared.fetchMovies()
        } else {
            let url = "http://www.omdbapi.com/?apikey=6fc87060&s=\(searchQuery)&type=movie"
            AF.request(url).responseDecodable(of: MovieResponse.self) { response in
                if let movies = response.value?.Search {
                    self.movies = movies
                    saveMoviesToCoreData(movies)
                } else {
                    self.movies = []
                }
            }
        }
    }
    
    func saveMoviesToCoreData(_ movies: [Movie]) {
        for movie in movies {
            CoreDataManager.shared.saveMovie(movie)
        }
    }
    
    func deleteMovie(movie: Movie) {
        CoreDataManager.shared.deleteMovie(by: movie.imdbID)
        fetchMovies()
    }
    
    func logout() {
        saveCredentials(username: "", password: "")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first {
//                appRootManager.switchToLogin()
                window.rootViewController = UIHostingController(rootView: StartView())
                window.makeKeyAndVisible()
        }
    }
}

struct HeaderView: View {
    @Binding var showLogoutAlert: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Text("Movies")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
                showLogoutAlert = true
                print("Logout button pressed")
            }) {
                Image(systemName: "escape")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
            }
        }
        .padding()
        .background(Color.white)
    }
}

struct SearchField: View {
    @Binding var searchQuery: String
    var fetchMovies: () -> Void
    
    var body: some View {
        TextField("Search Movies", text: $searchQuery, onCommit: fetchMovies)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(5.0)
            .padding(.horizontal)
    }
}

struct MovieList: View {
    let movies: [Movie]
    let searchQuery: String
    let deleteAction: (Movie) -> Void
    @Binding var showingDeleteAlert: Bool
    @Binding var movieToDelete: Movie?
    
    var body: some View {
        if movies.isEmpty {
            Text("No Data")
                .foregroundColor(.gray)
                .font(.headline)
                .padding()
        } else {
            List {
                ForEach(movies) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        MovieRow(movie: movie)
                    }
                }
                .onDelete(perform: searchQuery.isEmpty ? handleDelete : nil)
            }
        }
    }
    
    private func handleDelete(at offsets: IndexSet) {
        showingDeleteAlert = true
        if let index = offsets.first {
            movieToDelete = movies[index]
        }
    }
}

struct MovieRow: View {
    let movie: Movie
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: movie.Poster))
                .frame(width: 50, height: 75)
                .cornerRadius(5.0)
            
            VStack(alignment: .leading) {
                Text(movie.Title)
                    .font(.headline)
                Text(movie.Year)
                    .font(.subheadline)
            }
        }
    }
}
