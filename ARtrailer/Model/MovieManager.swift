//
//  MovieManager.swift
//  ARtrailer
//
//  Created by Daniel Ortiz on 3/17/20.
//  Copyright © 2020 Daniel Ortiz. All rights reserved.
//

import Foundation

protocol MovieManagerDelegate {
    
    func didUpdateMovie(_ MovieManager: MovieManager, movie: MovieModel)
    func didFailWithError(error: Error)
    
}

struct MovieManager {
    
    
    //api key: f121ff730c95d2fe4b7c334b95adae30
    
    //    // Search and Query
    //
    //    // use this link to search for a movie and get results. once the user has seen some results, he will select one. When he selects one result, get the id of the movie of that result and then search for its details.
    //     https://api.themoviedb.org/3/search/movie?api_key={api_key}&query=Jack+Reacher
    //
    //     // details
    //     // on this link, you will input the movie id from the results and get the details of the movie: https://api.themoviedb.org/3/movie/343611?api_key={api_key}&append_to_response=videos
    
    // This is the Now Playing movies parameter:
    //https://api.themoviedb.org/3/movie/now_playing?api_key=f121ff730c95d2fe4b7c334b95adae30&language=es&page=1&region=MX
    
    // all of the lnaguages
    //https://api.themoviedb.org/3/configuration/languages?api_key=f121ff730c95d2fe4b7c334b95adae30
    
    //all of the countries
    //https://api.themoviedb.org/3/configuration/countries?api_key=f121ff730c95d2fe4b7c334b95adae30
    
    
    
    //make sure the url is https for a secure connection
    let allMovieInfoURL = "https://api.themoviedb.org/3/movie/"
    
    let nowPlayingMoviesURL = "https://api.themoviedb.org/3/movie/now_playing?api_key=f121ff730c95d2fe4b7c334b95adae30"
    
    
    
    
    
    
    let moviesURL = "https://api.themoviedb.org/3/search/movie?api_key=f121ff730c95d2fe4b7c334b95adae30"
    
