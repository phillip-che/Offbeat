import SwiftUI

struct PlayOrderView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        ZStack {
            OB.Color.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("ROUND")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(2.5)
                    .foregroundStyle(OB.Color.faint)
                    .padding(.top, 4)

                Text("Play Order")
                    .font(.system(size: 40, weight: .bold))
                    .tracking(-1)
                    .foregroundStyle(OB.Color.text)
                    .padding(.top, 6)

                Text("Follow this order to play your songs. Discuss after, then reveal.")
                    .font(.system(size: 16))
                    .foregroundStyle(OB.Color.muted)
                    .padding(.top, 10)
                    .lineSpacing(2)

                VStack(spacing: 12) {
                    if let players = vm.session?.playOrder {
                        ForEach(Array(players.enumerated()), id: \.element.id) { idx, p in
                            row(index: idx + 1, player: p)
                        }
                    }
                }
                .padding(.top, 24)

                Spacer()

                PrimaryButton(title: "Reveal the Impostor", trailingChevron: true) {
                    vm.goToReveal()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .navigationBarBackButtonHidden()
    }

    private func row(index: Int, player: Player) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(player.color.color)
                    .frame(width: 32, height: 32)
                Text("\(index)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(OB.Color.bg)
            }
            Text(player.name)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(OB.Color.text)
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(OB.Color.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(OB.Color.border, lineWidth: 1)
        )
    }
}
