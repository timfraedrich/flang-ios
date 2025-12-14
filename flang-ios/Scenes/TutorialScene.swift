import FlangModel
import FlangUI
import SwiftUI

struct TutorialScene: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var stepIndex: Int = 10
    @State private var gameState: GameState = .init()
    
    var canUndo: Bool { gameState.backEnabled }
    var isLastStep: Bool { stepIndex == steps.count - 1 }
    
    let steps: [TutorialStep] = [
        .init(
            title: "Introduction",
            description: "This tutorial aims to explain the basic rules of Flang, a turn based game, simmilar to chess. This is the initial board.",
            prompt: "To continue press the next button.",
            initialBoard: .defaultPosition(),
            objective: .none,
            interactionDisabled: true
        ),
        .init(
            title: "The King",
            description: "Let's start by learning how pieces move. The king can move one square in any direction.",
            prompt: "Capture the enemy king!",
            initialBoard: .init(fromFBNPieces: "12K22k")!,
            objective: .claimPosition(.white, .init(algebraic: "D5")!)
        ),
        .init(
            title: "The Rook",
            description: "The rook can move horizontally and vertically any number of squares until there is a piece in the way.",
            prompt: "Capture the enemy rook!",
            initialBoard: .init(fromFBNPieces: "7R50r")!,
            objective: .claimPosition(.white, .init(algebraic: "C8")!)
        ),
        .init(
            title: "The Horse",
            description: "The horse can jump two squares in one and then one square in the other direction.",
            prompt: "Capture the enemy horse!",
            initialBoard: .init(fromFBNPieces: "27H22h")!,
            objective: .claimPosition(.white, .init(algebraic: "C7")!)
        ),
        .init(
            title: "The Uni",
            description: "The uni can move horizontally, vertically, and diagonally any number of squares, until the path is blocked by a piece. It can also jump like a horse.",
            prompt: "Capture the enemy uni!",
            initialBoard: .init(fromFBNPieces: "26U18u")!,
            objective: .claimPosition(.white, .init(algebraic: "F6")!)
        ),
        .init(
            title: "The Flanger",
            description: "The flanger moves in a zig-zack fashion horizontally and vertically until blocked by another piece. It can therefore only be on white squares.",
            prompt: "Capture the enemy flanger!",
            initialBoard: .init(fromFBNPieces: "30F2f1P")!,
            objective: .claimPosition(.white, .init(algebraic: "B5")!)
        ),
        .init(
            title: "The Pawn",
            description: "The pawn moves and takes pieces in the forward direction.",
            prompt: "Capture the enemy pawn!",
            initialBoard: .init(fromFBNPieces: "12P22p")!,
            objective: .claimPosition(.white, .init(algebraic: "D5")!)
        ),
        .init(
            title: "Pawn Promotion",
            description: "A pawn can be promoted to a uni, when it reaches the end of the board.",
            prompt: "Capture the enemy pawn after promoting yours!",
            initialBoard: .init(fromFBNPieces: "35p15P")!,
            objective: .claimPosition(.white, .init(algebraic: "D5")!)
        ),
        .init(
            title: "Freeze Mechanism",
            description: "In Flang a piece is frozen for one turn, after you move it. This does not apply to your king.",
            prompt: "Capture the enemy king!",
            initialBoard: .init(fromFBNPieces: "10PPP1F15p31k")!,
            objective: .claimPosition(.white, .init(algebraic: "G8")!),
            freezePieces: true
        ),
        .init(
            title: "Winning - Other Side",
            description: "There are two ways to win a game of Flang. The first is reaching the opponent's side of the board.",
            prompt: "Win by reaching the other side!",
            initialBoard: .init(fromFBNPieces: "47Kpppppp2kufhrp")!,
            objective: .reachOtherSide
        ),
        .init(
            title: "Winning - Capture",
            description: "The second way to win a game of Flang is by capturing the oppenents King.",
            prompt: "Win by capturing the enemy king!",
            initialBoard: .init(fromFBNPieces: "20U6K13p6p1pppp2kufhrp")!,
            objective: .captureKing,
            freezePieces: true
        ),
        .init(
            title: "Have Fun!",
            description: "Now that you know the basic rules of Flang, have fun playing your first game!",
            prompt: "Close the tutorial using the finish button.",
            initialBoard: .defaultPosition(),
            objective: .none,
            interactionDisabled: true
        ),
    ]
    
    var body: some View {
        GeometryReader { proxy in
            let step = steps[stepIndex]
            VStack(spacing: 20) {
                
                VStack(spacing: 10) {
                    Text(step.title).font(.title.weight(.bold))
                    Text(step.description).minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 20)
                
                BoardView(gameState: gameState, perspective: .singlePlayerWhite)
                    .backgroundStyle(.background.secondary)
                    .frame(width: proxy.size.width, height: proxy.size.width)
                    .disabled(step.interactionDisabled || gameState.winner != nil)
                
                VStack(spacing: .zero) {
                    
                    Text(gameState.winner == nil ? step.prompt : "Well done!")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        if !step.interactionDisabled, canUndo {
                            Button(action: undo) {
                                HStack {
                                    Text("Undo")
                                    Image(systemName: "arrow.uturn.backward")
                                }
                            }
                            .buttonStyle(.glass)
                        }
                        Spacer()
                        Button(action: nextOrFinish) {
                            HStack {
                                Text(isLastStep ? "Finish" : "Next")
                                Image(systemName: "chevron.forward")
                            }
                        }
                        .buttonStyle(.glassProminent)
                        .controlSize(.extraLarge)
                        .disabled(step.objective != .none && gameState.winner == nil)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    
                }
                
                .frame(maxHeight: .infinity)
                .bold()
            }
            .multilineTextAlignment(.center)
            
            .padding(.top, max(proxy.safeAreaInsets.top, 20))
            .padding(.bottom, max(proxy.safeAreaInsets.bottom, 20))
            .ignoresSafeArea()
        }
        .padding(.horizontal, 20)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel, action: dismiss.callAsFunction)
            }
        }
        .onChange(of: stepIndex, initial: true) { _, newValue in
            let step = steps[stepIndex]
            gameState = .init(game: .init(
                board: step.initialBoard,
                objective: step.objective,
                atMove: .white,
                takeTurns: false,
                freezePieces: step.freezePieces
            ))
        }
    }
    
    func nextOrFinish() {
        if stepIndex < steps.count - 1 {
            stepIndex += 1
        } else {
            dismiss()
        }
    }
    
    func undo() {
        try? gameState.back()
    }
    
    struct TutorialStep {
        let title: String
        let description: String
        let prompt: String
        let initialBoard: Board
        let objective: GameObjective
        let freezePieces: Bool
        let interactionDisabled: Bool
        
        init(
            title: String,
            description: String,
            prompt: String,
            initialBoard: Board,
            objective: GameObjective,
            freezePieces: Bool = false,
            interactionDisabled: Bool = false
        ) {
            self.title = title
            self.description = description
            self.prompt = prompt
            self.initialBoard = initialBoard
            self.objective = objective
            self.freezePieces = freezePieces
            self.interactionDisabled = interactionDisabled
        }
    }
}

#Preview {
    NavigationStack {
        TutorialScene()
    }
}
