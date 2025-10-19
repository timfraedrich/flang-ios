//
//  GameState.swift
//  flang-ios
//
//  Created by Tim Fraedrich on 16.10.25.
//

import Foundation
import Observation

@Observable
class GameState {
    var board: [BoardPosition: Piece] = [:]
    var selectedPosition: BoardPosition?
    var currentTurn: PieceColor = .white
    var legalMoves: Set<BoardPosition> = []

    init() {
        setupInitialPosition()
    }

    func setupInitialPosition() {
        // Clear board
        board.removeAll()

        // Flang DEFAULT starting position from Android app
        // Row 0 (rank 1): "  PRHFUK" - White back rank
        board[BoardPosition(row: 0, col: 2)] = Piece(type: .pawn, color: .white)
        board[BoardPosition(row: 0, col: 3)] = Piece(type: .rook, color: .white)
        board[BoardPosition(row: 0, col: 4)] = Piece(type: .horse, color: .white)
        board[BoardPosition(row: 0, col: 5)] = Piece(type: .flanger, color: .white)
        board[BoardPosition(row: 0, col: 6)] = Piece(type: .uni, color: .white)
        board[BoardPosition(row: 0, col: 7)] = Piece(type: .king, color: .white)

        // Row 1 (rank 2): "  PPPPPP" - White pawns
        for col in 2..<8 {
            board[BoardPosition(row: 1, col: col)] = Piece(type: .pawn, color: .white)
        }

        // Rows 2-5 are empty

        // Row 6 (rank 7): "pppppp  " - Black pawns
        for col in 0..<6 {
            board[BoardPosition(row: 6, col: col)] = Piece(type: .pawn, color: .black)
        }

        // Row 7 (rank 8): "kufhrp  " - Black back rank
        board[BoardPosition(row: 7, col: 0)] = Piece(type: .king, color: .black)
        board[BoardPosition(row: 7, col: 1)] = Piece(type: .uni, color: .black)
        board[BoardPosition(row: 7, col: 2)] = Piece(type: .flanger, color: .black)
        board[BoardPosition(row: 7, col: 3)] = Piece(type: .horse, color: .black)
        board[BoardPosition(row: 7, col: 4)] = Piece(type: .rook, color: .black)
        board[BoardPosition(row: 7, col: 5)] = Piece(type: .pawn, color: .black)

        currentTurn = .white
        selectedPosition = nil
        legalMoves.removeAll()
    }

    func selectPosition(_ position: BoardPosition) {
        // If no piece is selected
        if selectedPosition == nil {
            // Select this position if it has a piece of the current player's color
            if let piece = board[position], piece.color == currentTurn {
                selectedPosition = position
                // For now, calculate simple legal moves (this will be replaced with C engine)
                legalMoves = calculateLegalMoves(for: position)
            }
        } else if let selected = selectedPosition {
            // If the same position is tapped, deselect
            if selected == position {
                selectedPosition = nil
                legalMoves.removeAll()
            }
            // If tapping another piece of the same color, switch selection
            else if let piece = board[position], piece.color == currentTurn {
                selectedPosition = position
                legalMoves = calculateLegalMoves(for: position)
            }
            // If tapping a legal move destination, make the move
            else if legalMoves.contains(position) {
                makeMove(from: selected, to: position)
                selectedPosition = nil
                legalMoves.removeAll()
            }
            // Otherwise, deselect
            else {
                selectedPosition = nil
                legalMoves.removeAll()
            }
        }
    }

    private func makeMove(from: BoardPosition, to: BoardPosition) {
        guard let piece = board[from] else { return }

        // Move the piece
        board[to] = piece
        board.removeValue(forKey: from)

        // Switch turns
        currentTurn = currentTurn == .white ? .black : .white
    }

    // Temporary simple move calculation (will be replaced with C engine)
    private func calculateLegalMoves(for position: BoardPosition) -> Set<BoardPosition> {
        guard let piece = board[position] else { return [] }

        var moves = Set<BoardPosition>()

        // Simple placeholder logic - just allow moving to adjacent empty squares
        let directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

        for (dRow, dCol) in directions {
            let newRow = position.row + dRow
            let newCol = position.col + dCol

            guard (0..<8).contains(newRow), (0..<8).contains(newCol) else { continue }

            let newPos = BoardPosition(row: newRow, col: newCol)

            // Can move to empty square or capture opponent piece
            if board[newPos] == nil || board[newPos]?.color != piece.color {
                moves.insert(newPos)
            }
        }

        return moves
    }
}
