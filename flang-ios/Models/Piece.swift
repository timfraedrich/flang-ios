//
//  Piece.swift
//  flang-ios
//
//  Created by Tim Fraedrich on 16.10.25.
//

import Foundation

enum PieceType: String, CaseIterable {
    case pawn = "p"
    case horse = "n"  // Knight/horse in chess notation
    case rook = "r"
    case flanger = "f"
    case uni = "q"    // Queen/Uni
    case king = "k"

    var imageName: String {
        // Returns the image name based on type
        switch self {
        case .pawn: return "p"
        case .horse: return "n"
        case .rook: return "r"
        case .flanger: return "f"
        case .uni: return "q"
        case .king: return "k"
        }
    }

    var symbol: String {
        switch self {
        case .pawn: return "♟"
        case .horse: return "♞"
        case .rook: return "♜"
        case .flanger: return "♗"
        case .uni: return "♛"
        case .king: return "♚"
        }
    }

    // Piece can freeze opponent's piece after moving
    var hasFreeze: Bool {
        return self != .king
    }
}

enum PieceColor {
    case white
    case black
}

enum FrozenState {
    case normal
    case frozen
}

struct Piece: Identifiable, Equatable {
    let id = UUID()
    let type: PieceType
    let color: PieceColor
    var frozenState: FrozenState

    var symbol: String {
        type.symbol
    }

    // Full image name for the piece (e.g., "wp", "bk")
    var imageName: String {
        let colorPrefix = color == .white ? "w" : "b"
        return "\(colorPrefix)\(type.imageName)"
    }

    init(type: PieceType, color: PieceColor, frozenState: FrozenState = .normal) {
        self.type = type
        self.color = color
        self.frozenState = frozenState
    }
}
