#import <Foundation/Foundation.h>

// Category extensions.
#import "NSString+CDCommon.h"

@interface CDOption : NSObject {}

@property (nonatomic, assign) NSString *category;
@property (nonatomic, assign) NSString *helpText;
@property (nonatomic, assign) NSMutableArray<NSString *> *notes;
@property (nonatomic, assign) NSMutableArray<NSString *> *warnings;
@property (nonatomic, assign) BOOL required;
@property (nonatomic, assign) id value;
@property (nonatomic, assign) BOOL wasProvided;

// Read-only.
@property (nonatomic, readonly) NSArray* arrayValue;
@property (nonatomic, readonly) BOOL boolValue;
@property (nonatomic, readonly) double doubleValue;
@property (nonatomic, readonly) float floatValue;
@property (nonatomic, readonly) int intValue;
@property (nonatomic, readonly) NSInteger integerValue;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSNumber* numberValue;
@property (nonatomic, readonly) NSString* stringValue;
@property (nonatomic, readonly) unsigned int unsignedIntValue;
@property (nonatomic, readonly) NSUInteger unsignedIntegerValue;

+ (instancetype) name:(NSString *)name;
+ (instancetype) name:(NSString *)name value:(id)value;
+ (instancetype) name:(NSString *)name category:(NSString *) category;
+ (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category;
+ (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category helpText:(NSString *)helpText;

- (void) setValues:(NSArray<NSString *> *)values;

@end


@interface CDOptionDeprecated : CDOption {}

+ (instancetype) from:(NSString *)from to:(NSString *)to;

@property (nonatomic, readonly) NSString *from;
@property (nonatomic, readonly) NSString *to;

@end

@interface CDOptionFlag : CDOption @end

// Single values.
@interface CDOptionSingleString : CDOption @end
@interface CDOptionSingleNumber : CDOption @end
@interface CDOptionSingleStringOrNumber : CDOption @end

// Boolean
@interface CDOptionBoolean : CDOptionSingleStringOrNumber @end

// Multiple values.
@interface CDOptionMultipleStrings : CDOption @end
@interface CDOptionMultipleNumbers : CDOption @end
@interface CDOptionMultipleStringsOrNumbers : CDOption @end
