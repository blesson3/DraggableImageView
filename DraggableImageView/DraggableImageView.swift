//
//  DraggableImageView.swift
//  DraggableImageView
//
//  Created by Matt B on 10/18/15.
//  Copyright © 2015 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class DraggableImageView: UIView {
    
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()
    private let dummyView: UIView = UIView()
    private var proportion: CGFloat = 0.0
    
    var imageInset: UIEdgeInsets? {
        get {
            return scrollView.contentInset
        }
        set {
            if let nv = newValue {
                scrollView.contentInset = nv
            }
            else {
                scrollView.contentInset = UIEdgeInsetsZero
            }
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            layoutImageView(image: newValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.userInteractionEnabled = false // disable until image is set
        
        scrollView.frame = self.bounds
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.bouncesZoom = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        self.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()
        
        imageView.frame = CGRectMake(0, 0, 0, 0)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.opaque = false
        
        scrollView.addSubview(imageView)
        
        imageView.backgroundColor = UIColor.purpleColor().colorWithAlphaComponent(0.4) // testing
        scrollView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4) // testing
    }
    
    private func layoutImageView(image i: UIImage?) {
        // reset zoomscale
        scrollView.setZoomScale(1.0, animated: false)
        // set image
        imageView.image = i
        
        // set new size of image view
        if let size = i?.size {
            // set enabled if image
            self.userInteractionEnabled = true
            
            let v1 = CGSizeMake(self.bounds.size.width, (size.height*self.bounds.size.width)/size.width)
            let v2 = CGSizeMake((size.width*self.bounds.size.height)/size.height, self.bounds.size.height)
            
            if v1.height >= self.bounds.size.height {
                // use v1
                imageView.frame = CGRectMake(0, 0, v1.width, v1.height)
            }
            else if v2.width >= self.bounds.size.width {
                // use v2
                imageView.frame = CGRectMake(0, 0, v2.width, v2.height)
            }
            
            scrollView.contentSize = imageView.bounds.size
            scrollView.setContentOffset(CGPointZero, animated: false)
            
            proportion = imageView.frame.size.width/imageView.frame.size.height
        }
        else {
            // since no image, set disabled
            self.userInteractionEnabled = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutImageView(image: image)
    }
}

// MARK: UIScrollViewDelegate

extension DraggableImageView: UIScrollViewDelegate {
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: Render Image

extension DraggableImageView {
    // TODO: base image from view off of dimensions and cropping
    func renderImageFromView() -> UIImage {
        // basically screenshots
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
}
