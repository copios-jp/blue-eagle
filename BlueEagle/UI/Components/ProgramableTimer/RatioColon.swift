import SwiftUI

struct RatioColon: View {
    var fontSize: CGFloat
    
    var body: some View {
        VStack(alignment: .center, spacing: fontSize * 0.3) { // Adjust spacing based on your font size
            Circle()
                .frame(width: fontSize * 0.1, height: fontSize * 0.1) // Adjust dot size based on your font size
            Circle()
                .frame(width: fontSize * 0.1, height: fontSize * 0.1)
        }
        .frame(width: fontSize * 0.1, height: fontSize) // Adjust the frame to fit your layout
    }
}
