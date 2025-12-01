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
                            Button(action: closeAction) {
                                Label {
                                    Text("game_controls_close", bundle: .module)
                                } icon: {
                                    Image(systemName: "xmark")
                                }
                            }
                            Button(action: shareAction) {
                                Label {
                                    Text("game_controls_share", bundle: .module)
                                } icon: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal, 4)
                }
                Spacer()
                HStack {
                    Group {
                        Button(action: rotateBoardAction) {
                            Label {
                                Text("game_controls_rotate_board", bundle: .module)
                            } icon: {
                                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                            }
                        }
                        Group {
                            Button(action: backwardAction) {
                                Label {
                                    Text("game_controls_backward", bundle: .module)
                                } icon: {
                                    Image(systemName: "chevron.backward")
                                }
                            }.disabled(!backEnabled)
                            Button(action: forwardAction) {
                                Label {
                                    Text("game_controls_forward", bundle: .module)
                                } icon: {
                                    Image(systemName: "chevron.forward")
                                }
                            }.disabled(!forwardEnabled)
                        }
                        .buttonRepeatBehavior(.enabled)
                        if let resignAction {
                            Button(action: resignAction) {
                                Label {
                                    Text("game_controls_resign", bundle: .module)
                                } icon: {
                                    Image(systemName: "flag.fill")
                                }
                            }.disabled(!canResign).tint(.red)
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
