import Foundation

public enum Formatting {
    
    public static func formatMilliseconds(_ durationInMilliseconds: Int) -> String {
        let timeInterval = TimeInterval(durationInMilliseconds) / 1000
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: timeInterval) ?? "nil"
    }
}
