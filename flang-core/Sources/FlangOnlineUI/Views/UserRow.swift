import FlangOnline
import SwiftUI

public struct UserRow: View {
    
    private let user: UserInfo
    private let rank: Int?
    
    public init(user: UserInfo, rank: Int? = nil) {
        self.user = user
        self.rank = rank
    }

    public var body: some View {
        HStack(spacing: 16) {
            rankOrIcon
            userInfoView
            Spacer()
            optionalTrophy
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder private var rankOrIcon: some View {
        Group {
            if let rank {
                Image(systemName: rank.description)
            } else {
                Image(systemName: user.isBot ? "cpu" : "person")
            }
        }
        .font(.system(size: 40))
        .symbolVariant(.circle.fill)
        .foregroundStyle(color)
        .frame(width: 48)
    }
    
    @ViewBuilder private var userInfoView: some View {
        UserInfoView(userInfo: user, alignment: .leading)
    }
    
    @ViewBuilder private var optionalTrophy: some View {
        if let rank, let icon = medalIcon(rank: rank) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
        }
    }

    private var color: Color {
        guard let rank else { return user.isBot ? .blue : .gray }
        return switch rank {
        case 1: .yellow
        case 2: Color(red: 0.75, green: 0.75, blue: 0.75)
        case 3: Color(red: 0.8, green: 0.5, blue: 0.2)
        default: .blue
        }
    }

    private func medalIcon(rank: Int) -> String? {
        switch rank {
        case 1...3: "medal.fill"
        default: nil
        }
    }
}
