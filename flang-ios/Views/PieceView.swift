//
//  PieceView.swift
//  flang-ios
//
//  Created by Tim Fraedrich on 16.10.25.
//

import SwiftUI

struct PieceView: View {
    let piece: Piece
    let size: CGFloat

    var body: some View {
        ZStack {
            // Piece image
            Image(piece.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)

            // Frozen indicator
            if piece.frozenState == .frozen {
                Image(systemName: "snowflake")
                    .foregroundStyle(.blue)
                    .font(.system(size: size * 0.3))
                    .offset(x: size * 0.3, y: -size * 0.3)
                    .shadow(color: .white, radius: 2)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview("White Pieces") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            PieceView(piece: Piece(type: .king, color: .white), size: 50)
            PieceView(piece: Piece(type: .uni, color: .white), size: 50)
            PieceView(piece: Piece(type: .rook, color: .white), size: 50)
        }
        HStack(spacing: 20) {
            PieceView(piece: Piece(type: .flanger, color: .white), size: 50)
            PieceView(piece: Piece(type: .horse, color: .white), size: 50)
            PieceView(piece: Piece(type: .pawn, color: .white), size: 50)
        }
    }
    .padding()
    .background(Color.brown.opacity(0.3))
}

#Preview("Black Pieces") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            PieceView(piece: Piece(type: .king, color: .black), size: 50)
            PieceView(piece: Piece(type: .uni, color: .black), size: 50)
            PieceView(piece: Piece(type: .rook, color: .black), size: 50)
        }
        HStack(spacing: 20) {
            PieceView(piece: Piece(type: .flanger, color: .black), size: 50)
            PieceView(piece: Piece(type: .horse, color: .black), size: 50)
            PieceView(piece: Piece(type: .pawn, color: .black), size: 50)
        }
    }
    .padding()
    .background(Color.brown.opacity(0.3))
}

#Preview("Frozen Piece") {
    PieceView(piece: Piece(type: .king, color: .white, frozenState: .frozen), size: 80)
        .padding()
        .background(Color.brown.opacity(0.3))
}
