#import "AuthViewController.h"
#import "SPConstants.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"


#pragma mark - Constants


#pragma mark - Private

@interface AuthViewController ()
@property (nonatomic, strong) SPAuthenticationValidator *validator;
@end


#pragma mark - LoginViewController

@implementation AuthViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (instancetype)initWithMode:(AuthenticationMode*)mode state:(AuthenticationState*)state;
{
    if (self = [super init]) {
        self.validator = [SPAuthenticationValidator new];
        self.mode = mode;
        self.state = state;
    }

    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.validator = [SPAuthenticationValidator new];
        self.mode = [AuthenticationMode onboarding];
        self.state = [AuthenticationState new];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupInterface];
    [self refreshInterface];
    [self startListeningToNotifications];
}

- (void)startListeningToNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(signInErrorAction:) name:SPSignInErrorNotificationName object:nil];
}


#pragma mark - Action Handlers

- (void)openForgotPasswordURL {
    NSString *forgotPasswordURL = [SPCredentials simperiumForgotPasswordURL];
    NSString *username = self.usernameText;

    if (username.length) {
        NSString *parameters = [NSString stringWithFormat:@"?email=%@", username];
        forgotPasswordURL = [forgotPasswordURL stringByAppendingString:parameters];
    }

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:forgotPasswordURL]];
}

#pragma mark - Interface Helpers

- (void)setInterfaceEnabled:(BOOL)enabled {
    [self.usernameField setEnabled:enabled];
    [self.passwordField setEnabled:enabled];
    [self.actionButton setEnabled:enabled];
    [self.secondaryActionButton setEnabled:enabled];
    [self.tertiaryButton setEnabled:enabled];
}


#pragma mark - WordPress SSO

- (IBAction)signInErrorAction:(NSNotification *)notification
{
    NSString *errorMessage = NSLocalizedString(@"An error was encountered while signing in.", @"Sign in error message");
    if (notification.userInfo != nil && notification.userInfo[@"errorString"]) {
        errorMessage = [notification.userInfo valueForKey:@"errorString"];
    }

    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert setMessageText: NSLocalizedString(@"Couldn't Sign In", @"Alert dialog title displayed on sign in error")];
    [alert setInformativeText:errorMessage];
    [alert addButtonWithTitle: NSLocalizedString(@"OK", @"OK button in error alert dialog")];
    [alert runModal];
}


#pragma mark - Actions

- (void)pressedLogInWithPassword {
    [SPTracker trackUserSignedIn];
    [self clearAuthenticationError];

    if ([self mustUpgradePasswordStrength]) {
        [self performCredentialsValidation];
        return;
    }

    if (![self validateSignIn]) {
        return;
    }

    [self performLoginWithPassword];
}

- (void)pressedLoginWithMagicLink {
    [SPTracker trackLoginLinkRequested];
    
    [self clearAuthenticationError];
    
    if (![self validateSignInWithMagicLink]) {
        return;
    }
    
    [self performLoginWithEmailRequest];
}

- (void)pressedSignUp {
    [SPTracker trackUserSignedUp];
    [self clearAuthenticationError];

    if (![self validateSignUp]) {
        return;
    }

    [self performSignupRequest];
}

- (IBAction)cancelAction:(id)sender {
    [self.authenticator cancel];
}


#pragma mark - Authentication Wrappers

- (void)performCredentialsValidation {
    [self startActionAnimation];
    [self setInterfaceEnabled:NO];

    [self.authenticator validateWithUsername:self.usernameText password:self.passwordText success:^{
        [self stopActionAnimation];
        [self setInterfaceEnabled:YES];
        [self presentPasswordResetAlert];
    } failure:^(NSInteger responseCode, NSString *responseString, NSError *error) {
        [self showAuthenticationErrorForCode:responseCode responseString:responseString];
        [self stopActionAnimation];
        [self setInterfaceEnabled:YES];
    }];
}

- (void)performLoginWithPassword {
    [self startActionAnimation];
    [self setInterfaceEnabled:NO];

    [self.authenticator authenticateWithUsername:self.state.username password:self.state.password success:^{
        // NO-OP
    } failure:^(NSInteger responseCode, NSString *responseString, NSError *error) {
        [self showAuthenticationErrorForCode:responseCode responseString: responseString];
        [self stopActionAnimation];
        [self setInterfaceEnabled:YES];
    }];
}


#pragma mark - Password Reset Flow

