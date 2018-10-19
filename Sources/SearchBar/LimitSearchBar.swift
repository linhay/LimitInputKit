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

public class LimitSearchBar: UISearchBar,LimitInputProtocol {
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
  
  /// 调整至iOS11之前的风格(高度调整)
  public var isEnbleOldStyleBefore11: Bool = true{
    didSet{
      if #available(iOS 11,*), isEnbleOldStyleBefore11 {
        let reFont = searchField?.font?.withSize(14)
        placeholderFont = reFont
        searchField?.font = reFont
      }
    }
  }
  
  /// 占位文字颜色
  public var placeholderColor: UIColor? {
    get{
      guard var attr = searchField?.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil),
        let color = attr[NSAttributedStringKey.foregroundColor] as? UIColor else{ return searchField?.textColor }
      return color
    }
    set {
      guard let placeholder = self.placeholder, let color = newValue else { return }
      if var attr = searchField?.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil) {
        attr[NSAttributedStringKey.foregroundColor] = newValue
        searchField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attr)
        return
      }
      
      let attr = [NSAttributedStringKey.foregroundColor: color]
      searchField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attr)
    }
  }
  
  /// 占位文字字体
  public var placeholderFont: UIFont? {
    get{
      guard var attr = searchField?.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil),
        let ft = attr[.font] as? UIFont else{ return searchField?.font }
      return ft
    }
    set {
      guard let placeholder = self.placeholder, let font = newValue else { return }
      if var attr = searchField?.attributedPlaceholder?.attributes(at: 0, effectiveRange: nil) {
        attr[NSAttributedStringKey.font] = newValue
        searchField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attr)
        return
      }
      let attr = [NSAttributedStringKey.font: font]
      searchField?.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attr)
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    guard #available(iOS 11,*), isEnbleOldStyleBefore11, let heightConstraint = self.constraints.first else { return }
    heightConstraint.constant = isEnbleOldStyleBefore11 ? 44 : 56
    searchField?.bounds.size.height = isEnbleOldStyleBefore11 ? 28 : 32
    self.layoutIfNeeded()
  }
  
  /// 历史文本
  var lastText = ""
  
  /// 输入控件
  public lazy var searchField: UITextField? = {
    return self.value(forKey: "_searchField") as? UITextField
  }()
  
  private var inputHelp: LimitSearchBarExecutor?
  
  public override var delegate: UISearchBarDelegate? {
    get { return inputHelp }
    set { inputHelp = LimitSearchBarExecutor(delegate: newValue)
      super.delegate = inputHelp
    }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    delegate = nil
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    delegate = nil
  }
  
  public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return canPerformAction(self, text: text ?? "", action: action) ? super.canPerformAction(action, withSender: sender) : false
  }
  
}
