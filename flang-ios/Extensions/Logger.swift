import OSLog

extension Logger {
    
    init(category: String) {
        self.init(subsystem: "de.tadris.flang-ios", category: category)
    }
}
