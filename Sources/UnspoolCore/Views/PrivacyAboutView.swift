import SwiftUI

public struct PrivacyAboutView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your pages are stored locally on your Mac.")
            Text("Unspool does not create an account, sync to a server, or send analytics.")
            Text("You choose where Markdown pages are saved.")
            Text("Experimental export features only run when you choose to use them.")
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }
}
