#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
@import Simperium_OSX;

@class AuthenticationMode;
@class AuthenticationState;


// MARK: - AuthViewController: Simperium's Authentication UI

@interface AuthViewController : NSViewController <SPAuthenticationInterface, NSTextFieldDelegate>

@property (nonatomic, strong) IBOutlet NSStackView                  *stackView;
@property (nonatomic, strong) IBOutlet NSImageView                  *logoImageView;
@property (nonatomic, strong) IBOutlet NSTextField                  *simplenoteTitleView;
@property (nonatomic, strong) IBOutlet NSTextField                  *simplenoteSubTitleView;
@property (nonatomic, strong) IBOutlet NSTextField                  *headerLabel;
@property (nonatomic, strong) IBOutlet NSTextField                  *errorField;
@property (nonatomic, strong) IBOutlet SPAuthenticationTextField    *usernameField;
@property (nonatomic, strong) IBOutlet SPAuthenticationTextField    *passwordField;
@property (nonatomic, strong) IBOutlet SPAuthenticationTextField    *codeTextField;
@property (nonatomic, strong) IBOutlet NSButton                     *actionButton;
@property (nonatomic, strong) IBOutlet NSProgressIndicator          *actionProgress;
@property (nonatomic, strong) IBOutlet NSButton                     *secondaryActionButton;
@property (nonatomic, strong) IBOutlet NSView                       *tertiaryButtonContainerView;
@property (nonatomic, strong) IBOutlet NSButton                     *tertiaryButton;
@property (nonatomic, strong) IBOutlet NSView                       *actionsSeparatorView;
@property (nonatomic, strong) IBOutlet NSView                       *leadingSeparatorView;
@property (nonatomic, strong) IBOutlet NSTextField                  *separatorLabel;
@property (nonatomic, strong) IBOutlet NSView                       *trailingSeparatorView;
@property (nonatomic, strong) IBOutlet NSView                       *quarternaryButtonView;
@property (nonatomic, strong) IBOutlet NSButton                     *quarternaryButton;


@property (nonatomic, strong) IBOutlet NSLayoutConstraint           *passwordFieldHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint           *secondaryActionHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint           *wordPressSSOHeightConstraint;

@property (nonatomic, strong) SPAuthenticator                       *authenticator;
@property (nonatomic, strong) AuthenticationMode                    *mode;
@property (nonatomic, strong) AuthenticationState                   *state;

- (instancetype)initWithMode:(AuthenticationMode*)mode state:(AuthenticationState*)state;
- (void)pressedLogInWithPassword;
- (void)pressedLoginWithMagicLink;
- (void)pressedSignUp;
- (void)openForgotPasswordURL;
- (BOOL)validateCode;

- (void)setInterfaceEnabled:(BOOL)enabled;

- (void)presentPasswordResetAlert;
- (void)presentPasswordCompromisedAlert;
- (void)presentUnverifiedEmailAlert;
- (void)showAuthenticationErrorForCode:(NSInteger)responseCode responseString:(NSString *)responseString;

@end
