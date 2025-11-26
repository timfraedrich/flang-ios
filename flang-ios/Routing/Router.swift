import SwiftUI

@Observable
class Router {
    
    var path: NavigationPath
    var showAuthentication: Bool
    
    init(path: NavigationPath = .init(), showAuthentication: Bool = false) {
        self.path = path
        self.showAuthentication = showAuthentication
    }
}
