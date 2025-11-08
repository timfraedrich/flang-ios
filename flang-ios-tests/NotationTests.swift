import Testing
@testable import flang_ios

@Suite("Notation Tests")
struct NotationTests {

    // MARK: - FBN (Flang Board Notation) Tests

    @Test("FBN: Default position round-trip")
    func testFBNDefaultPosition() throws {
        let game = Game()
        let fbn = game.toFBN()

        let parsedGame = try #require(Game(fromFBN: fbn))
        #expect(parsedGame == game)
        #expect(parsedGame.atMove == game.atMove)
    }

    @Test("FBN: Board state after moves")
    func testFBNAfterMoves() throws {
        var game = Game()

        // Make some moves
        let fromG2 = try #require(Board.parseNotation("G2"))
        let toH3 = try #require(Board.parseNotation("H3"))
        try game.perform(.move(from: fromG2, to: toH3))

        let fromB7 = try #require(Board.parseNotation("B7"))
        let toB6 = try #require(Board.parseNotation("B6"))
        try game.perform(.move(from: fromB7, to: toB6))

        let fbn = game.toFBN()
        let parsedGame = try #require(Game(fromFBN: fbn))

        #expect(parsedGame.board == game.board)
        #expect(parsedGame.atMove == game.atMove)
    }

    @Test("FBN: Documentation example")
    func testFBNDocumentationExample() throws {
        let fbnExample = "+R-4K5P1PHPUP1P3P13pp2pup-4p2frhp5k3"

        let game = try #require(Game(fromFBN: fbnExample))
        let exported = game.toFBN()

        #expect(exported == fbnExample)
    }

    @Test("FBN: Frozen pieces are preserved")
    func testFBNFrozenPieces() throws {
        var game = Game()

        // Make a move to create a frozen piece
        let fromG2 = try #require(Board.parseNotation("G2"))
        let toH3 = try #require(Board.parseNotation("H3"))
        try game.perform(.move(from: fromG2, to: toH3))

        // The piece at H3 should now be frozen
        #expect(game.board[toH3]?.frozen == true)

        let fbn = game.toFBN()
        let parsedGame = try #require(Game(fromFBN: fbn))

        #expect(parsedGame.board[toH3]?.frozen == true)
    }

    // MARK: - FMN (Flang Move Notation) v2 Tests

    @Test("FMN: Empty game")
    func testFMNEmptyGame() throws {
        let game = Game()
        let fmn = try game.toFMN()

        #expect(fmn == "")
    }

    @Test("FMN: Simple moves round-trip")
    func testFMNSimpleMoves() throws {
        var game = Game()

        // Make some moves
        let moves: [(String, String)] = [
            ("G2", "H3"),
            ("B7", "B6"),
            ("F1", "F7"),
        ]

        for (from, to) in moves {
            let fromIdx = try #require(Board.parseNotation(from))
            let toIdx = try #require(Board.parseNotation(to))
            try game.perform(.move(from: fromIdx, to: toIdx))
        }

        let fmn = try game.toFMN()
        let parsedGame = try #require(Game(fromFMN: fmn))

        #expect(parsedGame == game)
    }

    @Test("FMN: Documentation example")
    func testFMNDocumentationExample() throws {
        let fmnExample = "b2 b7a6 Hd3 b2 a1 c2 b2 kb7 c1 he6 f2e3 fb5 g2g3 f7f6 Kg2 h5 g4 kb6 Kg3 h7 h4 pg7 Pg5 hg5 Ug5 h6 Pg3 g5"

        let game = try #require(Game(fromFMN: fmnExample))

        // Verify it parsed without error
        #expect(game.atMove == .white || game.atMove == .black)
    }

    @Test("FMN: Complex game round-trip")
    func testFMNComplexGame() throws {
        var game = Game()

        // Play a longer sequence
        let moves: [(String, String)] = [
            ("G2", "H3"),
            ("B7", "B6"),
            ("F1", "F7"),
            ("D8", "F7"), // Capture
            ("E1", "G2"),
            ("E7", "F6"),
        ]

        for (from, to) in moves {
            let fromIdx = try #require(Board.parseNotation(from))
            let toIdx = try #require(Board.parseNotation(to))
            try game.perform(.move(from: fromIdx, to: toIdx))
        }

        let fmn = try game.toFMN()
        let parsedGame = try #require(Game(fromFMN: fmn))

        #expect(parsedGame == game)
    }

    // MARK: - FMNe (Flang Move Notation Extended) Tests

    @Test("FMNe: Starts with exclamation mark")
    func testFMNeFormat() throws {
        var game = Game()

        let fromG2 = try #require(Board.parseNotation("G2"))
        let toH3 = try #require(Board.parseNotation("H3"))
        try game.perform(.move(from: fromG2, to: toH3))

        let fmne = try game.toFMNe()

        #expect(fmne.first == "!")
    }

