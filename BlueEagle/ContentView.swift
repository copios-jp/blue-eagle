import SwiftUI

enum Routes: String, CaseIterable, Hashable {
  case Settings
  case Devices
}

@MainActor internal struct ContentView: View {
  internal var body: some View {
    NavigationStack {
      VStack {
        TrainingScreen()
          .environment(ProgrammableTimer())
          .padding()

      }
      .toolbar {
        ToolbarItemGroup {
          NavigationLink(value: Routes.Devices) {
            AppStatusView()
          }
          Spacer()
          NavigationLink(value: Routes.Settings) {
            Image(systemName: "person.fill")
              .foregroundColor(.primary)

          }
        }
      }
      .navigationDestination(for: Routes.self) { screen in
        switch screen {
        case .Settings:
          SettingsScreen()
        case .Devices:
          DevicesScreen()
        }
      }

    }
    .preferredColorScheme(.dark)
  }
}

@MainActor internal struct ContentView_Previews: PreviewProvider {
  internal static var previews: some View {
    ContentView()
  }
}
