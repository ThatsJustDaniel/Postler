//
//  ViewController.swift
//  ARtrailer
//
//  Created by Daniel Ortiz on 3/14/20.
//  Copyright © 2020 Daniel Ortiz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {
    
    // I created the master file of version control here
    
    // I will download the posters for the movies that are playing each week and put the images on the AR imagage resource group. each image will be linked to its own id and from there the trailer and info of the movie will be played out.
    
    
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    
    var newReferenceImages:Set<ARReferenceImage> = Set<ARReferenceImage>()
    
//    var resultsVC = ResultsViewController()
    
//    var movieSet = MovieSet()
    
    var movieManager = MovieManager()
    
    var totalResults = 100
    
    var finalResults = 100
    
    var startCountdown = false
    
    var movieID = "0"


    
    override func viewDidLoad() {
        super.viewDidLoad()
                
            print("viewDidLoad")
        
        print(newReferenceImages.count)
        
        startCountdown = true
        
//         Set the view's delegate
        sceneView.delegate = self
        
        movieManager.delegate = self
        
        movieManager.moviesThisWeek()
        
        resetTracking()
        
        
    
        // set up the leftSwipeGesture
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
        
        
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTracking()
        print("view Will appear")
        
        
        //        // Run the view's session
//                sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    //MARK: - Photo Management
    
    func getPhotoURL(photoLink: String) -> URL{
        let url = URL(string: photoLink)!

        return url
    }


    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()

    }

    
    public func resetTracking() {
             
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = newReferenceImages
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }



    func downloadImage(from url: URL, movieID: Int) {

//        var newReferenceImages = movieSet.newReferenceImages
//
//        let totalResults = movieSet.totalResults

        //        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }

            //            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")


            func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
                let context = CIContext(options: nil)
                if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
                    return cgImage
                }
                return nil
            }


            if let result = UIImage(data: data) {


                //2. Convert It to CIImage
                let imageToCIImage = CIImage(image: result)

                //3. Then Convert The CIImage To a CGI Image

                let cgImage = convertCIImageToCGImage(inputImage: imageToCIImage!)


                //4. Create An ARReference Image (Remembering Physical Width Is In Metres)
                let arImage = ARReferenceImage(cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.5)

                // SET YOUR IMAGE NAME
                arImage.name = "\(movieID)";

                // APPEND TO REFERENCE IMAGES
                self.newReferenceImages.insert(arImage)
//                self.newReferenceImages.insert(arImage);

                print("there are \(self.newReferenceImages.count) images found")

                // RESET TRACKING
//                self.resetTracking();
                
                if self.finalResults == self.newReferenceImages.count {
                    
                    print("final Results is \(self.finalResults) and Reference images is \(self.newReferenceImages.count)")
                self.resetTracking()
                    
                            } else {
                    print("final Results is\(self.finalResults) and Reference images is\(self.newReferenceImages.count), this is not equal")
                
//                    self.resetTracking()
                                
                        }


            }

        }
    }



    
    //MARK: - ARSCNViewDelegate
    //     set up the delegate and anchor the plane for detection.
    

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        let node = SCNNode()

        if let imageAnchor = anchor as? ARImageAnchor {

            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)

            //            plane.firstMaterial?.diffuse.contents = videoScene

            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)

            let planeNode = SCNNode(geometry: plane)

            planeNode.eulerAngles.x = -.pi / 2


            // add the if statement saying that the plane will appear once the image has been recognized, and the method of all the movie info will be here

            node.addChildNode(planeNode)

            if let id = imageAnchor.name {
                
                movieID = id
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToResults", sender: self)
                }
                 
                
//                DispatchQueue.main.async {
//
//                    let resultsVC = ResultsViewController()
//
//                       resultsVC.movieTag = id
//                        self.present(resultsVC, animated: true, completion: nil)
//
//
//                }
                
         
                // I NEED TO LOAD THE WHOLE RESULTS VIEW CONTROLLER WHILE PASSING DATA!!!

            }

        }

        return node

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResults" {
            let destinationVC = segue.destination as! ResultsViewController
            destinationVC.movieTag = movieID
        }
    }
    
    
    
}

extension UIViewController {
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        
        
        switch swipe.direction.rawValue {
        case 1:
            performSegue(withIdentifier: "swipeRight", sender: self)
        case 2:
            performSegue(withIdentifier: "swipeLeft", sender: self)
        default:
            break
        }
        
    }
    
}

//MARK: - Movie Manager Delegate

extension ViewController: MovieManagerDelegate {

    func didUpdateMovie(_ MovieManager: MovieManager, movie: MovieModel) {


        
        
        
        let photoLink = movie.posterImage
        let photoString = "https://image.tmdb.org/t/p/w500/\(photoLink)"
        let url = getPhotoURL(photoLink: photoString)
        
        
        if startCountdown {
        self.finalResults = movie.totalResults
        startCountdown = false }

        if movie.posterImage != "0" {
            downloadImage(from: url, movieID: movie.movieId)
            print("downloading image")
        } else {
            finalResults = finalResults - 1
            print("movie \(movie.movieName) does not have an image")
        }
        
        
//        downloadImage(from: url, movieID: movie.movieId)
//        print("downloading image")

        self.totalResults = movie.totalResults - 1

        if MovieManager.loadPictures == true {

            movieManager.updatePosters(movieCount: movie.totalResults)

        }




    }


    func didFailWithError(error: Error) {
        print(error)
    }



}





