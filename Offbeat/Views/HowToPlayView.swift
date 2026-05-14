import SwiftUI

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            OB.Color.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("How to Play")
                        .font(.system(size: 34, weight: .bold))
                        .tracking(-0.5)
                        .foregroundStyle(OB.Color.text)
                        .padding(.top, 12)

                    section(
                        title: "THE SETUP",
                        body: "One player is secretly the Impostor. Everyone else gets the same hidden theme — a vibe, mood, or situation. Your job: pick a song that fits without making it too obvious."
                    )
                    section(
                        title: "THE IMPOSTOR",
                        body: "You don't know the theme. Pick any song and try to blend in. If no one suspects you, you win."
                    )
                    section(
                        title: "THE ROUND",
                        body: "Everyone sees their role privately, then follows the play order to play their song out loud one by one. After listening, discuss as a group — then hit Reveal to find out if you were right."
                    )
                    section(
                        title: "WINNING",
                        body: "Catch the Impostor and you win. Impostor — just don't get caught."
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .tracking(2.5)
                .foregroundStyle(OB.Color.accent)
            Text(body)
                .font(.system(size: 16))
                .foregroundStyle(OB.Color.text)
                .lineSpacing(4)
        }
    }
}
