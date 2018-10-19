//
//  LimitTextFieldViewController.swift
//  LimitInputKit_Example
//
//  Created by linhey on 2018/10/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import LimitInputKit

class LimitTextFieldViewController: UIViewController {
  
  @IBOutlet weak var limitRuleTextField: UITextField!
  @IBOutlet weak var replaceFromTextField: UITextField!
  @IBOutlet weak var replaceToTextField: UITextField!
  
  @IBOutlet weak var allBtn: UIButton!
  @IBOutlet weak var cutBtn: UIButton!
  @IBOutlet weak var copyBtn: UIButton!
  @IBOutlet weak var pasteBtn: UIButton!
  @IBOutlet weak var selectBtn: UIButton!
  @IBOutlet weak var selectAllBtn: UIButton!
  @IBOutlet weak var deleteBtn: UIButton!
  @IBOutlet weak var shareBtn: UIButton!
  
  @IBOutlet weak var limitTextField: LimitTextField!
  @IBOutlet weak var limitSearchBar: LimitSearchBar!{
    didSet{
      limitSearchBar.isEnbleOldStyleBefore11 = true
    }
  }
  @IBOutlet weak var limitTextView: LimitTextView!{
    didSet{
      limitTextView.placeholder = "limitTextView"
    }
  }
  
  lazy var statesBtns: [UIButton: LimitInputDisableState] = [shareBtn!: .share,
                                                             allBtn!: .all,
                                                             cutBtn!: .cut,
                                                             copyBtn!: .copy,
                                                             pasteBtn!: .paste,
                                                             selectBtn!: .select,
                                                             selectAllBtn!: .selectAll,
                                                             deleteBtn!: .delete]
  
  lazy var ruleInputs: [UITextField] = [limitRuleTextField!,replaceFromTextField!, replaceToTextField!]
  lazy var inputs: [LimitInputProtocol] = [limitTextField!,limitSearchBar!, limitTextView!]
  
  @IBAction func setRules(_ sender: UIButton) {
    ruleInputs.forEach { (input) in
      input.endEditing(true)
    }
    
    guard
      let limitChars = limitRuleTextField.text,
      let replaceFromText = replaceFromTextField.text,
      let replaceToText = replaceToTextField.text
      else{ return }
    
    let disableStates = statesBtns.compactMap({ (item) -> LimitInputDisableState? in
      return item.key.isSelected ? item.value : nil
    })
    
    let match = LimitInputMatch(rule: { (text) -> Bool in
      return !text.contains(where: { (char) -> Bool in
        return limitChars.contains(char)
      })
    })
    
    let filter = LimitInputFilter(rule: { (text) -> String in
      return text.replacingOccurrences(of: replaceFromText, with: replaceToText)
    })
    
    inputs.forEach { (input) in
      input.matchs.removeAll()
      input.filters.removeAll()
    }
    
    inputs.forEach { (input) in
      input.matchs.append(match)
      input.filters.append(filter)
      input.disables = disableStates
    }

  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    statesBtns.keys.forEach { (item) in
      item.addTarget(self, action: #selector(stateEvent(btn:)), for: UIControl.Event.touchUpInside)
    }
    
  }

  @objc func stateEvent(btn: UIButton) {
    btn.isSelected.toggle()
  }
  
}
