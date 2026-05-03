import SwiftUI

public struct PrivacyAboutView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your pages are stored locally on your Mac.")
            Text("Mental Compost does not create an account, sync to a server, or send analytics.")
            Text("Local model features only talk to the endpoint you configure.")
            Text("Nothing becomes AI context unless you export it.")
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }
}
