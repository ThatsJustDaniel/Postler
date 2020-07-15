//
//  ResultsViewController.swift
//  ARtrailer
//
//  Created by Daniel Ortiz on 4/12/20.
//  Copyright © 2020 Daniel Ortiz. All rights reserved.
//

import UIKit
import WebKit

class ResultsViewController: UIViewController {
    
 var movieManager = MovieManager()
    
    var photoString = ""
    
    var movieTag: String = "0"
    
    var infoTitle = ""
    var infoOverview = ""
    
    @IBOutlet weak var posterImage: UIImageView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    
    
    @IBOutlet weak var labelView: UIView!
    
    
    @IBOutlet weak var infoButton: UIButton!
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goToInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInfo" {
            let destinationVC = segue.destination as! InfoViewController
            destinationVC.name = infoTitle
            destinationVC.overview = infoOverview

            
        }
    }
    
    var trailers = ["https://apple.com"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view is loaded")
        
        labelView.layer.cornerRadius = 20
        
        sliderCollectionView.layer.cornerRadius = 20
        
        infoButton.layer.cornerRadius = 20
        

        
        
        movieManager.delegate = self
        print(movieTag)
        
        //this step was skipped when coming from the other function
        movieManager.fetchMovies(movieID: movieTag)

    }
    

    func imageRecognized(movieTag: String) {

        movieManager.delegate = self
        movieManager.fetchMovies(movieID: movieTag)

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



//MARK: - Movie Manager Delegate

extension ResultsViewController: MovieManagerDelegate {
    
    func didUpdateMovie(_ MovieManager: MovieManager, movie: MovieModel) {
        
        print("Results activated")
        print("yeeeeeiiii problem solved!!")
        print(movie.firstVideo)
        
        trailers.removeAll()
        trailers = movie.firstVideo
            
        
        print(movie.movieName)
        print(movie.movieOverview)
        print(movie.posterImage)
        print(movie.movieId)
        
        infoTitle = movie.movieName
        infoOverview = movie.movieOverview
        
        movieManager.loadPictures = false
                 
      DispatchQueue.main.async {

        self.sliderCollectionView.reloadData()
        
        print("data loaded again")
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

//MARK: - UICollectionView Delegate

extension ResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return trailers.count
//        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

 
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell

//        if let vc = cell.viewWithTag(111) as? UIImageView {
//            vc.image = imgArr[indexPath.row]
//        }

        let videos = trailers[indexPath.row]
        let myURL = URL(string: videos)
//        let myURL = URL(string:"https://www.youtube.com/watch?v=Ut6W8U9_sNQ")
        let myRequest = URLRequest(url: myURL!)
        cell.configureCell(website: myRequest)
//        videoOne.load(myRequest)


        return cell
    }
    
}

extension ResultsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

//MARK: - Cell

class Cell: UICollectionViewCell {

//@IBOutlet weak var webView: WKWebView!

    @IBOutlet weak var webView: WKWebView!
    
    
//    override init(frame: CGRect) {
//         super.init(frame: frame)
//    }
//    required init?(coder aDecoder: NSCoder) {
//         fatalError("init(coder:) has not been implemented")
//    }
    
    
override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    }

func configureCell(website: URLRequest) {

    self.webView.load(website)


    }

}

