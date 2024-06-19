import Foundation
import SwiftUI


// MARK: - MagicLinkConfirmationView
//
struct MagicLinkConfirmationView: View {
    
    @State var displaysInvalidLink = false
    
    var onDismissRequest: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            if displaysInvalidLink {
                invalidLinkText
                invalidLinkButton
            } else {
                authorizingText
                progressIndicator
            }
        }
        .padding()
        .background(.white)
        .frame(width: 380, height: 200, alignment: .center)
        .onReceive(NotificationCenter.default.publisher(for: .magicLinkAuthDidFail)) { _ in
            displaysInvalidLink = true
        }
    }
    
    private var authorizingText: some View {
        Text("Logging In...")
            .font(.title3)
            .foregroundColor(.gray)
    }
    
    private var progressIndicator: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .controlSize(.small)
    }
    
    private var invalidLinkText: some View {
        Text("Link was no longer valid")
            .font(.title3)
            .foregroundColor(.gray)
    }
    
    private var invalidLinkButton: some View {
        SwiftUI.Button(action: switchToAuthenticationUI) {
            Text("Accept")
                .fontWeight(.bold)
                .foregroundStyle(Color(nsColor: .simplenoteBrandColor))
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func switchToAuthenticationUI() {
        onDismissRequest?()
    }
}
