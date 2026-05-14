import SwiftUI

struct ProgressDots: View {
    let total: Int
    let current: Int  // 0-indexed

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                if i == current {
                    Capsule()
                        .fill(OB.Color.accent)
                        .frame(width: 20, height: 6)
                } else {
                    Circle()
                        .fill(i < current ? OB.Color.accent.opacity(0.55) : OB.Color.border)
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}
