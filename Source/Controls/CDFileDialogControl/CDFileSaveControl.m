/*
	CDFileSaveControl.m
	cocoaDialog
	Copyright (C) 2004-2006 Mark A. Stratman <mark@sporkstorms.org>
 
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.
 
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
 
	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#import "CDFileSaveControl.h"

@implementation CDFileSaveControl

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionFlag name:@"no-create-directories"]];

    return options;
}

- (void) createControl {
	savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:nil];
    
	NSString *file = @"";
	NSString *dir = nil;
	
	[self setMisc];

    [savePanel setTreatsFilePackagesAsDirectories:option[@"packages-as-directories"].wasProvided];

	if (option[@"no-create-directories"].wasProvided) {
		[savePanel setCanCreateDirectories:NO];
	}

	// Set starting file (to be used later with runModal...) - doesn't work.
	if (option[@"with-file"].wasProvided) {
		file = option[@"with-file"].stringValue;
	}
	// Set starting directory (to be used later with runModal...)
	if (option[@"with-directory"].wasProvided) {
		dir = option[@"with-directory"].stringValue;
	}
    
    // Check for dir or file path existance.
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    if (dir != nil && ![fm fileExistsAtPath:dir]) {
        [self warning:@"Option --with-directory specifies a directory that does not exist: %@", dir, nil];
    }

    self.panel = savePanel;

	// resize window if user specified alternate width/height
    if ([self needsResize]) {
		[self.panel setContentSize:[self findNewSize]];
	}
	
    // Reposition Panel
    [self setPosition];
    
    [self setTimeout];
	
    NSInteger result;
    if (dir != nil) {
        NSURL * url = [[[NSURL alloc] initFileURLWithPath:dir] autorelease];
        savePanel.directoryURL = url;
    }
    savePanel.nameFieldStringValue = file;
    result = [savePanel runModal];

    if (result == NSFileHandlingPanelOKButton) {
        controlExitStatus = -1;
        [controlReturnValues addObject:savePanel.URL.path];
    }
    else {
        controlExitStatus = -2;
        controlReturnValues = [NSMutableArray array];
    }
    [super stopControl];
}

@end
