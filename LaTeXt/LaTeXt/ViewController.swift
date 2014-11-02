//
//  ViewController.swift
//  LaTeXt
//
//  Created by Sihao Lu on 11/1/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var activityController: UIActivityViewController!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func activityButtonTapped(sender: UIButton!) {
        LaTeXRenderer.sharedRenderer.fetchPreviewImageForLaTeX("\(textField.text)", fetchBlock: { (image, error) -> Void in
            if error != nil {
                println("Fetch preview error")
            }
            self.activityController = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
            self.activityController.completionWithItemsHandler = { activityType, success, returnedItems, error in
                println(activityType)
            }
            self.presentViewController(self.activityController, animated: true, completion: nil)
        })
    }

}

