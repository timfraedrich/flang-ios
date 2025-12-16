import FlangModel
import FlangUI
import SwiftUI

struct TutorialScene: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var stepIndex: Int = 0
    @State private var gameState: GameState = .init()
    @State private var confirmClose: Bool = false
    
    private var canUndo: Bool { gameState.backEnabled }
    private var isLastStep: Bool { stepIndex == steps.count - 1 }
    
    private let steps: [TutorialStep] = [
        .init(
            title: .init(localized: "tutorial_introduction_title"),
            description: .init(localized: "tutorial_introduction_description"),
            prompt: .init(localized: "tutorial_introduction_prompt"),
            initialBoard: .defaultPosition(),
            objective: .none,
            interactionDisabled: true
        ),
        .init(
            title: .init(localized: "tutorial_king_title"),
            description: .init(localized: "tutorial_king_description"),
            prompt: .init(localized: "tutorial_king_prompt"),
            initialBoard: .init(fromFBNPieces: "12K22k")!,
            objective: .claimPosition(.white, .init(algebraic: "D5")!)
        ),
        .init(
            title: .init(localized: "tutorial_rook_title"),
            description: .init(localized: "tutorial_rook_description"),
            prompt: .init(localized: "tutorial_rook_prompt"),
            initialBoard: .init(fromFBNPieces: "7R50r")!,
            objective: .claimPosition(.white, .init(algebraic: "C8")!)
        ),
        .init(
            title: .init(localized: "tutorial_horse_title"),
            description: .init(localized: "tutorial_horse_description"),
            prompt: .init(localized: "tutorial_horse_prompt"),
            initialBoard: .init(fromFBNPieces: "27H22h")!,
            objective: .claimPosition(.white, .init(algebraic: "C7")!)
        ),
        .init(
            title: .init(localized: "tutorial_uni_title"),
            description: .init(localized: "tutorial_uni_description"),
            prompt: .init(localized: "tutorial_uni_prompt"),
            initialBoard: .init(fromFBNPieces: "26U18u")!,
            objective: .claimPosition(.white, .init(algebraic: "F6")!)
        ),
        .init(
            title: .init(localized: "tutorial_flanger_title"),
            description: .init(localized: "tutorial_flanger_description"),
            prompt: .init(localized: "tutorial_flanger_prompt"),
            initialBoard: .init(fromFBNPieces: "30F2f1P")!,
            objective: .claimPosition(.white, .init(algebraic: "B5")!)
        ),
        .init(
            title: .init(localized: "tutorial_pawn_title"),
            description: .init(localized: "tutorial_pawn_description"),
            prompt: .init(localized: "tutorial_pawn_prompt"),
            initialBoard: .init(fromFBNPieces: "12P22p")!,
            objective: .claimPosition(.white, .init(algebraic: "D5")!)
        ),
        .init(
            title: .init(localized: "tutorial_pawn_promotion_title"),
            description: .init(localized: "tutorial_pawn_promotion_description"),
            prompt: .init(localized: "tutorial_pawn_promotion_prompt"),
            initialBoard: .init(fromFBNPieces: "35p15P")!,
            objective: .claimPosition(.white, .init(algebraic: "D5")!)
        ),
        .init(
            title: .init(localized: "tutorial_freeze_title"),
            description: .init(localized: "tutorial_freeze_description"),
            prompt: .init(localized: "tutorial_freeze_prompt"),
            initialBoard: .init(fromFBNPieces: "10PPP1F15p31k")!,
            objective: .claimPosition(.white, .init(algebraic: "G8")!),
            freezePieces: true
        ),
        .init(
            title: .init(localized: "tutorial_winning_other_side_title"),
            description: .init(localized: "tutorial_winning_other_side_description"),
            prompt: .init(localized: "tutorial_winning_other_side_prompt"),
            initialBoard: .init(fromFBNPieces: "47Kpppppp2kufhrp")!,
            objective: .reachOtherSide
        ),
        .init(
            title: .init(localized: "tutorial_winning_capture_title"),
            description: .init(localized: "tutorial_winning_capture_description"),
            prompt: .init(localized: "tutorial_winning_capture_prompt"),
            initialBoard: .init(fromFBNPieces: "20U6K13p6p1pppp2kufhrp")!,
            objective: .captureKing,
            freezePieces: true
        ),
        .init(
            title: .init(localized: "tutorial_final_title"),
            description: .init(localized: "tutorial_final_description"),
            prompt: .init(localized: "tutorial_final_prompt"),
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

                    Text(gameState.winner == nil ? step.prompt : .init(localized: "tutorial_well_done"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 20)

                    HStack {
                        if !step.interactionDisabled, canUndo {
                            Button(action: undo) {
                                HStack {
                                    Text("undo")
                                    Image(systemName: "arrow.uturn.backward")
                                }
                            }
                            .buttonStyle(.glass)
                        }
                        Spacer()
                        Button(action: nextOrFinish) {
                            HStack {
                                Text(isLastStep ? "finish" : "next")
                                if !isLastStep {
                                    Image(systemName: "chevron.forward")
                                }
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
        .interactiveDismissDisabled()
        .padding(.horizontal, 20)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel, action: attemptClose)
                    .confirmationDialog("skip_tutorial", isPresented: $confirmClose) {
                        Button("skip_tutorial", role: .destructive, action: finish)
                    } message: {
                        Text("skip_tutorial_confirmation")
                    }
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
    
    private func nextOrFinish() {
        if stepIndex < steps.count - 1 {
            stepIndex += 1
        } else {
            finish()
        }
    }
    
    private func undo() {
        try? gameState.back()
    }
    
    private func attemptClose() {
        if UserDefaults.standard.hasFinishedTutorial {
            dismiss()
        } else {
            confirmClose = true
        }
    }
    
    private func finish() {
        UserDefaults.standard.hasFinishedTutorial = true
        dismiss()
    }
    
    private struct TutorialStep {
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
