#import <Foundation/Foundation.h>

#pragma mark - Constants

#ifndef CDColorEscape
#define CDColorEscape "\x1b["
#endif

#ifndef CDColorEscapeRegExp
#define CDColorEscapeRegExp "\\x1b\\["
#endif

#ifndef CDColor_h
#define CDColor_h

typedef NS_ENUM(int, CDColorBg) {
    CDColorBgNone = -1,
    CDColorBgBlack = 40,
    CDColorBgRed,
    CDColorBgGreen,
    CDColorBgYellow,
    CDColorBgBlue,
    CDColorBgMagenta,
    CDColorBgCyan,
    CDColorBgWhite,
    CDColorBgDefault = 49,
};

typedef NS_ENUM(int, CDColorFg) {
    CDColorFgNone = -1,
    CDColorFgBlack = 30,
    CDColorFgRed,
    CDColorFgGreen,
    CDColorFgYellow,
    CDColorFgBlue,
    CDColorFgMagenta,
    CDColorFgCyan,
    CDColorFgWhite,
    CDColorFgDefault = 39,
    CDColorFgLightBlack = 90,
    CDColorFgLightRed,
    CDColorFgLightGreen,
    CDColorFgLightYellow,
    CDColorFgLightBlue,
    CDColorFgLightMagenta,
    CDColorFgLightCyan,
    CDColorFgLightWhite,
};

typedef NS_ENUM(int, CDColorStyle) {
    CDColorStyleNone = -1,
    CDColorStyleDefault = 0,
    CDColorStyleBold = 1,
    CDColorStyleDim = 2,
    CDColorStyleItalic = 3,
    CDColorStyleUnderline = 4,
    CDColorStyleBlink = 5,
    CDColorStyleSwap = 7,
};

#pragma mark -
@interface CDColor : NSObject

#pragma mark - Properties
@property (nonatomic) CDColorBg bg;
@property (nonatomic) CDColorFg fg;
@property (nonatomic, readonly) BOOL isApplied;
@property (nonatomic, retain, readonly) NSMutableArray<NSNumber *> *styles;

#pragma mark - Public static methods
+ (instancetype) color;
+ (instancetype) fg:(CDColorFg)fg;
+ (instancetype) fg:(CDColorFg)fg bg:(CDColorBg)bg;
+ (instancetype) fg:(CDColorFg)fg bg:(CDColorBg)bg style:(CDColorStyle)style;
+ (instancetype) fg:(CDColorFg)fg bg:(CDColorBg)bg styles:(NSArray<NSNumber *> *)styles;
+ (NSNumber *) style:(CDColorStyle)style;

#pragma mark - Public instance methods.
- (void) addStyle:(CDColorStyle)style;
- (void) addStyles:(NSArray<NSNumber *> *)styles;
- (BOOL) hasStyle:(CDColorStyle)style;
- (BOOL) hasStyles:(NSArray<NSNumber *> *)styles;
- (void) merge:(CDColor *)color;
- (void) removeStyle:(CDColorStyle)style;
- (void) removeStyles:(NSArray<NSNumber *> *)styles;
- (void) removeAllStyles;
- (void) reset;

@end

#endif /* CDColor_h */