- (void)presentPasswordResetAlert {
    NSAlert *alert = [NSAlert new];
    [alert setMessageText:self.passwordResetMessageText];
    [alert addButtonWithTitle:self.passwordResetProceedText];
    [alert addButtonWithTitle:self.passwordResetCancelText];

    __weak typeof(self) weakSelf = self;
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode != NSAlertFirstButtonReturn) {
            return;
        }

        [weakSelf openResetPasswordURL];
    }];
}

- (NSString *)passwordResetMessageText {
    return [@[
        NSLocalizedString(@"Your password is insecure and must be reset. The password requirements are:", comment: @"Password Requirements: Title"),
        @"",
        NSLocalizedString(@"- Password cannot match email", comment: @"Password Requirement: Email Match"),
        NSLocalizedString(@"- Minimum of 8 characters", comment: @"Password Requirement: Length"),
        NSLocalizedString(@"- Neither tabs nor newlines are allowed", comment: @"Password Requirement: Special Characters")
    ] componentsJoinedByString:@"\n"];
}

- (NSString *)passwordResetProceedText {
    return NSLocalizedString(@"Reset", @"Password Reset: Proceed");
}

- (NSString *)passwordResetCancelText {
    return NSLocalizedString(@"Cancel", @"Password Reset: Cancel");
}

- (void)openResetPasswordURL {
    NSString *resetPasswordPath = [SPCredentials.simperiumResetPasswordURL stringByAppendingString:self.usernameText];
    NSURL *targetURL = [NSURL URLWithString:resetPasswordPath];

    if (!targetURL) {
        return;
    }

    [[NSWorkspace sharedWorkspace] openURL:targetURL];
}


#pragma mark - Validation and Error Handling

- (BOOL)validateUsername {
    NSError *error = nil;
    if ([self.validator validateUsername:self.state.username error:&error]) {
        return YES;
    }

    [self showAuthenticationError:error.localizedDescription];

    return NO;
}

- (BOOL)validatePasswordSecurity {
    NSError *error = nil;
    if ([self.validator validatePasswordWithUsername:self.state.username password:self.state.password error:&error]) {
        return YES;
    }

    [self showAuthenticationError:error.localizedDescription];

    return NO;
}

- (BOOL)validateConnection {
    if (!self.authenticator.connected) {
        [self showAuthenticationError:NSLocalizedString(@"You're not connected to the internet", @"Error when you're not connected")];
        return NO;
    }

    return YES;
}

- (BOOL)mustUpgradePasswordStrength {
    return [self.validator mustPerformPasswordResetWithUsername:self.usernameText password:self.passwordText];
}

- (BOOL)validateCodeInput {
    if (self.state.code.length >= 6) {
        return YES;
    }

    [self showAuthenticationError:NSLocalizedString(@"Login Code is too short", comment: @"Message displayed when a login code is too short")];
    return NO;
}

- (BOOL)validateSignIn {
    return [self validateConnection] &&
           [self validateUsername] &&
           [self validatePasswordSecurity];
}

- (BOOL)validateSignInWithMagicLink {
    return [self validateConnection] &&
           [self validateUsername];
}

- (BOOL)validateSignUp {
    return [self validateConnection] &&
           [self validateUsername];
}

- (BOOL)validateCode {
    return [self validateConnection] &&
    [self validateCodeInput];
}

-(void)presentPasswordCompromisedAlert
{
    __weak typeof(self) weakSelf = self;
    [self showCompromisedPasswordAlertFor:self.view.window
                               completion:^(NSModalResponse response)  {
        if (response == NSAlertFirstButtonReturn) {
            [weakSelf openResetPasswordURL];
        }
    }];
}

- (void)presentUnverifiedEmailAlert
{
    __weak typeof(self) weakSelf = self;
    [self showUnverifiedEmailAlertFor:self.view.window
                               completion:^(NSModalResponse response)  {
        if (response == NSAlertFirstButtonReturn) {
            [weakSelf sendVerificationMessageFor:self.usernameText inWindow:self.view.window];
        }
    }];
}

#pragma mark - NSTextView

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [self handleNewlineInField:control];
    }

    return NO;
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    [self.view setNeedsDisplay:YES];
    return YES;
}

- (void)controlTextDidChange:(NSNotification *)obj {
    NSEvent *currentEvent = [NSApp currentEvent];
    if (currentEvent.type == NSEventTypeKeyDown && [currentEvent.charactersIgnoringModifiers isEqualToString:@"\r"]) {
        [self handleNewlineInField:obj.object];
    }

    [self updateStateWith:obj.object];
}

@end
