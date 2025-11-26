import SwiftUI

struct BackgroundBlackoutGradient: View {
    
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    var body: some View {
        Rectangle().fill(.background).mask {
            LinearGradient(colors: [.clear, .black], startPoint: startPoint, endPoint: endPoint)
        }
    }
    
    init(startPoint: UnitPoint, endPoint: UnitPoint) {
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
}
