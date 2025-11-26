import FlangModel
import FlangOnline
import FlangUI
import SwiftUI

public struct ActiveGameRow: View {
    
    private let game: OnlineGameInfo
    
    public init(game: OnlineGameInfo) {
        self.game = game
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    playerView(game.white, alignment: .leading)
                    Text("vs").font(.subheadline).foregroundStyle(.secondary)
                    playerView(game.black, alignment: .trailing)
                }
                HStack {
                    Group {
                        Circle().frame(width: 8, height: 8)
                        Text(game.running ? "In Progress" : "Finished")
                    }
                    .foregroundStyle(game.running ? .green : .gray)
                    Spacer()
                    Text("Moves: \(game.moves)").foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func playerView(_ playerInfo: PlayerInfo, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            UserLabel(playerInfo: playerInfo)
                .font(.body)
                .font(.subheadline)
            RatingLabel(rating: playerInfo.rating, ratingDifference: playerInfo.ratingDifference)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .init(horizontal: alignment, vertical: .center))
    }
}

struct ActiveGameRowPreviews: PreviewProvider {
    static var previews: some View {
        List {
            ActiveGameRow(game: PreviewInstances.runningOnlineGameInfo)
            ActiveGameRow(game: PreviewInstances.finishedOnlineGameInfo)
        }
    }
}
