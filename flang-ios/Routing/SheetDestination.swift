import FlangModel

enum SheetDestination: Hashable, Identifiable {
    
    case tutorial
    case authentication
    case settings
    
    var id: Int { hashValue }
}
