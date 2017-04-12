/*
	CDProgressbarControl.m
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

#import "CDProgressbarControl.h"
#import "CDProgressbarInputHandler.h"
#import <sys/select.h>

@implementation CDProgressbarControl

- (NSString *) controlNib {
	return @"Progressbar";
}

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleString    name:@"text"]];
    [options addOption:[CDOptionSingleString    name:@"percent"]];
    [options addOption:[CDOptionFlag            name:@"indeterminate"]];
    [options addOption:[CDOptionFlag            name:@"float"]];
    [options addOption:[CDOptionFlag            name:@"stoppable"]];

    return options;
}

-(void) updateProgress:(NSNumber*)newProgress {
	progressBar.doubleValue = newProgress.doubleValue;
}

-(void) updateLabel:(NSString*)newLabel {
	expandingLabel.stringValue = newLabel;
}

-(void) finish {
	if (confirmationSheet) {
		[NSApp endSheet:confirmationSheet.window];
		[confirmationSheet release];
		confirmationSheet = nil;
	}

	if (stopped) {
		NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
		[fh writeData:[@"stopped\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}

	[NSApp terminate:nil];
}

-(void) confirmStop {
	confirmationSheet = [[NSAlert alloc] init];
	[confirmationSheet addButtonWithTitle:NSLocalizedString(@"Stop", nil)];
	[confirmationSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	confirmationSheet.messageText = NSLocalizedString(@"Are you sure you want to stop?", nil);
	[confirmationSheet beginSheetModalForWindow:panel.panel modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	if (confirmationSheet == alert) {
		[confirmationSheet release];
		confirmationSheet = nil;
	}
	if (returnCode == NSAlertFirstButtonReturn && stopEnabled) {
		stopped = YES;
		[self finish];
	}
}

-(IBAction)stop:(id)sender {
	[self confirmStop];
}

-(void) setStopEnabled:(NSNumber*)enabled {
	stopEnabled = enabled.boolValue;
	stopButton.enabled = stopEnabled;
}

- (void) createControl {
	stopEnabled = YES;
	
	[panel addMinWidth:progressBar.frame.size.width + 30.0f];
	[icon addControl:expandingLabel];
	[icon addControl:progressBar];

	// Set text label.
    expandingLabel.stringValue = arguments.options[@"text"].wasProvided ? arguments.options[@"text"].stringValue : @"";

	// Hide stop button if not stoppable and resize window/controls.
	if (!arguments.options[@"stoppable"].wasProvided) {
		NSRect progressBarFrame = progressBar.frame;

		NSRect currentWindowFrame = panel.panel.frame;
		CGFloat stopButtonWidth = stopButton.frame.size.width;
		NSRect newWindowFrame = {
			.origin = currentWindowFrame.origin,
			.size = NSMakeSize(currentWindowFrame.size.width - stopButtonWidth + 2, currentWindowFrame.size.height)
		};
		[panel.panel setFrame:newWindowFrame display:NO];

		progressBar.frame = progressBarFrame;
		[stopButton setHidden:YES];
	}

	[panel resize];
	
	CDProgressbarInputHandler *inputHandler = [[CDProgressbarInputHandler alloc] init];
	[inputHandler setDelegate:self];

	[progressBar setMinValue:CDProgressbarMIN];
	[progressBar setMaxValue:CDProgressbarMAX];
	
	// Set initial percent.
	if (arguments.options[@"percent"].wasProvided) {
		double initialPercent;
		if ([inputHandler parseString:arguments.options[@"percent"].stringValue intoProgress:&initialPercent]) {
			progressBar.doubleValue = initialPercent;
		}
	}
		
	// Set window title.
	if (arguments.options[@"title"].wasProvided) {
		panel.panel.title = arguments.options[@"title"].stringValue;
	}

	// set indeterminate
	if (arguments.options[@"indeterminate"].wasProvided) {
		[progressBar setIndeterminate:YES];
		[progressBar startAnimation:self];
	} else {
		[progressBar setIndeterminate:NO];
	}

	NSOperationQueue* queue = [[NSOperationQueue new] autorelease];
	[queue addOperation:inputHandler];
	[inputHandler release];
}

@end
