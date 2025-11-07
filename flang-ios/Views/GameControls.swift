import SwiftUI

struct GameControls: View {
    
    let isFirstPlayerPerspective: Bool
    let backEnabled: Bool
    let forwardEnabled: Bool
    let closeAction: () -> Void
    let shareAction: () -> Void
    let rotateBoardAction: () -> Void
    let backwardAction: () -> Void
    let forwardAction: () -> Void
    
    var body: some View {
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
                        Button("backward", systemImage: "chevron.backward", action: backwardAction).disabled(!backEnabled)
                        Button("forward", systemImage: "chevron.forward", action: forwardAction).disabled(!forwardEnabled)
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
