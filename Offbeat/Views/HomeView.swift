import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var showHowToPlay = false

    var body: some View {
        ZStack {
            OB.Color.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("A PARTY GAME")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(2.5)
                    .foregroundStyle(OB.Color.faint)
                    .padding(.top, 8)

                Spacer().frame(height: 0)

                VStack(alignment: .leading, spacing: 18) {
                    Spacer()
                    // Accent dot above the "O"
                    Circle()
                        .fill(OB.Color.accent)
                        .frame(width: 10, height: 10)
                        .padding(.leading, 8)

                    Text("Offbeat")
                        .font(.system(size: 76, weight: .bold))
                        .tracking(-2)
                        .foregroundStyle(OB.Color.text)

                    Text("One theme. One faker.\nCan you hear it?")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(OB.Color.muted)
                        .lineSpacing(2)
                }

                Spacer()

                HStack(spacing: 8) {
                    Circle()
                        .fill(OB.Color.accent)
                        .frame(width: 7, height: 7)
                    Text("3–10 players · one phone")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(OB.Color.muted)
                }
                .padding(.vertical, 9)
                .padding(.horizontal, 14)
                .background(Capsule().fill(OB.Color.surface))
                .overlay(Capsule().stroke(OB.Color.border, lineWidth: 1))
                .padding(.bottom, 16)

                PrimaryButton(title: "Start Game") {
                    vm.goToSetup()
                }

                Button {
                    showHowToPlay = true
                } label: {
                    Text("How to Play")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(OB.Color.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                        .padding(.bottom, 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .sheet(isPresented: $showHowToPlay) {
            HowToPlayView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
