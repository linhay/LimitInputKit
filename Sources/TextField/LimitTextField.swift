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

@IBDesignable
open class LimitTextField: UITextField,LimitInputProtocol {
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
  /// 设置占位文本偏移
  public var placeholderEdgeInsets: UIEdgeInsets = .zero
  /// 占位文本控件
  public lazy var placeholderLabel: UILabel? = {
    return self.value(forKey: "_placeholderLabel") as? UILabel
  }()
  
  /// 历史文本
  private var lastText = ""
  
  private var inputHelp: LimitTextFieldExecutor?
  
  override open var delegate: UITextFieldDelegate? {
    get { return inputHelp }
    set { inputHelp = LimitTextFieldExecutor(delegate: newValue)
      super.delegate = inputHelp
    }
  }
  
  open override var isEditing: Bool {
    if placeholderEdgeInsets != .zero {
      drawPlaceholder(in: self.bounds)
    }
    return super.isEditing
  }
  
  override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if canPerformAction(self, text: text ?? "", action: action) {
      return super.canPerformAction(action, withSender: sender)
    }
    return false
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    buildConfig()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    buildConfig()
  }
  
  open override func drawPlaceholder(in rect: CGRect) {
    super.drawPlaceholder(in: rect)
    guard placeholderEdgeInsets != .zero, var labelFarme = placeholderLabel?.frame else{ return }
    
    if !(placeholderEdgeInsets.top == 0 && placeholderEdgeInsets.bottom == 0) {
      if placeholderEdgeInsets.top != 0 && placeholderEdgeInsets.bottom != 0 {
        labelFarme.origin.y = placeholderEdgeInsets.top
        labelFarme.size.height = rect.height - placeholderEdgeInsets.top - placeholderEdgeInsets.bottom
      } else if placeholderEdgeInsets.top != 0 {
        labelFarme.origin.y = placeholderEdgeInsets.top
      } else if placeholderEdgeInsets.bottom == 0 {
        labelFarme.origin.y = rect.height - labelFarme.height - placeholderEdgeInsets.bottom
      }
    }
    
    if !(placeholderEdgeInsets.left == 0 && placeholderEdgeInsets.right == 0) {
      if placeholderEdgeInsets.left != 0 && placeholderEdgeInsets.right != 0 {
        labelFarme.origin.x = placeholderEdgeInsets.right
        labelFarme.size.width = rect.width - placeholderEdgeInsets.left - placeholderEdgeInsets.right
      } else if placeholderEdgeInsets.left != 0 {
        labelFarme.origin.x = placeholderEdgeInsets.left
      } else if placeholderEdgeInsets.right == 0 {
        labelFarme.origin.x = rect.width - placeholderEdgeInsets.left - placeholderEdgeInsets.right
      }
    }
    
    placeholderLabel?.frame = labelFarme
  }
  
  /// MARK: - Deinitialized
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
}

/// MARK: - Config
extension LimitTextField{
  
  func buildConfig() {
    delegate = nil
    buildNotifications()
  }
  
  fileprivate func buildNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(textField(changed:)),
                                           name:  NSNotification.Name.UITextFieldTextDidChange,
                                           object: nil)
  }
  
}

extension LimitTextField {
  @objc private func textField(changed not: Notification) {
    guard let input = not.object as? LimitTextField, self == input else { return }
    textDidChange(input: input, text: input.text ?? "", lastText: lastText) { (res) in
      if res != input.text { input.text = res }
      lastText = res
    }
  }
}





