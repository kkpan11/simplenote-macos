//
//  SPTracker.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/17/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import "SPTracker.h"
#import "SPAutomatticTracker.h"
#import "SimplenoteAppDelegate.h"
#import "Simperium+Simplenote.h"
#import "Simplenote-Swift.h"

@implementation SPTracker


#pragma mark - Metadata

+ (void)refreshMetadataWithEmail:(NSString *)email
{
    if ([NSProcessInfo isRunningTests]) {
        return;
    }

    [[SPAutomatticTracker sharedInstance] refreshMetadataWithEmail:email];
}

+ (void)refreshMetadataForAnonymousUser
{
    if ([NSProcessInfo isRunningTests]) {
        return;
    }

    [[SPAutomatticTracker sharedInstance] refreshMetadataForAnonymousUser];
}



#pragma mark - Lifecycle
+ (void)trackApplicationLaunched
{
    [self trackAutomatticEventWithName:@"application_launched" properties:nil];
}

+ (void)trackApplicationTerminated
{
    [self trackAutomatticEventWithName:@"application_terminated" properties:nil];
}


#pragma mark - Note Editor

+ (void)trackEditorCopiedInternalLink
{
    [self trackAutomatticEventWithName:@"editor_copied_internal_link" properties:nil];
}

+ (void)trackEditorChecklistInserted
{
    [self trackAutomatticEventWithName:@"editor_checklist_inserted" properties:nil];
}

+ (void)trackEditorNoteCreated
{
    [self trackAutomatticEventWithName:@"editor_note_created" properties:nil];
}

+ (void)trackEditorNoteDeleted
{
    [self trackAutomatticEventWithName:@"editor_note_deleted" properties:nil];
}

+ (void)trackEditorNoteDuplicated
{
    [self trackAutomatticEventWithName:@"editor_note_duplicated" properties:nil];
}

+ (void)trackEditorNoteRestored
{
    [self trackAutomatticEventWithName:@"editor_note_restored" properties:nil];
}

+ (void)trackEditorNotePublished
{
    [self trackAutomatticEventWithName:@"editor_note_published" properties:nil];
}

+ (void)trackEditorNoteUnpublished
{
    [self trackAutomatticEventWithName:@"editor_note_unpublished" properties:nil];
}

+ (void)trackEditorNoteEdited
{
    [self trackAutomatticEventWithName:@"editor_note_edited" properties:nil];
}

+ (void)trackEditorTagAdded:(BOOL)isEmail
{
    NSString *eventName = isEmail ? @"editor_email_tag_added" : @"editor_tag_added";
    [self trackAutomatticEventWithName:eventName properties:nil];
}

+ (void)trackEditorTagRemoved:(BOOL)isEmail
{
    NSString *eventName = isEmail ? @"editor_email_tag_removed" : @"editor_tag_removed";
    [self trackAutomatticEventWithName:eventName properties:nil];
}

+ (void)trackEditorTagsEdited
{
    [self trackAutomatticEventWithName:@"editor_tags_edited" properties:nil];
}

+ (void)trackEditorNotePinningToggled
{
    [self trackAutomatticEventWithName:@"editor_note_pinning_toggled" properties:nil];
}

+ (void)trackEditorCollaboratorsAccessed
{
    [self trackAutomatticEventWithName:@"editor_collaborators_accessed" properties:nil];
}

+ (void)trackEditorVersionsAccessed
{
    [self trackAutomatticEventWithName:@"editor_versions_accessed" properties:nil];
}



#pragma mark - Note List

+ (void)trackListCopiedInternalLink
{
    [self trackAutomatticEventWithName:@"list_copied_internal_link" properties:nil];
}

+ (void)trackListNoteDeleted
{
    [self trackAutomatticEventWithName:@"list_note_deleted" properties:nil];
}

+ (void)trackListNoteDeletedForever
{
    [self trackAutomatticEventWithName:@"list_note_deleted_forever" properties:nil];
}

+ (void)trackListNoteDuplicated
{
    [self trackAutomatticEventWithName:@"list_note_duplicated" properties:nil];
}

+ (void)trackListNotePinningToggled
{
    [self trackAutomatticEventWithName:@"list_note_pinning_toggled" properties:nil];
}

