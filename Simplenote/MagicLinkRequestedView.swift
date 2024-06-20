import Foundation
import SwiftUI


// MARK: - MagicLinkConfirmationView
//
struct MagicLinkRequestedView: View {

    @State private var displaysFullImage: Bool = false
    let email: String
    var onDismissRequest: (() -> Void)?

    
    private var emailLengthLimited: String {
        guard email.count > Metrics.maximumEmailLength else {
            return email
        }
        
        return String(email.prefix(Metrics.maximumEmailLength)) + "..."
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: MagicLinkImages.mail)
                .renderingMode(.template)
                .font(.system(size: 48))
                .foregroundColor(Color(nsColor: .simplenoteBrandColor))
                .scaleEffect(displaysFullImage ? 1 : 0.4)
                .onAppear {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                        displaysFullImage = true
                    }
                }
                .padding(.bottom, Metrics.imagePaddingBottom)
                .padding(.top, Metrics.imagePaddingTop)

            Text("Check your email")
                .bold()
                .font(.title)
                .padding(.bottom, Metrics.titlePaddingBottom)
                        
            Text("If an account exists, we've sent an email to **\(emailLengthLimited)** containing a link that'll log you in.")
                .font(.title3)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding()
            
            SwiftUI.Button(action: switchToAuthenticationUI) {
                Text("Go Back")
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
            .padding(.bottom, Metrics.buttonPaddingBottom)
        }

        .frame(width: 380)
        .fixedSize()

        /// Force Light Mode (since the Authentication UI is all light!)
        .environment(\.colorScheme, .light)
    }
    
    func switchToAuthenticationUI() {
        onDismissRequest?()
    }
}



// MARK: - Constants
//
private enum Metrics {
    static let imagePaddingTop: CGFloat = 20
    static let imagePaddingBottom: CGFloat = 10
    static let titlePaddingBottom: CGFloat = 10
    static let buttonPaddingBottom: CGFloat = 30
    static let maximumEmailLength = 100
}

private enum MagicLinkImages {
    static let mail = "envelope.fill"
}


struct MagicLinkConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        MagicLinkRequestedView(email: "lord@yosemite.com")
    }
}
