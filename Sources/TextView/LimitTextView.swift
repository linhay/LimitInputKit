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
  
  /// 占位文本控件
  public lazy var placeholderLabel: UILabel = {
    let item = UILabel()
    item.numberOfLines = 0
    item.font = font
    item.textColor = UIColor.gray.withAlphaComponent(0.7)
    self.addSubview(item)
    self.setValue(item, forKey: "_placeholderLabel")
    return item
  }()
  
  /// 占位颜色
  open var placeholderColor: UIColor{
    set{ placeholderLabel.textColor = newValue }
    get{ return placeholderLabel.textColor }
  }
  
  /// 占位富文本
  open var attributedPlaceholder: NSAttributedString? {
    set{ placeholderLabel.attributedText = newValue }
    get{ return placeholderLabel.attributedText }
  }
  
  /// 占位文本
  open var placeholder: String? {
    set{ placeholderLabel.text = newValue }
    get{ return placeholderLabel.text }
  }
  
  private var inputHelp: LimitTextViewExecutor?
  
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
      guard wordLimit != Int.max else { return }
    }
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
    return canPerformAction(self, text: text, action: action) ? super.canPerformAction(action, withSender: sender) : false
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

