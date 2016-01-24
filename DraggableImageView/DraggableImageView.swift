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
    func renderImageFromView() -> UIImage {
        // basically screenshots
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 0.0)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let _ = imageInset {
            // then crop
            let cropRect = cropRectWithRespectToInsets(img)
            if let imageRef = CGImageCreateWithImageInRect(img.CGImage, cropRect) {
                let i = UIImage(CGImage: imageRef)
                return i
            }
            return img
        }
        else {
            return img
        }
    }
    
    func cropRectWithRespectToInsets(i: UIImage) -> CGRect {
        let left = (imageInset!.left/i.size.width)*CGFloat(CGImageGetWidth(i.CGImage))
        let right = (imageInset!.right/i.size.width)*CGFloat(CGImageGetWidth(i.CGImage))
        let top = (imageInset!.top)/i.size.height*CGFloat(CGImageGetHeight(i.CGImage))
        let bottom = (imageInset!.bottom)/i.size.height*CGFloat(CGImageGetHeight(i.CGImage))
        let translatedInsets = UIEdgeInsetsMake(top, left, bottom, right)
        
        let x: CGFloat = translatedInsets.left
        let y: CGFloat = translatedInsets.top
        let width: CGFloat = CGFloat(CGImageGetWidth(i.CGImage))-x-translatedInsets.right
        let height: CGFloat = CGFloat(CGImageGetHeight(i.CGImage))-y-translatedInsets.bottom
        return CGRectMake(x, y, width, height)
    }
}
