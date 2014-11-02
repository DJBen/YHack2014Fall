//
//  LaTeXRenderer.swift
//  LaTeXt
//
//  Created by Sihao Lu on 11/1/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

class LaTeXRenderer: NSObject {
    class var sharedRenderer : LaTeXRenderer {
    struct Static {
        static let instance : LaTeXRenderer = LaTeXRenderer()
    }
    return Static.instance
}
    
    func fetchPreviewImageForLaTeX(LaTeX: String, fetchBlock: (image: UIImage?, error: NSError?) -> Void) {
        let parameters: [String: String] = ["cht": "tx", "chl": LaTeX]
        let latexRequest = request(.POST, "https://chart.googleapis.com/chart", parameters: parameters)
        latexRequest.response { (urlRequest, urlResponse, responseData, error) -> Void in
            println(urlRequest)
            println(urlResponse)
            println(error)
            if error != nil {
                fetchBlock(image: nil, error: error)
            }
            if let image = UIImage(data: (responseData as NSData)) {
                fetchBlock(image: image, error: nil)
            } else {
                println("Image not valid")
            }
        }
    }
    
}
