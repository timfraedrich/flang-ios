import SwiftUI

public struct GameControls: View {

    private let isFirstPlayerPerspective: Bool
    private let backEnabled: Bool
    private let forwardEnabled: Bool
    private let closeAction: () -> Void
    private let shareAction: () -> Void
    private let rotateBoardAction: () -> Void
    private let backwardAction: () -> Void
    private let forwardAction: () -> Void
    private let resignAction: (() -> Void)?
    private let canResign: Bool
    
    public init(
        isFirstPlayerPerspective: Bool,
        backEnabled: Bool,
        forwardEnabled: Bool,
        closeAction: @escaping () -> Void,
        shareAction: @escaping () -> Void,
        rotateBoardAction: @escaping () -> Void,
        backwardAction: @escaping () -> Void,
        forwardAction: @escaping () -> Void,
        resignAction: (() -> Void)? = nil,
        canResign: Bool = false
    ) {
        self.isFirstPlayerPerspective = isFirstPlayerPerspective
        self.backEnabled = backEnabled
        self.forwardEnabled = forwardEnabled
        self.closeAction = closeAction
        self.shareAction = shareAction
        self.rotateBoardAction = rotateBoardAction
        self.backwardAction = backwardAction
        self.forwardAction = forwardAction
        self.resignAction = resignAction
        self.canResign = canResign
    }
    
    public var body: some View {
        HStack {
            Group {
                if isFirstPlayerPerspective {
                    HStack {
                        Group {
                            Button("close", systemImage: "xmark", action: closeAction)
                            Button("share", systemImage: "square.and.arrow.up", action: shareAction)
                        }
                        .padding()
                    }
                    .padding(.horizontal, 4)
                }
                Spacer()
                HStack {
                    Group {
                        Button("rotate board", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90", action: rotateBoardAction)
                        Group {
                            Button("backward", systemImage: "chevron.backward", action: backwardAction).disabled(!backEnabled)
                            Button("forward", systemImage: "chevron.forward", action: forwardAction).disabled(!forwardEnabled)
                        }
                        .buttonRepeatBehavior(.enabled)
                        if let resignAction {
                            Button("resign", systemImage: "flag.fill", action: resignAction).disabled(!canResign).tint(.red)
                        }
                    }
                    .padding()
                }
                .padding(.horizontal, 4)
            }
            .labelStyle(.iconOnly)
            .glassEffect(.regular.interactive(), in: .capsule)
        }
        .tint(.primary)
        .controlSize(.large)
    }
}
