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

public class LimitSearchBarExecutor: LimitInputDelegate, UISearchBarDelegate {
  
  @available(iOS 2.0, *)
  public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    return textInputDelegate?.searchBarShouldBeginEditing?(searchBar) ?? true
  }
  
  @available(iOS 2.0, *)
  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    textInputDelegate?.searchBarTextDidBeginEditing?(searchBar)
  }
  
  @available(iOS 2.0, *)
  public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool{
    return textInputDelegate?.searchBarShouldEndEditing?(searchBar) ?? true
  }
  
  @available(iOS 2.0, *)
  public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    textInputDelegate?.searchBarTextDidEndEditing?(searchBar)
  }
  
  @available(iOS 2.0, *)
  public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
    textInputDelegate?.searchBar(searchBar, textDidChange: searchText)
    guard let searchBar = searchBar as? LimitSearchBar,
      let input = searchBar.searchField,
    let ir = searchBar.textDidChange(input: input, text: searchText) else { return }
    searchBar.text = ir.text
    (input as UITextInput).selectedRange = ir.range
    searchBar.textDidChangeEvent?(ir.text)
  }
  
  @available(iOS 3.0, *)
  public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if let flag = textInputDelegate?.searchBar?(searchBar, shouldChangeTextIn: range, replacementText: text),!flag { return flag }
    guard  let searchBar = searchBar as? LimitSearchBar, let input = searchBar.searchField else { return true }
    return searchBar.shouldChange(input: input, range: range, string: text)
  }
  
  @available(iOS 2.0, *)
  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    textInputDelegate?.searchBarSearchButtonClicked?(searchBar)
  }
  
  @available(iOS 2.0, *)
  public func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
    textInputDelegate?.searchBarBookmarkButtonClicked?(searchBar)
  }
  
  @available(iOS 2.0, *)
  public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    textInputDelegate?.searchBarCancelButtonClicked?(searchBar)
  }
  
  @available(iOS 3.2, *)
  public func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
    textInputDelegate?.searchBarResultsListButtonClicked?(searchBar)
  }
  
  @available(iOS 3.0, *)
  public func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int){
    textInputDelegate?.searchBar?(searchBar, selectedScopeButtonIndexDidChange: selectedScope)
  }
  
}
