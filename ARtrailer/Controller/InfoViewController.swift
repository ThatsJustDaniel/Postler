//
//  InfoViewController.swift
//  ARtrailer
//
//  Created by Daniel Ortiz on 7/15/20.
//  Copyright © 2020 Daniel Ortiz. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    var name: String?
    var overview: String?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = name
        overviewLabel.text = overview
        
        
    }
    



}
