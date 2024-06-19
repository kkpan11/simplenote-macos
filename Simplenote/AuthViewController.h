#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
@import Simperium_OSX;

@class AuthenticationMode;


// MARK: - AuthViewController: Simperium's Authentication UI

@interface AuthViewController : NSViewController <SPAuthenticationInterface, NSTextFieldDelegate>

@property (nonatomic, strong) IBOutlet NSStackView                  *stackView;
@property (nonatomic, strong) IBOutlet NSImageView                  *logoImageView;
@property (nonatomic, strong) IBOutlet NSTextField                  *errorField;
@property (nonatomic, strong) IBOutlet SPAuthenticationTextField    *usernameField;
@property (nonatomic, strong) IBOutlet SPAuthenticationTextField    *passwordField;
@property (nonatomic, strong) IBOutlet NSButton                     *actionButton;
@property (nonatomic, strong) IBOutlet NSProgressIndicator          *actionProgress;
@property (nonatomic, strong) IBOutlet NSButton                     *secondaryActionButton;
@property (nonatomic, strong) IBOutlet NSTextField                  *switchTipField;
@property (nonatomic, strong) IBOutlet NSButton                     *switchActionButton;
@property (nonatomic, strong) IBOutlet NSView                       *wordPressSSOContainerView;
@property (nonatomic, strong) IBOutlet NSButton                     *wordPressSSOButton;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint           *passwordFieldHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint           *secondaryActionHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint           *wordPressSSOHeightConstraint;

@property (nonatomic, strong) SPAuthenticator                       *authenticator;
@property (nonatomic, strong) AuthenticationMode                    *mode;
@property (nonatomic, assign) BOOL                                  signingIn;

- (void)setInterfaceEnabled:(BOOL)enabled;

- (void)startSignupAnimation;
- (void)stopSignupAnimation;

- (void)presentPasswordResetAlert;
- (void)showAuthenticationErrorForCode:(NSInteger)responseCode responseString:(NSString *)responseString;

@end
