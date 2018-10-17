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

class TextViewHelp: TextInputDelegate, UITextViewDelegate {
  
  @available(iOS 2.0, *)
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool{
    if let input = textView as? TextView {
      input.placeholderLabel.isHidden = true
    }
    return textInputDelegate?.textViewShouldBeginEditing?(textView) ?? true
  }
  
  @available(iOS 2.0, *)
  public func textViewShouldEndEditing(_ textView: UITextView) -> Bool{
    if let input = textView as? TextView {
      input.placeholderLabel.isHidden = !input.lastText.isEmpty
    }
    return textInputDelegate?.textViewShouldEndEditing?(textView) ?? true
  }
  
  @available(iOS 2.0, *)
  public func textViewDidBeginEditing(_ textView: UITextView){
    textInputDelegate?.textViewDidBeginEditing?(textView)
  }
  
  @available(iOS 2.0, *)
  public func textViewDidEndEditing(_ textView: UITextView){
    textInputDelegate?.textViewDidEndEditing?(textView)
  }
  
  @available(iOS 2.0, *)
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
    if let flag = textInputDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text),!flag { return flag }
    guard let input = textView as? TextView else { return true }
    let value = input.shouldChange(input: input, range: range, string: text)
    print(value)
    return value
  }
  
  
  @available(iOS 2.0, *)
  public func textViewDidChange(_ textView: UITextView){
    textInputDelegate?.textViewDidChange?(textView)
  }
  
  //选中textView 或者输入内容的时候调用
  @available(iOS 2.0, *)
  public func textViewDidChangeSelection(_ textView: UITextView){
    textInputDelegate?.textViewDidChangeSelection?(textView)
  }
  
  @available(iOS 10.0, *)
  public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool{
    return textInputDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
  }
  
  @available(iOS 10.0, *)
  public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool{
    return textInputDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
  }
  
  @available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead")
  public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool{
    return textInputDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange) ?? true
  }
  
  @available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView:shouldInteractWithTextAttachment:inRange:forInteractionType: instead")
  public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool{
    return textInputDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange) ?? true
  }
}
