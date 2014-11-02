//
//  KeyboardViewController.swift
//  LaTeXtKeyboard
//
//  Created by Sihao Lu on 11/1/14.
//  Copyright (c) 2014 DJ.Ben. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    private var extraView = UIView()
    private var extraLabel = UILabel()
    private var previewButton: UIButton!
    private var previewView = UIView()
    private var previewImageView = UIImageView()
    
    private var extraViewHeightConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private var isPreviewShowing: Bool = false
    private var isShowingSymbols: Bool = true {
        didSet {
            setHideRowSet(symbolRowSet, hidden: !self.isShowingSymbols)
            setHideRowSet(alphabetRowSet, hidden: self.isShowingSymbols)
        }
    }
    private var isCapOn: Bool = false
    
    private var symbolRowSet: [UIView]!
    private var alphabetRowSet: [UIView]!
    
    private var keyText: [String: String]!
    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Layout 1..9, 0
        let buttonTitles1 = (1...10).map { number -> String in
            return "\(number % 10)"
        }
        let buttonTitles2 = ["+", "-", "<", ">", "!", "?", "(", ")", "[", "]"]
        let buttonTitles3 = ["\\", "{", "}", "_", "^", "+", "-", "\u{00b7}" /* cdot */, "/", "="]
        let buttonTitles4 = ["\u{222b}" /* integral */, "\u{2211}" /* sum */, "\u{21D2}" /* implies */, "\u{00bd}" /* one half */, "\u{2208}" /* in */, "\u{2282}" /* subset */, "\u{2264}", "\u{2265}" /* leq and geq */, "\u{03c0}"/* PI */, "BP"]
        let buttonTitles5 = ["SNIP", "Aa", "CHG", "SPACE", "RETURN"]
        
        let secondButtonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
        let secondButtonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "\""]
        let secondButtonTitles3 = ["SHIFT", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "BP"]
        let secondButtonTitles4 = ["SNIP", "Aa", "CHG", "SPACE", "RETURN"]
        
        keyText = ["\u{222B}": "\\int",
            "\u{2211}": "\\sum",
            "\u{00bd}": "\\frac{",
            "\u{00b7}": "\\cdot",
            "\u{21D2}": "\\Rightarrow",
            "\u{2208}": "\\in",
            "\u{2282}": "\\subset",
            "\u{2264}": "\\leq", "\u{2265}": "\\geq",
            "\u{03c0}": "\\pi",
            "^": "^{", "_": "_{"]
        
        configureExtraView()
        
        var row1 = createRowOfButtons(buttonTitles1)
        var row2 = createRowOfButtons(buttonTitles2)
        var row3 = createRowOfButtons(buttonTitles3)
        var row4 = createRowOfButtons(buttonTitles4)
        var row5 = createRowOfButtons(buttonTitles5)
        
        self.view.addSubview(row1)
        self.view.addSubview(row2)
        self.view.addSubview(row3)
        self.view.addSubview(row4)
        self.view.addSubview(row5)
        
        
        var aRow1 = createRowOfButtons(secondButtonTitles1)
        var aRow2 = createRowOfButtons(secondButtonTitles2)
        var aRow3 = createRowOfButtons(secondButtonTitles3)
        var aRow4 = createRowOfButtons(secondButtonTitles4)
        
        self.view.addSubview(aRow1)
        self.view.addSubview(aRow2)
        self.view.addSubview(aRow3)
        self.view.addSubview(aRow4)
        
        symbolRowSet = [row1, row2, row3, row4, row5]
        alphabetRowSet = [aRow1, aRow2, aRow3, aRow4]
        
        isShowingSymbols = true
        
        view.bringSubviewToFront(previewView)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addConstraintsToInputView(self.view, rowViews: symbolRowSet)
        addConstraintsToInputView(self.view, rowViews: alphabetRowSet)
    }
    
    func createRowOfButtons(buttonTitles: [NSString]) -> UIView {
        
        var buttons = [UIButton]()
        var keyboardRowView = UIView(frame: CGRectMake(0, 0, 320, 40))
        
        for buttonTitle in buttonTitles{
            
            let button = createButtonWithTitle(buttonTitle)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
        
        addIndividualButtonConstraints(buttons, mainView: keyboardRowView)
        
        return keyboardRowView
    }
    
    private func configureExtraView() {
        extraView.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(extraView)
        
        previewView.backgroundColor = UIColor.whiteColor()
        previewView.userInteractionEnabled = false
        previewView.alpha = 0
        view.addSubview(previewView)
        
        layout(extraView, previewView) { v, p in
            v.left == v.superview!.left
            v.right == v.superview!.right
            v.top == v.superview!.top
            self.extraViewHeightConstraint = (v.height == 44)
            p.top == v.bottom
            p.bottom == p.superview!.bottom
            p.left == p.superview!.left
            p.right == p.superview!.right
        }
        
        extraLabel.textColor = UIColor.whiteColor()
        extraLabel.text = ""
        extraLabel.lineBreakMode = .ByTruncatingHead
        extraView.addSubview(extraLabel)
        
        previewButton = UIButton.buttonWithType(.System) as UIButton
        previewButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        previewButton.setTitle("Preview", forState: .Normal)
        previewButton.addTarget(self, action: "showPreview:", forControlEvents: .TouchUpInside)
        extraView.addSubview(previewButton)

        layout(extraLabel, previewButton) { label, button in
            label.left == label.superview!.left + 10
            label.centerY == label.superview!.centerY
            label.top == label.superview!.top
            label.right == button.left - 4
            button.centerY == label.centerY
            button.right == button.superview!.right - 4
            button.height == label.height
            button.width == 64
        }
        
        previewView.addSubview(previewImageView)
        layout(previewImageView) { imageView in
            imageView.centerX == imageView.superview!.centerX
            imageView.centerY == imageView.superview!.centerY
        }
    }
    
    private func isExtraViewOpen() -> Bool {
        return extraViewHeightConstraint.constant > 0
    }
    
    private func setExtraViewOpen(open: Bool) {
        extraViewHeightConstraint.constant = open ? 44 : 0
        previewButton.hidden = !open
        view.layoutIfNeeded()
    }
    
    private func setHideRowSet(rowSet: [UIView]!, hidden: Bool) {
        if rowSet == nil {
            return
        }
        for row in rowSet {
            row.hidden = hidden
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
    }
    
    func createButtonWithTitle(title: String) -> UIButton {
        let button = UIButton.buttonWithType(.System) as UIButton
        button.setTitle(title, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setBackgroundImage(UIImage(named: "keycap"), forState: .Normal)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
        return button
    }
    
    func showPreview(sender: UIButton!) {
        if !isPreviewShowing && extraLabel.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            // Show preview now
            LaTeXRenderer.sharedRenderer.fetchPreviewImageForLaTeX(extraLabel.text!, fetchBlock: { (_, image: UIImage?, error: NSError?) -> Void in
                if error == nil {
                    self.previewImageView.image = image
                    self.previewView.layoutIfNeeded()
                }
            })
        }
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
            self.previewView.alpha = self.isPreviewShowing ? 0 : 1
        }) { (completed) -> Void in
            self.isPreviewShowing = !self.isPreviewShowing
        }
    }
    
    func didLongTap(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            var proxy = textDocumentProxy as UITextDocumentProxy
            proxy.insertText("\n")
        }
    }
    
    func didTapButton(sender: AnyObject?) {
        
        let button = sender as UIButton
        var proxy = textDocumentProxy as UITextDocumentProxy
        
        if let title = button.titleForState(.Normal) {
            switch title {
            case "BP" :
                if isExtraViewOpen() {
                    if extraLabel.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                        extraLabel.text!.removeAtIndex(advance(extraLabel.text!.endIndex, -1))
                    }
                } else {
                    proxy.deleteBackward()
                }
            case "RETURN" :
                if isExtraViewOpen() {
                    proxy.insertText("$\(extraLabel.text!)$")
                    extraLabel.text = String()
                    setExtraViewOpen(false)
                } else {
                    proxy.insertText("\n")
                }
            case "SPACE" :
                if isExtraViewOpen() {
                    extraLabel.text! += " "
                } else {
                    proxy.insertText(" ")
                }
            case "CHG" :
                self.advanceToNextInputMode()
            case "CAP":
                isCapOn = !isCapOn
            case "SNIP":
                setExtraViewOpen(!isExtraViewOpen())
            case "Aa":
                isShowingSymbols = !isShowingSymbols
            default:
                let output = (keyText[title] ?? title).lowercaseString
                if isExtraViewOpen() {
                    extraLabel.text = extraLabel.text! + output
                } else {
                    if !isShowingSymbols && !isCapOn {
                        proxy.insertText(output.lowercaseString)
                    } else {
                        proxy.insertText(output.lowercaseString)
//                        proxy.insertText(output)
                    }
                }
            }
        }
    }
    
    func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        
        for (index, button) in enumerate(buttons) {
            
            var topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 1)
            
            var bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -1)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -1)
            } else {
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -1)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 1)
            }else{
                
                let prevtButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 1)
                
                let firstButton = buttons[0]
                var widthConstraint: NSLayoutConstraint
                if button.titleForState(.Normal) == "SPACE" {
                    widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
                } else {
                    widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
                }
                
                widthConstraint.priority = 800
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        var prevRow = UIView()
        for (index, rowView) in enumerate(rowViews.reverse()) {
            layout(rowView, prevRow, self.extraView) { r, p, e in
                r.left == r.superview!.left + 1
                r.right == r.superview!.right - 1
                if index == 0 {
                    // Last row
                    r.bottom == r.superview!.bottom - 1
                    r.height == 50
                } else {
                    r.bottom == p.top - 4
                    r.height == p.height
                    if (index + 1 == rowViews.count) {
                        // First row
                        r.top == e.bottom + 4
                    }
                }
            }
            prevRow = rowView
        }
    }
}
