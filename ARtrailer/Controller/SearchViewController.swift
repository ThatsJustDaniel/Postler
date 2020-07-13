//
//  SearchViewController.swift
//  ARtrailer
//
//  Created by Daniel Ortiz on 3/14/20.
//  Copyright © 2020 Daniel Ortiz. All rights reserved.
//

import UIKit


class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var posterImage: UIImageView!
    
    
    var movieManager = MovieManager()
    
    var photoString = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        
        movieManager.delegate = self
        searchTextField.delegate = self
        
        // set up the rightSwipeGesture
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
    }
    
    //MARK: - Photo Management
    
    func getPhotoURL(photoLink: String) -> URL{
        let url = URL(string: photoLink)!
        
        return url
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.posterImage.image = UIImage(data: data)
            }
        }
    }
    
    
}

//MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: Any) {
        
        searchTextField.endEditing(true)
        print(searchTextField.text!)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        //Use searchTextField.text to get the weatrher for that movie.
        if let movie = searchTextField.text {
            movieManager.queryMovies(movieName: movie)
        }
        
        searchTextField.text = ""
        
    }
}

//MARK: - MovieManagerDelegate

extension SearchViewController: MovieManagerDelegate {
    
    func didUpdateMovie(_ MovieManager: MovieManager, movie: MovieModel) {
        //Long-running tasks such as networking are often executed in the background, and provide a completion handler to signal completion. Attempting to read or update the UI from a completion handler may cause problems. Therefore, dispatch the call to update the label text on the MAIN THREAD.
             print("Search activated")
        DispatchQueue.main.async {
            
            self.titleLabel.text = movie.movieName
            self.overviewLabel.text = movie.movieOverview
            
            print(movie.movieName)
            print(movie.movieOverview)
            
            
        }
        
        let photoLink = movie.posterImage
        let photoString = "https://image.tmdb.org/t/p/w500/\(photoLink)"
        print(photoString)
        let url = getPhotoURL(photoLink: photoString)
        downloadImage(from: url)
        print(photoString)
             
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    
}




