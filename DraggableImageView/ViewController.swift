//
//  ViewController.swift
//  DraggableImageView
//
//  Created by Matt B on 1/23/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: DraggableImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.image = UIImage(named: "test1")
        imageView.imageInset = UIEdgeInsetsMake(30, 20, 30, 20)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

