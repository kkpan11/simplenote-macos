import Foundation
import SwiftUI


// MARK: - MagicLinkConfirmationView
//
struct MagicLinkRequestedView: View {
    
    let email: String
    var onDismissRequest: (() -> Void)?
    

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: MagicLinkImages.mail)
                .renderingMode(.template)
                .font(.system(size: 48))
                .foregroundColor(Color(nsColor: .simplenoteBrandColor))

            Spacer()
                .frame(height: Metrics.imagePaddingBottom)

            Text("Check your email")
                .bold()
                .font(.title)
            
            Spacer()
                .frame(height: Metrics.titlePaddingBottom)
            
            Text("If an account exists, we've sent an email to **\(email)** containing a link that'll log you in.")
                .font(.title3)
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
        }
        .frame(width: 380, height: 400)
        
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
    static let imagePaddingBottom: CGFloat = 10
    static let titlePaddingBottom: CGFloat = 10
}

private enum MagicLinkImages {
    static let mail = "envelope.fill"
}


struct MagicLinkConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        MagicLinkRequestedView(email: "lord@yosemite.com")
    }
}
