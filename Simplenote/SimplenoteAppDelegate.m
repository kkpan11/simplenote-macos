//
//  SimplenoteAppDelegate.m
//  Simplenote
//
//  Created by Michael Johnston on 11-08-22.
//  Copyright (c) 2011 Simperium. All rights reserved.
//

#import "SimplenoteAppDelegate.h"
#import "TagListViewController.h"
#import "DateTransformer.h"
#import "Note.h"
#import "Tag.h"
#import "NSNotification+Simplenote.h"
#import "AuthViewController.h"
#import "NoteEditorViewController.h"
#import "StatusChecker.h"
#import "SPConstants.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"
#import "WPAuthHandler.h"

@import Simperium_OSX;

#if SPARKLE_OTA
#import <Sparkle/Sparkle.h>
#endif



#pragma mark ====================================================================================
#pragma mark Private
#pragma mark ====================================================================================

@interface SimplenoteAppDelegate () <SPBucketDelegate>

@property (assign, nonatomic) BOOL                              exportUnlocked;

@property (strong, nonatomic) NSWindowController                *aboutWindowController;
@property (strong, nonatomic) NSWindowController                *privacyWindowController;

@property (strong, nonatomic) CoreDataManager                   *coreDataManager;

#if SPARKLE_OTA
@property (strong, nonatomic) SPUStandardUpdaterController      *updaterController;
#endif

@property (strong, nonatomic) CrashLogging                      *crashLogging;

@end


#pragma mark ====================================================================================
#pragma mark SimplenoteAppDelegate
#pragma mark ====================================================================================

@implementation SimplenoteAppDelegate

#pragma mark - Startup
// Can be used for bugs that don't show up while debugging from Xcode
- (void)redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    
    NSLog(@"Redirecting Console Logs: %@", logPath);
    freopen([logPath fileSystemRepresentation],"a+",stderr);
}

#if SPARKLE_OTA
- (void)configureSparkle
{
    self.updaterController = [[SPUStandardUpdaterController alloc] initWithUpdaterDelegate:nil
                                                                        userDriverDelegate:nil];

    _updaterController.updater.sendsSystemProfile = YES;
    _updaterController.updater.automaticallyChecksForUpdates = YES;

    [_updaterController.updater checkForUpdatesInBackground];
}
#endif

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [self configureSimperium];
    [self configureSimperiumAuth];
    [self configureSimperiumBuckets];
    [self configureCrashLogging];

    [self configureEditorMetadataCache];
    [self configureMainInterface];
    [self configureSplitViewController];
    [self configureMainWindowController];
    [self configureTagsController];
    [self configureNotesController];
    [self configureEditorController];
    [self configureVerificationCoordinator];
    [self configureVersionsController];
    [self configureAccountDeletionController];
    [self configureNoteWindowControllersManager];

    [self refreshStatusController];

    [self.simperium authenticateWithAppID:SPCredentials.simperiumAppID APIKey:SPCredentials.simperiumApiKey window:self.window];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#if SPARKLE_OTA
    [self configureSparkle];
#endif

#if VERBOSE_LOGGING
    [self.simperium setVerboseLoggingEnabled:YES];
    [self redirectConsoleLogToDocumentFolder];
#endif

    [[MigrationsHandler new] ensureUpdateIsHandled];

    [self applyStyle];
    [self cleanupTags];
    [self startListeningForThemeNotifications];

    [SPTracker trackApplicationLaunched];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self cleanupEditorMetadataCache];
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls
{
    NSURL *url = [urls firstObject];

    if (!url) {
        return;
    }

    // URL: Open a Note!
    if ([self handleOpenNoteWithUrl:url]) {
        return;
    }

    // Magic Link
    if ([self handleMagicAuthWithUrl:url]) {
        return;
    }

    if ([WPAuthHandler isWPAuthenticationUrl:url]) {
        if (self.simperium.user.authenticated) {
            // We're already signed in
            [[NSNotificationCenter defaultCenter] postNotificationName:SPSignInErrorNotificationName
                                                                object:nil];
            return;
        }

        SPUser *newUser = [WPAuthHandler authorizeSimplenoteUserFromUrl:url forAppId:SPCredentials.simperiumAppID];
        if (newUser != nil) {
            self.simperium.user = newUser;
            [self.simperium authenticationDidSucceedForUsername:newUser.email token:newUser.authToken];
        }
        
        [SPTracker trackWPCCLoginSucceeded];
        return;
    }

    if ([SPExporter mustEnableExportAction:url]) {
        self.exportUnlocked = YES;
    }
}


