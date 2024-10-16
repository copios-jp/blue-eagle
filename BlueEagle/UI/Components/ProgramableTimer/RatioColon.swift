import SwiftUI

struct RatioColon: View {
  var fontSize: CGFloat = 80

  var body: some View {
    VStack(alignment: .center, spacing: fontSize * 0.3) {
      Circle()
        .frame(width: fontSize * 0.1, height: fontSize * 0.1)
      Circle()
        .frame(width: fontSize * 0.1, height: fontSize * 0.1)
    }
    .frame(width: fontSize * 0.1, height: fontSize * 0.5)
  }
}
