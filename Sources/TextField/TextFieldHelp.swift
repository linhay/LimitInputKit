/*
 |-| Copyright (c) 2018 linhay <is.linhay@outlook.com>
 |-| LimitInputKit https://github.com/linhay/LimitInputKit
 |-|
 |-| Permission is hereby granted, free of charge, to any person obtaining a copy
 |-| of this software and associated documentation files (the "Software"), to deal
 |-| in the Software without restriction, including without limitation the rights
 |-| to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 |-| copies of the Software, and to permit persons to whom the Software is
 |-| furnished to do so, subject to the following conditions:
 |-|
 |-| The above copyright notice and this permission notice shall be included in
 |-| all copies or substantial portions of the Software.
 |-|
 |-| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 |-| IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 |-| FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 |-| AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 |-| LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 |-| OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 |-| THE SOFTWARE.
 */

import UIKit

class TextFieldHelp: TextInputDelegate, UITextFieldDelegate {
  
  @available(iOS 2.0, *)
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return textInputDelegate?.textFieldShouldBeginEditing?(textField) ?? true
  }
  
  @available(iOS 2.0, *)
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textInputDelegate?.textFieldDidBeginEditing?(textField)
  }
  
  @available(iOS 2.0, *)
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return textInputDelegate?.textFieldShouldEndEditing?(textField) ?? true
  }
  
  @available(iOS 2.0, *)
  func textFieldDidEndEditing(_ textField: UITextField) {
    textInputDelegate?.textFieldDidEndEditing?(textField)
  }
  
  @available(iOS 2.0, *)
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    return textInputDelegate?.textFieldShouldClear?(textField) ?? true
  }
  
  @available(iOS 2.0, *)
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textInputDelegate?.textFieldShouldReturn?(textField) ?? true
  }
  
  @available(iOS 10.0, *)
  func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
    textInputDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    textInputDelegate?.textFieldDidEndEditing?(textField)
  }
  
  @available(iOS 2.0, *)
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let flag = textInputDelegate?.textField?(textField,shouldChangeCharactersIn: range, replacementString: string),!flag { return flag }
    guard let input = textField as? TextField else { return true }
    return input.shouldChange(input: input, range: range, string: string)
  }
}
