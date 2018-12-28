//
//  TextViewViewController.swift
//  LimitInputKit_Example
//
//  Created by linhey on 2018/12/27.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import LimitInputKit
import BLFoundation

class TextViewViewController: UIViewController {
  
  @IBOutlet weak var textView: LimitTextView! {
    didSet{
      textView.placeholder = "在 Swift 4.2，SE-0194 的 Derived Collection of Enum Cases 讓 enum 變得更方便了，現在我們可以把 enum 變成 array 來使用呢。"
    }
  }
  
  @IBOutlet weak var segmentedCotrol1: UISegmentedControl!
  @IBOutlet weak var segmentedCortol2: UISegmentedControl!
  
  @IBOutlet weak var matchTextFiled: UITextField!
  @IBOutlet weak var replaceFromTextFiled: UITextField!
  @IBOutlet weak var replaceToTextFiled: UITextField!
  @IBOutlet weak var wordLimitField: UITextField!
  
  @IBAction func doneEvent(_ sender: UIButton) {
    RunTime.ivars(from: UITextView.self).forEach { (item) in
      print(String.init(cString: ivar_getName(item)!))
    }
    textView.matchs.removeAll()
    textView.replaces.removeAll()
    
    do{
      textView.wordLimit = Int(wordLimitField.text!) ?? 1024
    }
    
    if let from = replaceFromTextFiled.text,
    let to = replaceToTextFiled.text,
      !from.isEmpty {
      textView.replaces.append(LimitInputReplace(from: from, of: to))
    }
    
    do{
      let index1 = segmentedCotrol1.selectedSegmentIndex
      let index2 = segmentedCortol2.selectedSegmentIndex
      guard let title1 = segmentedCotrol1.titleForSegment(at: index1) else { return }
      guard let title2 = segmentedCortol2.titleForSegment(at: index2) else { return }
      let state1 = LimitInputDisableState(rawValue: title1)!
      let state2 = LimitInputDisableState(rawValue: title2)!
      textView.disables = [state1,state2]
    }
    
    if let text = matchTextFiled.text {
      textView.matchs.append(LimitInputMatch(rule: { (item) -> Bool in
        return !item.contains(text)
      }))
    }
  }
  
}
