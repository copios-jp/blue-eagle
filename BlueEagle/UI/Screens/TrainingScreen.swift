import SwiftUI

struct TrainingScreen: View {
  var body: some View {
    GeometryReader { geometry in
      ViewThatFits {
        HStack(alignment: .center) {
          TrainingZoneView(lineWidth: 30)
          ProgrammableTimerView(fontSize: 160)
        }
        VStack(alignment: .center) {
          TrainingZoneView(lineWidth: 35)
          ProgrammableTimerView(fontSize: 130)
                .frame(height: geometry.size.height / 2.25)

        }
      }
    }
  }
}

#Preview {
  TrainingScreen()
    .environment(ProgrammableTimer())
}
