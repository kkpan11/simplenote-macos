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
        VStack(alignment: .center, spacing: Metrics.stackSpacing) {
            Image(systemName: MagicLinkImages.mail)
                .renderingMode(.template)
                .font(.system(size: Metrics.titleFontSize))
                .foregroundColor(Color(nsColor: .simplenoteBrandColor))
                .scaleEffect(displaysFullImage ? AnimationSettings.scaleEffectFull : AnimationSettings.scaleEffectReduced)
                .onAppear {
                    withAnimation(.spring(response: AnimationSettings.response, dampingFraction: AnimationSettings.dampingFactor)) {
                        displaysFullImage = true
                    }
                }
                .padding(.bottom, Metrics.imagePaddingBottom)
                .padding(.top, Metrics.imagePaddingTop)

            Text("Check your email")
                .bold()
                .font(.title)
                .padding(.bottom, Metrics.titlePaddingBottom)
                        
            Text("If an account exists, we've sent an email with a link that'll log you in to **\(emailLengthLimited)**")
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

        .frame(width: Metrics.maximumWidth)
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
    static let stackSpacing: CGFloat = 10
    static let imagePaddingTop: CGFloat = 20
    static let imagePaddingBottom: CGFloat = 10
    static let titlePaddingBottom: CGFloat = 10
    static let titleFontSize: CGFloat = 48
    static let buttonPaddingBottom: CGFloat = 30
    static let maximumEmailLength = 100
    static let maximumWidth: CGFloat = 380
}

private enum AnimationSettings {
    static let scaleEffectFull: CGFloat = 1
    static let scaleEffectReduced: CGFloat = 0.4
    static let response: Double = 0.3
    static let dampingFactor: Double = 0.3
}

private enum MagicLinkImages {
    static let mail = "envelope.fill"
}


struct MagicLinkConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        MagicLinkRequestedView(email: "lord@yosemite.com")
    }
}
