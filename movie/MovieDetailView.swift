//
//  MovieDetailView.swift
//  movie
//
//  Created by oscar perdana on 07/06/24.
//

import SwiftUI
import Alamofire

struct MovieDetailView: View {
    let movie: Movie
    @State private var movieDetail: MovieDetail?
    @State private var fetchError: String?
    
    var body: some View {
        Group {
            if let movieDetail = movieDetail {
                MovieDetailContent(movieDetail: movieDetail)
            } else if let fetchError = fetchError {
                ErrorView(fetchError: fetchError)
            } else {
                LoadingView()
                    .onAppear(perform: fetchMovieDetail)
            }
        }
        .navigationTitle(movie.Title)
        .padding()
    }
    
    private func fetchMovieDetail() {
        guard let imdbID = movie.imdbID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Invalid IMDB ID")
            return
        }

        let url = "http://www.omdbapi.com/?apikey=6fc87060&i=\(imdbID)"
        
        AF.request(url).validate().responseDecodable(of: MovieDetail.self) { response in
            switch response.result {
            case .success(let movieDetail):
                self.movieDetail = movieDetail
                self.fetchError = nil
            case .failure(let error):
                print("Request error: \(error)")
                self.fetchError = "Request error: \(error.localizedDescription)"
                
                if let data = response.data {
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                }
            }
        }
    }
}

struct MovieDetailContent: View {
    let movieDetail: MovieDetail
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack {
                    AsyncImage(url: URL(string: movieDetail.Poster)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 10)
                            .clipped()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                    .frame(maxHeight: 120)
                }
                HStack(alignment: .top) {
                    AsyncImage(url: URL(string: movieDetail.Poster))
                        .frame(width: 120, height: 160)
                        .cornerRadius(10.0)
                        .padding()
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        StarsView(rating: CGFloat(Double(movieDetail.imdbRating) ?? 0.0), votes: movieDetail.imdbVotes)
                        
                        Text("\(movieDetail.Title) (\(movieDetail.Year))")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(movieDetail.Genre)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 1)
                    }
                    .padding(.top, 10)
                    .padding(.leading, 5)
                }
                
                Text("Plot Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                Text(movieDetail.Plot)
                    .padding(.top, 5)
                    .multilineTextAlignment(.leading)
                
                Text("Other Ratings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(movieDetail.Ratings, id: \.Source) { rating in
                            RatingView(rating: rating)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct RatingView: View {
    let rating: MovieDetail.Rating
    
    var body: some View {
        VStack {
            Text(rating.Source)
                .font(.headline)
                .padding(.bottom, 5)
            
            Text(rating.Value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10.0)
        .overlay(
            RoundedRectangle(cornerRadius: 10.0)
                .stroke(Color.gray, lineWidth: 1.0)
        )
        .shadow(radius: 2)
    }
}

struct StarsView: View {
    var rating: CGFloat
    let votes: String
    let maxRating: Int = 10
    var starCount: Int = 5

    var body: some View {
        let adjustedRating = rating / 2.0

        HStack {
            let stars = HStack(spacing: 0) {
                ForEach(0..<starCount, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                }
            }

            stars.overlay(
                GeometryReader { g in
                    let width = adjustedRating / CGFloat(starCount) * g.size.width
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: width)
                            .foregroundColor(.yellow)
                    }
                }
                .mask(stars)
            )
            .foregroundColor(.gray)
            .frame(height: 20)
            .padding(.trailing, 5)

            VStack(alignment: .leading, spacing: 5) {
                Text(String(format: "%.1f / %d", rating, maxRating))
                    .foregroundColor(.blue)
                    .font(.headline)
                
                Text("\(votes) Ratings")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
        }
        .padding(.bottom, 10)
    }
}

struct ErrorView: View {
    let fetchError: String
    
    var body: some View {
        Text("Error fetching movie details: \(fetchError)")
            .foregroundColor(.red)
            .padding()
    }
}

struct LoadingView: View {
    var body: some View {
        ProgressView()
    }
}
