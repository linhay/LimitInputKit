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
    guard let range = self.selectedTextRange else { return nil }
    let location = offset(from: beginningOfDocument, to: range.start)
    let length = offset(from: range.start, to: range.end)
    return NSRange(location: location, length: length)
  }
}

public protocol LimitInputProtocol: NSObjectProtocol {
  // 文字过滤与转换 无法保证光标位置
  var filters: [LimitInputFilter] { set get }
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
}

public extension LimitInputProtocol {
  
  /// 获取输入后文本
  ///
  /// - Parameters:
  ///   - string: 原有字符串
  ///   - text: 插入字符
  ///   - range: 插入字符范围
  /// - Returns: 处理后文本
  public func getAfterInputText(string: String,text: String,range: NSRange) -> String {
    var result = string
    // 删除操作
    switch text.isEmpty {
    case true:
      let startIndex = String.Index(encodedOffset: range.location)
      let endIndex = String.Index(encodedOffset: range.location + range.length)
      // 全选删除
      if startIndex <= result.startIndex {
        result = String(result[endIndex..<result.endIndex])
      }
        // 尾部删除
      else if endIndex >= result.endIndex {
        result = String(result[result.startIndex...startIndex])
      }
        // 局部删除
      else{
        result = String(result[result.startIndex...startIndex]) + String(result[endIndex..<result.endIndex])
      }
    case false:
      /// 正常输入
      let startIndex = String.Index(encodedOffset: range.location)
      let endIndex = String.Index(encodedOffset: range.location + range.length)
      // 头部添加
      if startIndex <= result.startIndex, range.length == 0 {
        result = text + result
      }
        // 尾部添加
      else if endIndex >= result.endIndex, range.length == 0 {
        result = result + text
      }
        // 局部替换
      else{
        result = String(result[result.startIndex..<startIndex]) + text + String(result[endIndex..<result.endIndex])
      }
    }
    return result
  }
  
  func textDidChange(input: UITextInput, text: String, lastText: String, call: (_ result: String) -> ()) {
    guard input.markedTextRange == nil, let range = input.selectedRange else { return }
    let filterText = filter(text: text)
    let replaceResult = replaces(text: filterText, range: range)
    let result3 = match(text: replaceResult.text) ? replaceResult.text : lastText
    
    call(result3)
    
    if result3 == text { return }
    
    let preStr = result3[...String.Index(encodedOffset: replaceResult.range.location)]
    /// utf16: emoji 字符为 utf8
    guard let start = input.position(from: input.beginningOfDocument, offset: preStr.utf16.count) else{ return }
    input.selectedTextRange = input.textRange(from: start, to: start)
  }
  
  public func shouldChange(input: UITextInput, range: NSRange, string: String) -> Bool {
    if string.isEmpty { return true }
    guard input.markedTextRange == nil,
      let allRange = input.textRange(from: input.beginningOfDocument, to: input.endOfDocument),
      let text = input.text(in: allRange) else { return true }
    
    let finishText = getAfterInputText(string: text, text: string, range: range)
    let filterText = filter(text: finishText)
    let replaceResult = replaces(text: filterText, range: range)
    
    if !match(text: replaceResult.text) { return false }
    // 处理字符限制
    if replaceResult.text.count > wordLimit { return false }
    // 处理第三方键盘候选词输入/粘贴
    // if inputStr != string,range.length != 0 { return false }
    return true
  }
  
}

public extension LimitInputProtocol {
  
  func replaces(text: String,range: NSRange) -> (text: String, range: NSRange) {
    var range = range
    var text = text
    for item in replaces {
      let res = split(replace: item, text: text, range: range)
      range = reviseRange(replace: item, indexs: res.indexs, pointIndex: res.pointIndex, range: range)
      text = reviseText(replace: item, substrings: res.substrings, indexs: res.indexs)
    }
    
    return (text,range)
  }
  
  // 修正文本内容位置
  func reviseText(replace: LimitInputReplace, substrings: [String],indexs: [Int]) -> String {
    var substrings = substrings
    for index in indexs {
      substrings[index] = replace.value
    }
    return substrings.joined()
  }
  
  // 修正光标位置
  func reviseRange(replace: LimitInputReplace,indexs: [Int], pointIndex: Int, range: NSRange) -> NSRange {
    var flag = 0
    for item in indexs {
      if item > pointIndex { break }
      flag += 1
    }
    let point = range.location + range.length
    let offset = replace.offset * flag
    return NSRange(location: point + offset, length: 0)
  }
  
  // 文本预处理
  func split( replace: LimitInputReplace, text: String, range: NSRange) -> (substrings: [String],indexs: [Int],pointIndex: Int) {
    /// 缓冲标志位
    var flag = false
    /// 文本分割数组
    var substrings = [String]()
    /// 不需要替换缓冲数据
    var buffer = [Character]()
    /// 需要替换缓冲数据
    var keybuffer = [Character]()
    /// 需要替换元素标志位
    var indexs = [Int]()
    /// 光标位于元素标志位
    var pointIndex = -1
    /// 光标末尾位置
    let point = range.location + range.length
    
    text.enumerated().forEach { (element) in
      let index = element.offset
      let char = element.element
      if char == replace.key.first { flag = true }
      if index == point - 1, !substrings.isEmpty { pointIndex = substrings.count }
      
      if keybuffer.count >= replace.chars.count {
        if !buffer.isEmpty { substrings.append(String(buffer)) }
        
        substrings.append(String(keybuffer))
        indexs.append(substrings.count - 1)
        buffer.removeAll()
        keybuffer.removeAll()
      }
      
      if flag, char == replace.chars[keybuffer.count] {
        keybuffer.append(char)
      }else{
        flag = false
        buffer += keybuffer
        buffer.append(char)
        keybuffer.removeAll()
      }
    }
    
    if keybuffer == replace.chars {
      if !buffer.isEmpty { substrings.append(String(buffer)) }
      substrings.append(String(keybuffer))
      indexs.append(substrings.count - 1)
   }else{
      substrings.append(String(buffer + keybuffer))
    }
    
    if indexs.isEmpty || pointIndex == -1 { pointIndex = point }
    return (substrings,indexs,pointIndex)
  }
  
}
public extension LimitInputProtocol {
  
  /// 判断输入是否合法的
  ///
  /// - Parameter text: 待判断文本
  /// - Returns: 结构
  public func match(text: String) -> Bool {
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
  /// 文本过滤
  ///
  /// - Parameter text: 待过滤文本
  /// - Returns: 过滤后文本
  public func filter(text: String) -> String {
    var text = text
    for item in filters {
      text = item.code(text)
    }
    text = filter(limit: text)
    return text
  }
  
  /// 过滤超过字符限制字符
  ///
  /// - Parameter text: 待过滤文本
  /// - Returns: 过滤后文本
  public func filter(limit text: String) -> String {
    if wordLimit == Int.max { return text }
    let endIndex = String.Index(encodedOffset: wordLimit)
    if text.count > wordLimit{
      overWordLimitEvent?(text)
      return String(text[text.startIndex..<endIndex])
    }
    
    return text
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
    if disables.contains(.all) { return false }
    
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
