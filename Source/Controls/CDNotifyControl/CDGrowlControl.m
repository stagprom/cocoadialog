//
//  CDGrowl.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/1/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDGrowlControl.h"

@implementation CDGrowlControl

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleNumber        name:@"priority"]];
    [options addOption:[CDOptionMultipleNumbers     name:@"priorities"]];

    return options;
}

- (instancetype)initWithArguments {
    self = [super initWithArguments];
    if (self) {
        NSBundle *growlBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle].privateFrameworksPath stringByAppendingPathComponent:@"Growl.framework"]];
        if (growlBundle && [growlBundle load]) {
            // Register ourselves as a Growl delegate.
            [GrowlApplicationBridge setGrowlDelegate:self];
        } else {
            [self warning:@"Could not load Growl.framework", nil];
        }
    }
    return self;
}

- (void) createControl {
    [panel setPanelEmpty];

    NSString *clickPath = @"";
    if (arguments.options[@"click-path"].wasProvided) {
        clickPath = arguments.options[@"click-path"].stringValue;
    }
    
    NSString *clickArg = @"";
    if (arguments.options[@"click-arg"].wasProvided) {
        clickArg = arguments.options[@"click-arg"].stringValue;
    }
    
	NSArray *titles = arguments.options[@"titles"].arrayValue;
    NSArray *descriptions = arguments.options[@"descriptions"].arrayValue;
    
    NSNumber * priority = @0;
    if (arguments.options[@"priority"].wasProvided) {
        priority = arguments.options[@"priority"].numberValue;
    }
    BOOL sticky = arguments.options[@"sticky"].boolValue;
    // Multiple notifications
	if (descriptions != nil && descriptions.count && titles != nil && titles.count && titles.count == descriptions.count) {
		NSArray *givenIconImages = [self notificationIcons];
		NSImage *fallbackIcon = nil;
		NSMutableArray *icons = nil;
		unsigned i;
		// See what icons we got at the command line, or set a fallback
		// icon to use for all bubbles
		if (givenIconImages == nil) {
			fallbackIcon = [icon iconWithDefault];
		} else {
			icons = [NSMutableArray arrayWithArray:givenIconImages];
		}
		// If we were given less icons than we have bubbles, use a default
		// for any extra bubbles
		if (icons.count < descriptions.count) {
			NSImage *defaultIcon = [icon iconWithDefault];
			unsigned long numToAdd = descriptions.count - icons.count;
			for (i = 0; i < numToAdd; i++) {
				[icons addObject:defaultIcon];
			}
		}
        NSArray * priorities = arguments.options[@"priorities"].arrayValue;
        NSArray * clickPaths = arguments.options[@"click-paths"].arrayValue;
        NSArray * clickArgs = arguments.options[@"click-args"].arrayValue;
		// Create the bubbles
		for (i = 0; i < descriptions.count; i++) {
			NSImage *_icon = fallbackIcon == nil ? (NSImage *)icons[i] : fallbackIcon;
            [self addNotificationWithTitle:titles[i]
                               description:descriptions[i]
                                      icon:_icon
                                  priority:priorities.count ? priorities[i] : priority
                                    sticky:sticky
                                 clickPath:clickPaths.count ? clickPaths[i] : clickPath
                                  clickArg:clickArgs.count ? clickArgs[i] : clickArg
             ];

		}
    }
    // Single notification
    else if (arguments.options[@"title"].wasProvided && arguments.options[@"description"].wasProvided) {
        NSImage * _icon = [icon iconWithDefault];
        [self addNotificationWithTitle:arguments.options[@"title"].stringValue
                           description:arguments.options[@"description"].stringValue
                                  icon:_icon
                              priority:priority
                                sticky:sticky
                             clickPath:clickPath
                              clickArg:clickArg
         ];
    }
    
    NSEnumerator *en = [notifications objectEnumerator];
    id obj;
    while (obj = [en nextObject]) {
        NSDictionary * notification = [NSDictionary dictionaryWithDictionary:obj];
        [GrowlApplicationBridge
         notifyWithTitle:notification[@"title"]
         description:notification[@"description"]
         notificationName:@"General Notification"
         iconData:notification[@"iconData"]
         priority:[notification[@"priority"] intValue]
         isSticky:[notification[@"sticky"] boolValue]
         clickContext:[NSString stringWithFormat:@"%d", activeNotifications]];
        activeNotifications++;
    }
}

#pragma mark - Growl Integration
// Register Growl Notifications
- (NSDictionary *) registrationDictionaryForGrowl
{
    NSArray * notificationsForGrowl = @[@"General Notification"];
    return @{@"TicketVersion": @1,
                                 @"AllNotifications": notificationsForGrowl,
                                 @"DefaultNotifications": notificationsForGrowl};
}

- (void) growlNotificationWasClicked:(id)clickContext
{
    [self notificationWasClicked:clickContext];
    activeNotifications--;
    // Terminate cocoaDialog once all the notifications are complete
    if (activeNotifications <= 0) {
        [self stopControl];
    }
}

- (void) growlNotificationTimedOut:(id)clickContext
{
    activeNotifications--;
    if (activeNotifications <= 0) {
        [self stopControl];
    }
}

@end
