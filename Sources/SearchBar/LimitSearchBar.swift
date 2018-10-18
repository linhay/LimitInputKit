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
  /// 调整至iOS10之前的风格(高度调整)
  public var isEnbleOldStyleBefore10: Bool = false

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
    buildConfig()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    buildConfig()
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    // fix 10 以上 textField 高度变更
    if #available(iOS 10,*), isEnbleOldStyleBefore10 {
      subviews.forEach { (view) in
        view.subviews.forEach({ (subview) in
          if subview is UITextField {
            let con = subview.frame.height - 28
            subview.frame.origin.y = subview.frame.origin.y + con * 0.5
            subview.frame.size.height = 28
          }
          if subview is UIImageView {
            subview.removeFromSuperview()
          }
        })
      }
    }
  }
  
  public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    if canPerformAction(self, text: text ?? "", action: action) {
      return super.canPerformAction(action, withSender: sender)
    }
    return false
  }
  
}

/// MARK: - Config
extension LimitSearchBar{
  
  func buildConfig() {
    delegate = nil
  }
  
}


