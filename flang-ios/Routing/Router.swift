import SwiftUI

@Observable
class Router {
    
    var path: NavigationPath
    var showAuthentication: Bool
    var showTutorial: Bool
    
    init(path: NavigationPath = .init(), showAuthentication: Bool = false, showTutorial: Bool = false) {
        self.path = path
        self.showAuthentication = showAuthentication
        self.showTutorial = showTutorial
    }
}
