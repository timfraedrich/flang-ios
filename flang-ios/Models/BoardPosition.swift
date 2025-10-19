//
//  BoardPosition.swift
//  flang-ios
//
//  Created by Tim Fraedrich on 16.10.25.
//

import Foundation

struct BoardPosition: Hashable, Equatable {
    let row: Int
    let col: Int

    // Convert to algebraic notation (e.g., "e2")
    var algebraic: String {
        let file = String(UnicodeScalar(UInt8(97 + col))) // 'a' + col
        let rank = row + 1
        return "\(file)\(rank)"
    }

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    init?(algebraic: String) {
        guard algebraic.count == 2,
              let file = algebraic.first,
              let rank = algebraic.last,
              let col = file.asciiValue.map({ Int($0) - 97 }),
              let row = rank.wholeNumberValue.map({ $0 - 1 }),
              (0...7).contains(col),
              (0...7).contains(row) else {
            return nil
        }
        self.row = row
        self.col = col
    }

    // Convert to array index (0-63)
    var index: Int {
        row * 8 + col
    }

    static func from(index: Int) -> BoardPosition {
        BoardPosition(row: index / 8, col: index % 8)
    }
}
