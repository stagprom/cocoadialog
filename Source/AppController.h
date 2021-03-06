/*
	AppController.h
	cocoaDialog
	Copyright (C) 2004 Mark A. Stratman <mark@sporkstorms.org>

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

#import <Foundation/Foundation.h>

// Category extensions.
#import "NSArray+CocoaDialog.h"
#import "NSString+CocoaDialog.h"

// Controls.
#import "CDControl.h"
#import "CDBubbleControl.h"
#import "CDCheckboxControl.h"
#import "CDFileSelectControl.h"
#import "CDFileSaveControl.h"
#import "CDGrowlControl.h"
#import "CDInputboxControl.h"
#import "CDMsgboxControl.h"
#import "CDNotifyControl.h"
#import "CDOkMsgboxControl.h"
#import "CDPopUpButtonControl.h"
#import "CDProgressbarControl.h"
#import "CDRadioControl.h"
#import "CDSecureInputboxControl.h"
#import "CDSecureStandardInputboxControl.h"
#import "CDSlider.h"
#import "CDStandardInputboxControl.h"
#import "CDStandardPopUpButtonControl.h"
#import "CDTextboxControl.h"
#import "CDYesNoMsgboxControl.h"

#pragma mark - Constants
#define CDSite "https://mstratman.github.io/cocoadialog/"

#pragma mark -
@interface AppController : NSObject

#pragma mark - Properties
@property (nonatomic, retain) IBOutlet  NSTextField *aboutAppLink;
@property (nonatomic, retain) IBOutlet  NSPanel     *aboutPanel;
@property (nonatomic, retain) IBOutlet  NSTextField *aboutText;
@property (nonatomic, readonly, copy)   NSString    *appVersion;

#pragma mark - Public static methods
+ (NSString *) appVersion;
+ (NSArray<NSString *> *) availableControls;

#pragma mark - Public instance methods
- (CDControl *) getControl;
- (void)setHyperlinkForTextField:(NSTextField*)aTextField replaceString:(NSString *)aString withURL:(NSString *)aURL;
@end

#pragma mark -
@interface NSAttributedString (Hyperlink)
    +(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL withFont:(NSFont *)aFont;
@end
