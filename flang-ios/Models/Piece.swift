struct Piece: Equatable {
    
    private static let TYPE_MASK: UInt8 = 0b11100000
    private static let COLOR_MASK: UInt8 = 0b00010000
    private static let FROZEN_MASK: UInt8 = 0b00001000
    
    private static let TYPE_SHIFT = 5
    private static let COLOR_SHIFT = 4
    private static let FROZEN_SHIFT = 3
    
    private var rawValue: UInt8
    
    init() {
        rawValue = .zero
    }
    
    init(type: PieceType, color: PieceColor, frozen: Bool = false) {
        self.init()
        self.type = type
        self.color = color
        self.frozen = frozen
    }
    
    var type: PieceType {
        get { PieceType(rawValue: (rawValue & Self.TYPE_MASK) >> Self.TYPE_SHIFT) }
        set { reset(for: Self.TYPE_MASK); rawValue |= ((newValue.rawValue << Self.TYPE_SHIFT) & Self.TYPE_MASK) }
    }
    
    var color: PieceColor {
        get { (rawValue & Self.COLOR_MASK) != 0 ? .white : .black }
        set { reset(for: Self.COLOR_MASK); rawValue |= ((newValue.rawValue ? 0b1 : 0b0) << Self.COLOR_SHIFT) }
    }
    
    var frozen: Bool {
        get { rawValue & Self.FROZEN_MASK != 0 }
        set { reset(for: Self.FROZEN_MASK); rawValue |= ((newValue ? 0b1 : 0b0) << Self.FROZEN_SHIFT) }
    }
    
    var imageName: String? {
        guard let imageName = type.imageName else { return nil }
        let colorPrefix = color == .white ? "w" : "b"
        return "\(colorPrefix)\(imageName)"
    }
    
    private mutating func reset(for bitMask: UInt8) {
        rawValue &= ~bitMask
    }
}