#pragma mark - Other

- (void)configureCrashLogging
{
    self.crashLogging = [[CrashLogging alloc] initWithSimperium:self.simperium];
    [self.crashLogging start];
}

- (IBAction)ensureMainWindowIsVisible:(id)sender
{
    if ([self.window isVisible]) {
        return;
    }

    [self.window makeKeyAndOrderFront:nil];
}

- (IBAction)selectAllNotesTag
{
    [self.tagListViewController selectAllNotesTag];
}

- (void)selectNoteWithKey:(NSString *)simperiumKey
{
    [self.noteListViewController displayAndSelectNoteWithSimperiumKey:simperiumKey];
}

- (void)cleanupTags
{
    // Some previous versions of Simplenote created blank tags that cause problems; clean them up
    SPBucket *tagBucket = [_simperium bucketForName:@"Tag"];
    NSArray *tags = [tagBucket allObjects];
    for (Tag *tag in tags) {
        if (tag.name == nil || tag.name.length == 0) {
            [tagBucket deleteObject:tag];
		}
    }
    [_simperium save];
}

- (IBAction)exportAcction:(id)sender
{
    [[SPExporter new] presentExporterFrom:self.window simperium:self.simperium];
}

- (IBAction)aboutAction:(id)sender
{
    // Prevents duplicate windows!
    if (self.aboutWindowController && self.aboutWindowController.window.isVisible) {
        [self.aboutWindowController.window makeKeyAndOrderFront:self];
        return;
    }
    
    NSStoryboard *aboutStoryboard = [NSStoryboard storyboardWithName:@"About" bundle:nil];
    self.aboutWindowController = [aboutStoryboard instantiateControllerWithIdentifier:@"AboutWindowController"];
    [self.aboutWindowController.window center];
    [self.aboutWindowController showWindow:self];
}

- (BOOL)application:(NSApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<NSUserActivityRestoring>> * _Nonnull))restorationHandler
{
    return [self handleUserActivity:userActivity];
}

#pragma mark - Simperium Delegates

- (void)simperiumDidLogin:(Simperium *)simperium
{
    SPUser *user = simperium.user;

    [self.verificationCoordinator processDidLoginWithEmail:user.email];
    [SPTracker refreshMetadataWithEmail:user.email];
    [self.crashLogging cacheUser: simperium.user];
}

- (void)simperiumDidLogout:(Simperium *)simperium
{
    [self.verificationCoordinator processDidLogout];
    [SPTracker refreshMetadataForAnonymousUser];
    [self.crashLogging clearCachedUser];

    [self.noteEditorMetadataCache removeAll];

    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:nil];
}

- (void)simperium:(Simperium *)simperium didFailWithError:(NSError *)error
{
    [SPTracker refreshMetadataForAnonymousUser];
    if (error.code == SPSimperiumErrorsInvalidToken) {
        [self logOutIfAccountDeletionRequested];
    }
}


#pragma mark - Simperium Callbacks

- (void)bucket:(SPBucket *)bucket didChangeObjectForKey:(NSString *)key forChangeType:(SPBucketChangeType)change memberNames:(NSArray *)memberNames
{
    // Ignore acks
    if (change == SPBucketChangeTypeAcknowledge) {
        return;
	}
    
    if ([bucket isEqual: self.simperium.notesBucket]) {
        // Note change
        switch (change) {                
            case SPBucketChangeTypeUpdate: {
                Note *note = [bucket objectForKey:key];
                if (!note) {
                    break;
                }

                if ([key isEqualToString:self.noteEditorViewController.note.simperiumKey]) {
                    [self.noteEditorViewController didReceiveNewContent];
                    [self.breadcrumbsViewController didReceiveNewContent:note];
                }

                [self.noteEditorMetadataCache didUpdateNote:note];

                if (note && !note.deleted) {
                    [[CSSearchableIndex defaultSearchableIndex] indexSearchableNote:note];
                } else {
                    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:@[key] completionHandler:nil];
                }
                
                break;
            }
            
            case SPBucketChangeTypeInsert:
                break;

            default:
                break;
        }
        return;
    }

    // Tag change
    if ([bucket isEqual: self.simperium.tagsBucket]) {
        [self.tagListViewController loadTags];
        return;
    }

    // Verification Status Change
    if ([bucket isEqual: self.simperium.accountBucket] && [key isEqualToString:SPCredentials.simperiumEmailVerificationObjectKey]) {
        NSDictionary *verification = [bucket objectForKey:key];
        [self.verificationCoordinator refreshStateWithVerification:verification];
        return;
    }
}

