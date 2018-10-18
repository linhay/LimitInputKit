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

public class LimitTextView: UITextView,LimitInputProtocol {
  /// 字数限制
  public var wordLimit: Int = LimitInputConfig.wordLimit
  /// 文字超出字符限制执行
  public var overWordLimitEvent: ((String) -> ())? = LimitInputConfig.overWordLimitEvent
  /// 文字过滤与转换
  public var filters: [LimitInputFilter] = LimitInputConfig.filters
  /// 判断输入是否合法的
  public var matchs: [LimitInputMatch] = LimitInputConfig.matchs
  /// 菜单禁用项
  public var disables: [LimitInputDisableState] = LimitInputConfig.disables
  
  private var inputHelp: LimitTextViewExecutor?
  
  public lazy var placeholderLabel: UILabel = {
    let item = UILabel()
    item.font = font
    item.numberOfLines = 0
    item.textColor = UIColor(red: 0, green: 0, blue: 0.1, alpha: 0.22)
    item.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(item)
    let views = ["label": item]
    let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[label]-5-|",
                                                     options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                     metrics: nil,
                                                     views: views)
    
    let vConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[label]-5-|",
                                                     options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                     metrics: nil,
                                                     views: views)
    self.addConstraints(hConstraint + vConstraint)
    return item
  }()
  
  override open var delegate: UITextViewDelegate? {
    get { return inputHelp }
    set { inputHelp = LimitTextViewExecutor(delegate: newValue)
      super.delegate = inputHelp
    }
  }
  
  /// 文本框文本
  public override var text: String!{
    set {
      if newValue == text { return }
      super.text = newValue
      lastText = newValue
    }
    get {
      return super.text
    }
  }
  
  /// 历史文本
  public var lastText = ""{
    didSet{
      if lastText == oldValue { return }
      placeholderLabel.isHidden = !lastText.isEmpty
      guard wordLimit != Int.max else { return }
    }
  }
  
  /// 占位文字
  public var placeholder: String?{
    set{ placeholderLabel.text = newValue }
    get{ return placeholderLabel.text }
  }
  
  public override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    buildConfig()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    buildConfig()
  }
  
  override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if canPerformAction(self, text: text, action: action) {
      return super.canPerformAction(action, withSender: sender)
    }
    return false
  }
  
  //MARK: - Deinitialized
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
}

// MARK: - Config
extension LimitTextView{
  
  func buildConfig() {
    delegate = nil
    buildNotifications()
  }
  
  fileprivate func buildNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(textView(changed:)),
                                           name: Notification.Name.UITextViewTextDidChange,
                                           object: nil)
  }
}

extension LimitTextView {
  @objc private func textView(changed not: Notification) {
    guard let input = not.object as? LimitTextView, self == input else { return }
    textDidChange(input: input, text: input.text, lastText: lastText) { (res) in
      if res != input.text { input.text = res }
      lastText = res
    }
  }
  
}

