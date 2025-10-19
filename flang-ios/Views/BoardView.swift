//
//  BoardView.swift
//  flang-ios
//
//  Created by Tim Fraedrich on 16.10.25.
//

import SwiftUI

struct BoardView: View {
    @State private var gameState = GameState()

    private let boardSize: CGFloat = 360
    private var squareSize: CGFloat {
        boardSize / 8
    }

    var body: some View {
        VStack(spacing: 0) {
            // Column labels (a-h)
            HStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { col in
                    Text(String(UnicodeScalar(UInt8(97 + col))))
                        .frame(width: squareSize)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 0) {
                // Row labels (1-8)
                VStack(spacing: 0) {
                    ForEach((0..<8).reversed(), id: \.self) { row in
                        Text("\(row + 1)")
                            .frame(height: squareSize)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 20)

                // The board grid
                ZStack {
                    // Background squares
                    VStack(spacing: 0) {
                        ForEach((0..<8).reversed(), id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<8, id: \.self) { col in
                                    SquareView(
                                        position: BoardPosition(row: row, col: col),
                                        gameState: gameState
                                    )
                                }
                            }
                        }
                    }
                }
                .frame(width: boardSize, height: boardSize)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Turn indicator
            HStack {
                Text("Turn:")
                    .font(.headline)
                Circle()
                    .fill(gameState.currentTurn == .white ? .white : .black)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(.gray, lineWidth: 1)
                    )
                Text(gameState.currentTurn == .white ? "White" : "Black")
                    .font(.headline)
            }
            .padding()
        }
        .padding()
    }
}

struct SquareView: View {
    let position: BoardPosition
    let gameState: GameState

    private var squareSize: CGFloat {
        360 / 8
    }

    private var isLightSquare: Bool {
        (position.row + position.col) % 2 == 0
    }

    private var isSelected: Bool {
        gameState.selectedPosition == position
    }

    private var isLegalMove: Bool {
        gameState.legalMoves.contains(position)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(squareColor)
                .frame(width: squareSize, height: squareSize)

            // Highlight for legal moves
            if isLegalMove {
                Circle()
                    .fill(.green.opacity(0.3))
                    .frame(width: squareSize * 0.4, height: squareSize * 0.4)
            }

            // Piece if present
            if let piece = gameState.board[position] {
                PieceView(piece: piece, size: squareSize * 0.7)
            }

            // Selection border
            if isSelected {
                Rectangle()
                    .strokeBorder(.blue, lineWidth: 3)
                    .frame(width: squareSize, height: squareSize)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            gameState.selectPosition(position)
        }
    }

    private var squareColor: Color {
        isLightSquare ? Color(red: 0.93, green: 0.85, blue: 0.72) : Color(red: 0.72, green: 0.53, blue: 0.33)
    }
}

#Preview {
    BoardView()
}