+ (void)trackListNoteRestored
{
    [self trackAutomatticEventWithName:@"list_note_restored" properties:nil];
}

+ (void)trackListNoteOpened
{
    [self trackAutomatticEventWithName:@"list_note_opened" properties:nil];
}

+ (void)trackListTrashEmptied
{
    [self trackAutomatticEventWithName:@"list_trash_emptied" properties:nil];
}

+ (void)trackListNotesSearched
{
    [self trackAutomatticEventWithName:@"list_notes_searched" properties:nil];
}

+ (void)trackListTrashPressed
{
    [self trackAutomatticEventWithName:@"list_trash_viewed" properties:nil];
}

+ (void)trackListSortBarModeChanged
{
    [self trackAutomatticEventWithName:@"list_sortbar_mode_changed" properties:nil];
}


#pragma mark - Preferences

+ (void)trackSettingsFontSizeUpdated
{
    [self trackAutomatticEventWithName:@"settings_font_size_updated" properties:nil];
}

+ (void)trackSettingsNoteListSortMode:(NSString *)description
{
    [self trackAutomatticEventWithName:@"settings_note_list_sort_mode" properties:@{ @"description" : description }];
}

+ (void)trackSettingsThemeUpdated:(NSString *)themeName
{
    NSDictionary *properties = nil;
    if (themeName != nil) {
        properties = @{ @"name": themeName };
    }

    [self trackAutomatticEventWithName:@"settings_theme_updated" properties:properties];
}

+ (void)trackSettingsListCondensedEnabled:(BOOL)isOn
{
    [self trackAutomatticEventWithName:@"settings_list_condensed_enabled" properties:@{ @"enabled" : @(isOn) }];
}



#pragma mark - Sidebar

+ (void)trackSidebarButtonPresed
{
    [self trackAutomatticEventWithName:@"sidebar_button_pressed" properties:nil];
}



#pragma mark - Tag List

+ (void)trackTagRowPressed
{
    [self trackAutomatticEventWithName:@"tag_cell_pressed" properties:nil];
}

+ (void)trackTagRowRenamed
{
    [self trackAutomatticEventWithName:@"tag_menu_renamed" properties:nil];
}

+ (void)trackTagRowDeleted
{
    [self trackAutomatticEventWithName:@"tag_menu_deleted" properties:nil];
}



#pragma mark - User

+ (void)trackUserSignedUp
{
    [self trackAutomatticEventWithName:@"user_account_created" properties:nil];
}

+ (void)trackUserSignedIn
{
    [self trackAutomatticEventWithName:@"user_signed_in" properties:nil];
}

+ (void)trackUserSignedOut
{
    [self trackAutomatticEventWithName:@"user_signed_out" properties:nil];
}


#pragma mark - Login Links

+ (void)trackLoginLinkRequested
{
    [self trackAutomatticEventWithName:@"login_link_requested" properties:nil];
}

+ (void)trackLoginLinkConfirmationSuccess
{
   [self trackAutomatticEventWithName:@"login_link_confirmation_success" properties:nil];
}

+ (void)trackLoginLinkConfirmationFailure
{
   [self trackAutomatticEventWithName:@"login_link_confirmation_failure" properties:nil];
}


#pragma mark - WP.com Sign In

+ (void)trackWPCCButtonPressed
{
    [self trackAutomatticEventWithName:@"wpcc_button_pressed" properties:nil];
}

+ (void)trackWPCCLoginSucceeded
{
    [self trackAutomatticEventWithName:@"wpcc_login_succeeded" properties:nil];
}

+ (void)trackWPCCLoginFailed
{
    [self trackAutomatticEventWithName:@"wpcc_login_failed" properties:nil];
}



#pragma mark - Google Analytics Helpers

+ (void)trackAutomatticEventWithName:(NSString *)name properties:(NSDictionary *)properties
{
    if ([self isTrackingDisabled]) {
        return;
    }

    if ([NSProcessInfo isRunningTests]) {
        return;
    }

    [[SPAutomatticTracker sharedInstance] trackEventWithName:name properties:properties];
}


#pragma mark - Automattic Tracks Helpers

+ (BOOL)isTrackingDisabled
{
    return [[Options shared] analyticsEnabled] == false;
}

@end
