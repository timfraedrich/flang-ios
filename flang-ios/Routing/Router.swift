import SwiftUI

@Observable
class Router {
    
    var path: NavigationPath
    var sheets: [SheetDestination]
    var currentSheet: SheetDestination? {
        get { sheets.last }
        set {
            if let newValue {
                sheets.append(newValue)
            } else if !sheets.isEmpty {
                sheets.removeLast()
            }
        }
    }
    
    init(path: NavigationPath = .init(), sheets: [SheetDestination]) {
        self.path = path
        self.sheets = sheets
    }
}
