#import "NSArray+CocoaDialog.h"

@implementation NSArray (CocoaDialog)

#pragma mark - Properties
- (NSArray *) sortedAlphabetically {
    return [self sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark - Public instance methods
- (NSArray *) prependStringsWith:(NSString *)prefix {
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    for (id item in self) {
        if ([item isKindOfClass:[NSString class]]) {
            NSMutableString *string = [NSMutableString stringWithString:item];
            [string prepend:prefix];
            [array addObject:string];
        }
    }
    return [NSArray arrayWithArray:array];
}

@end
