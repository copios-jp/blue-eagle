import SwiftUI

struct TrainingScreen: View {
  var body: some View {
    ViewThatFits {
      HStack(alignment: .center) {
        TrainingZoneView(strokeWidth: 35)
        ProgrammableTimerView(fontSize: 160)
      }

      VStack(alignment: .center) {
        TrainingZoneView(strokeWidth: 35)
        ProgrammableTimerView(fontSize: 130)
        Spacer()
      }
    }
  }
}

#Preview {
  TrainingScreen()
    .environment(ProgrammableTimer())
}