- (void)bucket:(SPBucket *)bucket willChangeObjectsForKeys:(NSSet *)keys
{
    if ([bucket isEqual: self.simperium.notesBucket]) {
        for (NSString *key in keys) {
            if ([key isEqualToString:self.noteEditorViewController.note.simperiumKey]) {
                [self.noteEditorViewController willReceiveNewContent];
            }

            Note *note = [bucket objectForKey:key];
            if (note) {
                [self.noteEditorMetadataCache willUpdateNote:note];
            }
        }
    }
}

- (void)bucket:(SPBucket *)bucket didReceiveObjectForKey:(NSString *)key version:(NSString *)version data:(NSDictionary *)data
{
    if ([bucket isEqual: self.simperium.notesBucket]) {
        [self.versionsController didReceiveObjectForSimperiumKey:key version:version data:data];
    }
}


#pragma mark - Static Helpers

+ (SimplenoteAppDelegate *)sharedDelegate
{
	return (SimplenoteAppDelegate *)[[NSApplication sharedApplication] delegate];
}


#pragma mark - Actions

-(void)signOut
{
    [SPTracker trackUserSignedOut];
    
    // Remove WordPress token

    [SPKeychain deletePasswordForService:SPWPServiceName account:self.simperium.user.email];
    
    [self.noteListViewController dismissSearch];
    [self.noteEditorViewController displayNote:nil];
    [self.tagListViewController reset];
    [self.noteListViewController setWaitingForIndex:YES];
    
    [_simperium signOutAndRemoveLocalData:YES completion:^{
        // Nuke User Settings
        [[Options shared] reset];
        [self.noteEditorMetadataCache removeAll];

        // Auth window won't show up until next run loop, so be careful not to close main window until then
        [self.window performSelector:@selector(orderOut:) withObject:self afterDelay:0.1f];
        [self.simperium authenticateIfNecessary];
        [self.accountDeletionController clearRequestToken];
    }];
}

- (IBAction)toggleSidebarAction:(id)sender
{
    [self.splitViewController toggleSidebarActionWithSender:sender];
    [SPTracker trackShortcutToggleSidebar];
}

- (IBAction)focusModeAction:(id)sender
{
    [self.splitViewController focusModeActionWithSender:sender];
    [SPTracker trackToggleFocusMode];
}

- (IBAction)helpAction:(id)sender
{
    NSArray *helpLinks = @[SPHelpURL, SPContactUsURL, SPTwitterURL];
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: helpLinks[menuItem.tag]]];
}

- (void)startListeningForThemeNotifications
{
    // Note: This *definitely* has to go, the second backgroundView is relocated
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(applyStyle)
                                                            name:AppleInterfaceThemeChangedNotification
                                                          object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyStyle)
                                                 name:ThemeDidChangeNotification
                                               object:nil];
}

- (void)stopListeningForThemeNotifications
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applyStyle
{
    [self.tagListViewController applyStyle];
    [self.noteListViewController refreshStyle];
    [self.noteEditorViewController refreshStyle];
    [self.noteEditorViewController fixChecklistColoring];
}


#pragma mark - Shutdown

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)hasVisibleWindows
{
    if (hasVisibleWindows) {
        return YES;
    }

    if (!self.simperium.user.authenticated) {
        [self.simperium authenticateIfNecessary];
        return YES;
    }

    [self.window setIsVisible:YES];
    [self.window makeKeyAndOrderFront:self];
    
    return YES;
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
    [self authenticateIfAccountDeletionRequested];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    [SPTracker trackApplicationTerminated];
    return [_simperium applicationShouldTerminate:sender];
}


#pragma mark - Core Data

- (CoreDataManager *)coreDataManager
{
    if (_coreDataManager) {
        return _coreDataManager;
    }

    NSError *error = nil;
    _coreDataManager = [self makeCoreDataManagerAndReturnError:&error];

    if (error) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }

    return _coreDataManager;
}


- (NSManagedObjectModel *)managedObjectModel
{
    return self.coreDataManager.managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    return  self.coreDataManager.persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataManager.managedObjectContext;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

@end