    @Test("FMNe: Simple moves round-trip")
    func testFMNeSimpleMoves() throws {
        var game = Game()

        let moves: [(String, String)] = [
            ("G2", "H3"),
            ("B7", "B6"),
        ]

        for (from, to) in moves {
            let fromIdx = try #require(Board.parseNotation(from))
            let toIdx = try #require(Board.parseNotation(to))
            try game.perform(.move(from: fromIdx, to: toIdx))
        }

        let fmne = try game.toFMNe()
        let parsedGame = try #require(Game(fromFMNe: fmne))

        #expect(parsedGame == game)
    }

    @Test("FMNe: Documentation example")
    func testFMNeDocumentationExample() throws {
        let fmneExample = "!acdoarqpbFmhwuvkFmzdJAHkzsAj"

        let game = try #require(Game(fromFMNe: fmneExample))

        // Verify the game was parsed
        #expect(game.atMove == .white || game.atMove == .black)
    }

    @Test("FMNe: Complex game round-trip")
    func testFMNeComplexGame() throws {
        var game = Game()

        // Play multiple moves
        let moves: [(String, String)] = [
            ("G2", "H3"),
            ("B7", "B6"),
            ("F1", "F7"),
            ("D8", "F7"),
            ("E1", "G2"),
            ("E7", "F6"),
            ("C1", "B2"),
        ]

        for (from, to) in moves {
            let fromIdx = try #require(Board.parseNotation(from))
            let toIdx = try #require(Board.parseNotation(to))
            try game.perform(.move(from: fromIdx, to: toIdx))
        }

        let fmne = try game.toFMNe()
        let parsedGame = try #require(Game(fromFMNe: fmne))

        #expect(parsedGame == game)
    }

    @Test("FMNe: Shorter than FMN")
    func testFMNeShorterThanFMN() throws {
        var game = Game()

        // Play several moves
        for _ in 0..<10 {
            let legalActions = game.legalActions()
            if let action = legalActions.first {
                try game.perform(action)
            }
        }

        let fmn = try game.toFMN()
        let fmne = try game.toFMNe()

        // FMNe should generally be shorter (excluding the "!" prefix)
        #expect(fmne.count <= fmn.count)
    }

    // MARK: - Cross-format Tests

    @Test("All formats produce equivalent games")
    func testAllFormatsEquivalent() throws {
        var game = Game()

        // Play some moves
        let moves: [(String, String)] = [
            ("G2", "H3"),
            ("B7", "B6"),
            ("F1", "F7"),
        ]

        for (from, to) in moves {
            let fromIdx = try #require(Board.parseNotation(from))
            let toIdx = try #require(Board.parseNotation(to))
            try game.perform(.move(from: fromIdx, to: toIdx))
        }

        // Export to all formats
        let fbn = game.toFBN()
        let fmn = try game.toFMN()
        let fmne = try game.toFMNe()

        // Parse from all formats
        let gameFromFBN = try #require(Game(fromFBN: fbn))
        let gameFromFMN = try #require(Game(fromFMN: fmn))
        let gameFromFMNe = try #require(Game(fromFMNe: fmne))

        // FBN only preserves board state, not history
        #expect(gameFromFBN.board == game.board)
        #expect(gameFromFBN.atMove == game.atMove)

        // FMN and FMNe should preserve full game state
        #expect(gameFromFMN == game)
        #expect(gameFromFMNe == game)
    }

    // MARK: - Edge Cases

    @Test("FBN: Invalid notation returns nil")
    func testFBNInvalidNotation() {
        #expect(Game(fromFBN: "") == nil)
        #expect(Game(fromFBN: "invalid") == nil)
        #expect(Game(fromFBN: "+XYZ") == nil)
    }

    @Test("FMN: Invalid notation returns nil")
    func testFMNInvalidNotation() {
        #expect(Game(fromFMN: "invalid notation xyz") == nil)
        #expect(Game(fromFMN: "z9z9") == nil)
    }

    @Test("FMNe: Invalid notation returns nil")
    func testFMNeInvalidNotation() {
        #expect(Game(fromFMNe: "abc") == nil) // Doesn't start with !
        #expect(Game(fromFMNe: "!") == nil) // Empty after !
    }

    @Test("FMN: Resignation is encoded")
    func testFMNResignation() throws {
        var game = Game()

        // Make a move
        let fromG2 = try #require(Board.parseNotation("G2"))
        let toH3 = try #require(Board.parseNotation("H3"))
        try game.perform(.move(from: fromG2, to: toH3))

        // Resign
        try game.perform(.resign(color: .black))

        let fmn = try game.toFMN()

        // Should contain resignation notation
        #expect(fmn.contains("#-"))
    }
}
