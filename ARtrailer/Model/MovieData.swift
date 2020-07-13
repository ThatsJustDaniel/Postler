//
//  MovieData.swift
//  ARtrailer
//
//  Created by Daniel Ortiz on 3/19/20.
//  Copyright © 2020 Daniel Ortiz. All rights reserved.
//

import Foundation

struct MovieData: Decodable {
    
    let results: [Results]
    let page: Int
    
}


struct Results: Decodable {
    let original_title: String
    let overview: String
    let id: Int
    let poster_path: String?
//    let backdrop_path: String?

}

struct VideoSearch: Decodable {
    let original_title: String
    let overview: String
    let id: Int
    let poster_path: String?
//    let backdrop_path: String?
    let videos: VideoResults
}

struct VideoResults: Decodable {
    let results: [Videos?]
}

struct Videos: Decodable {
    let key: String
     
}



