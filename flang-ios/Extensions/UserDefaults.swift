import Foundation

extension UserDefaults {
    
    private static let hasFinishedTutorialKey = "flang_hasFinishedTutorial"
    
    var hasFinishedTutorial: Bool {
        get { bool(forKey: Self.hasFinishedTutorialKey) }
        set { set(newValue, forKey: Self.hasFinishedTutorialKey) }
    }
}
