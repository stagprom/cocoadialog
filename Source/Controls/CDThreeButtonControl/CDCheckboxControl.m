//
//  CDCheckboxControl.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 9/20/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDCheckboxControl.h"

@implementation CDCheckboxControl

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleNumber        name:@"rows"        category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionSingleNumber        name:@"columns"     category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionMultipleStrings     name:@"items"       category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionMultipleNumbers     name:@"checked"     category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionMultipleNumbers     name:@"mixed"       category:@"_CHECKBOX_OPTIONS"]];
    [options addOption:[CDOptionMultipleNumbers     name:@"disabled"    category:@"_CHECKBOX_OPTIONS"]];

    // Require options.
    options[@"button1"].required = YES;
    options[@"items"].required = YES;

    return options;
}

- (BOOL)isReturnValueEmpty {
    if (checkboxes.count > 0) {
        NSEnumerator *en = [checkboxes objectEnumerator];
        BOOL hasChecked = NO;
        id obj;
        while (obj = [en nextObject]) {
            if ([obj state] == NSOnState){
                hasChecked = YES;
                break;
            }
        }
        return !hasChecked;
    }
    else {
        return NO;
    }
}
- (NSString *) returnValueEmptyText {
    if (checkboxes.count > 1) {
        return @"You must check at least one item before continuing.";
    }
    else {
        return [NSString stringWithFormat: @"You must check the item \"%@\" before continuing.", [checkboxes[0] title]];
    }
}

- (BOOL) validateOptions {
    BOOL pass = [super validateOptions];

    // Check that at least one item has been specified.
    // @todo this really could be checked automatically now that options
    // are objects and could specify the number of minimum values.
    if (!arguments.options[@"items"].arrayValue.count) {
        [self error:@"Must supply at least one item in --items", nil];
        pass = NO;
	}

    return pass;
}
- (void) createControl {
	[self setTitleButtonsLabel:arguments.options[@"label"].stringValue];

	// set return values 
    NSArray * cells = controlMatrix.cells;
    NSMutableArray *tmpValues = [[[NSMutableArray alloc] init] autorelease];
    NSEnumerator *en = [cells objectEnumerator];
    id obj;
    while (obj = [en nextObject]) {
        if ([[obj className] isEqualToString:@"NSButtonCell"]) {
            [tmpValues addObject:obj];
        } 
    }
    checkboxes = [[NSMutableArray arrayWithArray:tmpValues] autorelease];
    en = [tmpValues objectEnumerator];
    while (obj = [en nextObject]) {
        checkboxes[[obj tag]] = obj;
    }
}

- (void) controlHasFinished:(int)button {
    NSMutableArray *checkboxesArray = [[[NSMutableArray alloc] init] autorelease];
    NSEnumerator *en = [checkboxes objectEnumerator];
    id obj;
	if (arguments.options[@"string-output"].wasProvided) {
        if (checkboxes != nil && checkboxes.count) {
            unsigned long state;
            while (obj = [en nextObject]) {
                state = [obj state];
                switch (state) {
                    case NSOffState: [checkboxesArray addObject: @"off"]; break;
                    case NSOnState: [checkboxesArray addObject: @"on"]; break;
                    case NSMixedState: [checkboxesArray addObject: @"mixed"]; break;
                }
            }
            [controlReturnValues addObject:[checkboxesArray componentsJoinedByString:@" "]];
        }
	} else {
        if (checkboxes != nil && checkboxes.count) {
            while (obj = [en nextObject]) {
                [checkboxesArray addObject: [NSString stringWithFormat:@"%li", (long)[obj state]]];
            }
            [controlReturnValues addObject:[checkboxesArray componentsJoinedByString:@" "]];
        }
	}    
    [super controlHasFinished:button];
}


- (void) setControl:(id)sender {
    // Setup the control
    NSArray *items = arguments.options[@"items"].arrayValue;
    NSArray *checked = arguments.options[@"checked"].wasProvided ? arguments.options[@"checked"].arrayValue : [NSArray array];
    NSArray *mixed = arguments.options[@"mixed"].wasProvided ? arguments.options[@"mixed"].arrayValue : [NSArray array];
    NSArray *disabled = arguments.options[@"disabled"].wasProvided ? arguments.options[@"disabled"].arrayValue : [NSArray array];

    // Set default precedence: columns, if both are present or neither are present
    int matrixPrecedence = 0;

    // Set number of columns.
    NSUInteger columns = 1;
    if (arguments.options[@"columns"].wasProvided) {
        columns = arguments.options[@"columns"].unsignedIntegerValue;
        if (columns < 1) {
            columns = 1;
        }
    }
    
    // Set number of rows.
    NSUInteger rows = 1;
    if (arguments.options[@"rows"].wasProvided) {
        rows = arguments.options[@"rows"].unsignedIntegerValue;
        if (rows < 1) {
            rows = 1;
        }
        if (rows > items.count){
            rows = items.count;
        }
        // User has specified number of rows, but not columns.
        // Set precedence to expand columns, not rows
        if (!arguments.options[@"columns"].wasProvided) {
            matrixPrecedence = 1;
        }
    }
    
    [self setControl: self matrixRows:rows matrixColumns:columns items:items precedence:matrixPrecedence];
    rows = controlMatrix.numberOfRows;
    columns = controlMatrix.numberOfColumns;
    
    NSMutableArray * controls = [NSMutableArray array];
    
    // Create the control for each item
    NSUInteger currItem = 0;
    NSEnumerator *en = [items objectEnumerator];
    float cellWidth = 0.0;
    id obj;
    while (obj = [en nextObject]) {
        NSButton * button = [[[NSButton alloc] init] autorelease];
        [button setButtonType:NSSwitchButton];
        button.title = items[currItem];
        if (checked != nil && checked.count) {
            if ([checked containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                button.cell.state = NSOnState;
            }
        }
        if (mixed != nil && mixed.count) {
            if ([mixed containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                [button.cell setAllowsMixedState:YES];
                button.cell.state = NSMixedState;
            }
        }
        if (disabled != nil && disabled.count) {
            if ([disabled containsObject:[NSString stringWithFormat:@"%lu", currItem]]) {
                [button.cell setEnabled: NO];
            }
        }
        button.cell.tag = currItem;
        [button sizeToFit];
        if (button.frame.size.width > cellWidth) {
            cellWidth = button.frame.size.width;
        }
        [controls addObject:button.cell];
        currItem++;
    }
    
    // Set other attributes of matrix
    [controlMatrix setAutosizesCells:NO];
    controlMatrix.cellSize = NSMakeSize(cellWidth, 18.0f);
    controlMatrix.mode = NSHighlightModeMatrix;
    
    // Populate the matrix
    currItem = 0;
    for (unsigned long currColumn = 0; currColumn <= columns - 1; currColumn++) {
        for (unsigned long currRow = 0; currRow <= rows - 1; currRow++) {
            if (currItem <= items.count - 1) {
                NSButtonCell * cell = controls[currItem];
                [controlMatrix putCell:cell atRow:currRow column:currColumn];
                currItem++;
            }
            else {
                NSCell * blankCell = [[[NSCell alloc] init] autorelease];
                blankCell.type = NSNullCellType;
                [blankCell setEnabled:NO];
                [controlMatrix putCell:blankCell atRow:currRow column:currColumn];
            }
        }
    }
}

@end
