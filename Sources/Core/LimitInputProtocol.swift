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


extension UITextInput {
  
  var selectedRange: NSRange? {
    set {
      let beginning = beginningOfDocument
      guard let range = newValue,
        let start = position(from: beginning, offset: range.location),
        let end = position(from: beginning, offset: range.location + range.length)
        else { return }
      let selectionRange = textRange(from: start, to: end)
      self.selectedTextRange = selectionRange
    }
    get {
      guard let range = self.selectedTextRange else { return nil }
      let location = offset(from: beginningOfDocument, to: range.start)
      let length = offset(from: range.start, to: range.end)
      return NSRange(location: location, length: length)
    }
  }
  
}

public protocol LimitInputProtocol: NSObjectProtocol {
  // 判断输入是否合法的
  var matchs: [LimitInputMatch] { set get }
  // 文本替换 保证光标位置
  var replaces: [LimitInputReplace] { set get }
  // 字数限制
  var wordLimit: Int { set get }
  // 菜单禁用项
  var disables: [LimitInputDisableState] { set get }
  // 超过字数限制
  var overWordLimitEvent: ((_ text: String)->())? { set get }
  // 完成输入
  var textDidChangeEvent: ((_ text: String)->())? { set get }
  var preIR: IR? { set get }
}

public struct IR {
  let text: String
  let range: NSRange
}

public extension LimitInputProtocol {
  
  func setOverWordLimitEvent(_ event: @escaping (_ text: String)->()) {
    self.overWordLimitEvent = event
  }
  
  func setTextDidChangeEvent(_ event: @escaping (_ text: String)->()) {
    self.textDidChangeEvent = event
  }
  
}

extension LimitInputProtocol {
  
  /// 获取输入后文本
  ///
  /// - Parameters:
  ///   - string: 原有字符串
  ///   - text: 插入字符
  ///   - range: 插入字符范围
  /// - Returns: 处理后文本与光标位置
  func getAfterInputText(string: String, text: String, range: NSRange) -> IR {
    var result = string
    var range = range
    // 删除操作
    switch text.isEmpty {
    case true:
      let startIndex = String.Index(encodedOffset: range.location)
      let endIndex = String.Index(encodedOffset: range.location + range.length)
      // 全选删除
      if startIndex <= result.startIndex {
        range.location = 0
        range.length = 0
        result = String(result[endIndex..<result.endIndex])
      }
        // 尾部删除
      else if endIndex >= result.endIndex {
        range.location -= text.utf16.count
        result = String(result[result.startIndex...startIndex])
      }
        // 局部删除
      else{
        range.length = 0
        result = String(result[result.startIndex...startIndex]) + String(result[endIndex..<result.endIndex])
      }
    case false:
      /// 正常输入
      let startIndex = String.Index(encodedOffset: range.location)
      let endIndex = String.Index(encodedOffset: range.location + range.length)
      // 头部添加
      if startIndex <= result.startIndex, range.length == 0 {
        range.location += text.utf16.count
        result = text + result
      }
        // 尾部添加
      else if endIndex >= result.endIndex, range.length == 0 {
        range.location += text.utf16.count
        result = result + text
      }
        // 局部替换
      else{
        range.length = text.utf16.count
        result = String(result[result.startIndex..<startIndex]) + text + String(result[endIndex..<result.endIndex])
      }
    }
    return IR(text: result, range: range)
  }
  
  
  /// 文本输入完成后处理
  ///
  /// - Parameters:
  ///   - input: 输入控件
  ///   - text: 文本
  func textDidChange(input: UITextInput, text: String) -> IR? {
    guard input.markedTextRange == nil, let range = input.selectedRange else { return nil }
    let ir1 = replaces(ir: IR(text: text, range: range))
    let ir2 = match(text: ir1.text) ? ir1 : self.preIR ?? IR(text: "", range: NSRange(location: 0, length: 0))
    if self.preIR?.text == ir2.text { return nil }
    return ir2
  }
  
  /// 文本输入前处理
  ///
  /// - Parameters:
  ///   - input: 输入控件
  ///   - range: 插入位置
  ///   - string: 待输入文本
  /// - Returns: 能否输入
  public func shouldChange(input: UITextInput, range: NSRange, string: String) -> Bool {
    if string.isEmpty { return true }
    guard input.markedTextRange == nil,
      let allRange = input.textRange(from: input.beginningOfDocument, to: input.endOfDocument),
      let text = input.text(in: allRange) else { return true }
    
    let ir1 = getAfterInputText(string: text, text: string, range: range)
    let ir2 = replaces(ir: ir1)
    
    if !match(text: ir2.text) { return false }
    // 处理字符限制
    if ir2.text.count > wordLimit { return false }
    
    self.preIR = ir1
    return true
  }
  
}

extension LimitInputProtocol {
  
  func replaces(ir: IR) -> IR {
    if self.replaces.isEmpty || ir.text.isEmpty { return ir }
    var text = ir.text
    var range = ir.range
    var offset = 0
    
    for item in replaces {
      let list = text.components(separatedBy: item.key)
      guard list.count > 1 else { continue }
      offset += list.count * (item.value.utf16.count - item.key.utf16.count)
      text = list.joined(separator: item.value)
    }
    
    range.location += offset
    return IR(text: text, range: range)
  }
  
}
public extension LimitInputProtocol {
  
  /// 判断输入是否合法的
  ///
  /// - Parameter text: 待判断文本
  /// - Returns: 结构
  public func match(text: String) -> Bool {
    
    if text.isEmpty { return true }
    
    if text.count > wordLimit {
      overWordLimitEvent?(text)
      return false
    }
    
    for item in matchs {
      if !item.code(text) { return false }
    }
    return true
  }
  
}


public extension LimitInputProtocol {
  /// 是否响应工具条事件
  ///
  /// - Parameters:
  ///   - respoder: textView & textfield
  ///   - action: 执行方法名
  /// - Returns: 是否响应
  public func canPerformAction(_ respoder: UIResponder,text: String, action: Selector) -> Bool {
    if disables == LimitInputDisableState.allCases { return false }
    
    guard let state = LimitInputDisableState(rawValue: action.description) else {
      return true
    }
    
    let res = !disables.contains(state)
    
    if state == .paste, let str = UIPasteboard.general.string {
      return !disables.contains(.paste) && (str.count + text.count) <= wordLimit
    }
    
    return res
  }
  
  
}