    var delegate: MovieManagerDelegate?
    var loadVideos: Bool = false
    var loadPictures : Bool = false
    var regionCode = Locale.current.regionCode
    var language = Locale.current.identifier
    
    
    mutating func fetchMovies(movieID: String) {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)?api_key=f121ff730c95d2fe4b7c334b95adae30&append_to_response=videos&region=\(regionCode!)&language=\(language)"
        loadVideos = true
        performRequest(with: urlString)
        print(urlString)
        
        
    }
    
    
    func queryMovies(movieName: String) {
        let urlString = "\(moviesURL)&query=\(movieName)&region=\(regionCode!)&language=\(language)"
        performRequest(with: urlString)
        print(urlString)
        // the parameter above with is just "with" here because it is an external paramenter.
        //for example: Func hello(external internal: String) {}
    }
    
    mutating func moviesThisWeek() {
        let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=f121ff730c95d2fe4b7c334b95adae30&region=\(regionCode!)&language=\(language)"
        loadPictures = true
        performRequest(with: urlString)
        print(urlString)
        
    }
    
    mutating func updatePosters(movieCount: Int){
        let urlString = "https://api.themoviedb.org/3/movie/now_playing?api_key=f121ff730c95d2fe4b7c334b95adae30&region=\(regionCode!)&language=\(language)"
        loadPictures = false
        performRequest(with: urlString, arrayNumber: movieCount)
        
    }
    
    
    //MARK: - Networking
    
    
    func performRequest(with urlString: String, arrayNumber: Int) {
        
        
        for index in 0 ..< arrayNumber {
            
            
            //1. Create a URL
            
            if let url = URL(string: urlString) {
                
                
                //2. Create a URLSession
                
                let session = URLSession(configuration: .default)
                
                //3. Give the session a task
                
                let task = session.dataTask(with: url) { (data, response, error) in
                    
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return //return here means to exit out of the function and dont continue
                    }
                    
                    if let safeData = data {
                        
                        //We are going to parse this data to use it as part of an object
                        
                        if let movie = self.parseJSON(safeData, number: index){
                            self.delegate?.didUpdateMovie(self,movie: movie)
                            
                        }
                    }
                }
                
                //4. Start the task
                
                task.resume()
                
            }
            
        }
        
    }
    
    
    
    
    
    
    func performRequest(with urlString: String) {
        
        //1. Create a URL
        
        if let url = URL(string: urlString) {
            
            
            //2. Create a URLSession
            
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return //return here means to exit out of the function and dont continue
                }
                
                if let safeData = data {
                    
                    //We are going to parse this data to use it as part of an object
                    
                    if let movie = self.parseJSON(safeData){
                        self.delegate?.didUpdateMovie(self,movie: movie)
                        
                    }
                }
            }
            
            //4. Start the task
            
            task.resume()
            
        }
        
    }
    
    
    
    //MARK: - Parsing
    
    
    
    
    func parseJSON(_ movieData: Data, number: Int) -> MovieModel? {
        
        //        print(number)
        
        let decoder = JSONDecoder()
        
        do {
            
            let decodedData = try decoder.decode(MovieData.self, from: movieData)
            
            
            let results = decodedData.results.count + 1
            
            let id = decodedData.results[number].id
            let name = decodedData.results[number].original_title
            let overview = decodedData.results[number].overview
//            let poster = decodedData.results[number].poster_path!
            
            let poster = decodedData.results[number].poster_path ?? "0"
            //            let backdrop = "0"
            let video1 = ["0"]
            
            let movie = MovieModel(movieId: id, movieName: name, movieOverview: overview, posterImage: poster, totalResults: results, firstVideo: video1)
            
            
            return movie
            
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
        
    }
    
    
    
    func parseJSON(_ movieData: Data) -> MovieModel? {
        
        
        if loadVideos == true {
            
            
            let decoder = JSONDecoder()
            
            do {
                
                print("movieManager is updating")
                
                let decodedData = try decoder.decode(VideoSearch.self, from: movieData)
                
                let results = 0
                
                let id = decodedData.id
                let name = decodedData.original_title
                let overview = decodedData.overview
                let poster = decodedData.poster_path!
                //                let backdrop = decodedData.backdrop_path!
                
                //                let video1 = decodedData.videos.results[0]?.key
                //                let video1 = [decodedData.videos.results.first??.key ?? "WORJw3VsFEc"]
                
                func videosArray() -> [String] {
                    
                    var videoArray = [String]()
                    let video1 = decodedData.videos.results.first??.key ?? "m927vJiLn7E"
                    let videoCount = decodedData.videos.results.count
                    videoArray.append("https://www.youtube.com/embed/\(video1)")
                    
                    func addVideos(video: String) {
                        
                        videoArray.append("https://www.youtube.com/embed/\(video)")
                    }
                    
                    if videoCount > 1 {
                        let video2 = decodedData.videos.results[1]!.key
                        addVideos(video: video2)
                        
                    }
                    
                    if videoCount > 2 {
                        let video3 = decodedData.videos.results[2]!.key
                        addVideos(video: video3)
                    }
                    
                    
                    return videoArray
                }
                
                let video1 = videosArray()
                
                
                
                let movie = MovieModel(movieId: id, movieName: name, movieOverview: overview, posterImage: poster, totalResults: results, firstVideo: video1)
                
                
                return movie
                
            } catch {
                
                delegate?.didFailWithError(error: error)
                return nil
                
            } 
            
        } else {
            
            let decoder = JSONDecoder()
            
            do {
                
                let decodedData = try decoder.decode(MovieData.self, from: movieData)
                
                let results = decodedData.results.count
                let id = decodedData.results[0].id
                let name = decodedData.results[0].original_title
                let overview = decodedData.results[0].overview
                let poster = decodedData.results[0].poster_path!
                //                let backdrop = decodedData.results[0].backdrop_path!
                let video1 = ["0"]
                
                let movie = MovieModel(movieId: id, movieName: name, movieOverview: overview, posterImage: poster, totalResults: results, firstVideo: video1)
                
                
                return movie
                
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
                
            }
        }
        
        
    }
    
    
    
    
}




