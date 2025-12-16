import SwiftUI

public struct StatBoxLabeledContentStyle: LabeledContentStyle {
    
    @Environment(\.fontResolutionContext) private var fontContext
    
    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 4) {
            configuration.content
                .font(.title3.bold())
                .frame(height: Font.title3.resolve(in: fontContext).pointSize * 1.2)
            configuration.label
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(height: Font.caption.resolve(in: fontContext).pointSize * 1.2)
        }
        .lineHeight(.multiple(factor: 1.2))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .padding(.horizontal, 8)
        .background()
        .clipShape(.rect(corners: .concentric(minimum: 16), isUniform: true))
    }
}

public extension LabeledContentStyle where Self == StatBoxLabeledContentStyle {
    static var statBox: Self { .init() }
}

struct Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 12) {
            LabeledContent("Bullet", value: "1630")
            LabeledContent("Blitz", value: "1630")
            LabeledContent("Classical", value: "1630")
            LabeledContent("Daily", value: "1630")
            LabeledContent("Puzzle", value: "1630?")
        }
        .labeledContentStyle(.statBox)
        .backgroundStyle(.background.secondary)
        .containerShape(.rect)
        .padding()
    }
}
