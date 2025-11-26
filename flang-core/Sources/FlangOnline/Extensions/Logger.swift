import OSLog

extension Logger {
    
    init(category: String) {
        self.init(subsystem: FlangOnline.moduleIdentifier, category: category)
    }
}
