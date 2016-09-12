//
//  MDDateFormatter.m
//  Font Finagler
//
//  Created by Mark Douma on 6/19/2009.
//  Copyright © 2009 - 2010 Mark Douma. All rights reserved.
//  


#import "MDDateFormatter.h"


#pragma mark view
#define MD_DEBUG 0

static const NSTimeInterval MDNilDateTimeIntervalSinceReferenceDate = -3061152000.0;
static NSDate *MDNilDate = nil;


@implementation MDDateFormatter
{
@private
	CFDateFormatterRef	__mdFormatter;
	CFDateFormatterRef	__mdTimeFormatter;
	
	NSString *today;
	NSString *yesterday;
	NSString *tomorrow;
}

@synthesize style;
@synthesize relative;

+ (void)initialize {
	MDNilDate = [NSDate dateWithTimeIntervalSinceReferenceDate:MDNilDateTimeIntervalSinceReferenceDate];
}

- (instancetype)initWithStyle:(MDDateFormatterStyle)aStyle isRelative:(BOOL)value {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	if ((self = [super init])) {
		style = -1;
		relative = YES;
		
		__mdFormatter = NULL;
		__mdTimeFormatter = NULL;
		
		CFLocaleRef currentLocale = CFLocaleCopyCurrent();
		
		__mdTimeFormatter = CFDateFormatterCreate(NULL, currentLocale, kCFDateFormatterNoStyle, kCFDateFormatterShortStyle);
		
		CFRelease(currentLocale);
		
		self.style = aStyle;
		self.relative = value;
		
		today = NSLocalizedString(@"Today", @"");
		yesterday = NSLocalizedString(@"Yesterday", @"");
		tomorrow = NSLocalizedString(@"Tomorrow", @"");
	}
	return self;
}

- (instancetype)init
{
	return self = [self initWithStyle:MDDateFormatterMediumStyle isRelative:NO];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	if ((self = [super initWithCoder:coder])) {
		style = -1;
		relative = YES;
		
		__mdFormatter = NULL;
		__mdTimeFormatter = NULL;
		
		CFLocaleRef currentLocale = CFLocaleCopyCurrent();
		
		__mdTimeFormatter = CFDateFormatterCreate(NULL, currentLocale, kCFDateFormatterNoStyle, kCFDateFormatterShortStyle);
		
		CFRelease(currentLocale);
		
		
		self.style = [coder decodeIntegerForKey:@"MDStyle"];
		self.relative = [coder decodeBoolForKey:@"MDRelative"];
		
		today = NSLocalizedString(@"Today", @"");
		yesterday = NSLocalizedString(@"Yesterday", @"");
		tomorrow = NSLocalizedString(@"Tomorrow", @"");
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	[super encodeWithCoder:coder];
	
	[coder encodeInteger:style forKey:@"MDStyle"];
	[coder encodeBool:relative forKey:@"MDRelative"];
}

- (id)copyWithZone:(NSZone *)zone {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	MDDateFormatter *copy = [[[self class] allocWithZone:zone] initWithStyle:self.style isRelative:self.relative];
	
	return copy;
}

- (void)dealloc {
	if (__mdFormatter != NULL) {
		CFRelease(__mdFormatter);
		__mdFormatter = NULL;
	}
	if (__mdTimeFormatter != NULL) {
		CFRelease(__mdTimeFormatter);
		__mdTimeFormatter = NULL;
	}
}

#if MD_DEBUG
- (MDDateFormatterStyle)style {
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return style;
}
#endif

- (void)setStyle:(MDDateFormatterStyle)value {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (style != value) {
		style = value;
		if (__mdFormatter != NULL) {
			CFRelease(__mdFormatter);
			__mdFormatter = NULL;
		}
		CFLocaleRef currentLocale = CFLocaleCopyCurrent();
		switch (style) {
			case MDDateFormatterFullStyle:
				__mdFormatter = CFDateFormatterCreate(NULL, currentLocale, kCFDateFormatterFullStyle, kCFDateFormatterShortStyle);
				break;
				
			case MDDateFormatterLongStyle:
				__mdFormatter = CFDateFormatterCreate(NULL, currentLocale, kCFDateFormatterLongStyle, kCFDateFormatterShortStyle);
				break;

			case MDDateFormatterMediumStyle:
				__mdFormatter = CFDateFormatterCreate(NULL, currentLocale, kCFDateFormatterMediumStyle, kCFDateFormatterShortStyle);
				break;

			case MDDateFormatterShortStyle:
				__mdFormatter = CFDateFormatterCreate(NULL, currentLocale, kCFDateFormatterShortStyle, kCFDateFormatterShortStyle);
				break;

			case MDDateFormatterNoStyle:
				__mdFormatter = CFDateFormatterCreate(NULL, currentLocale, kCFDateFormatterShortStyle, kCFDateFormatterNoStyle);
				break;

			default:
				break;
		}
		CFRelease(currentLocale);
	}
}

#if MD_DEBUG
- (BOOL)isRelative {
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return relative;
}

- (void)setRelative:(BOOL)value {
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	relative = value;
}
#endif

- (NSString *)stringForObjectValue:(id)anObject {
#if MD_DEBUG
	NSLog(@"[%@ %@] anObject == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), anObject);
#endif
	
	if ([anObject isKindOfClass:[NSDate class]]) {
//		NSLog(@"[%@ %@] timeIntervalSinceReferenceDate == %f; MDNilDate == %@, %f", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [anObject timeIntervalSinceReferenceDate], MDNilDate, [MDNilDate timeIntervalSinceReferenceDate]);
	
		if ([anObject isEqualToDate:MDNilDate]) {
			return NSLocalizedString(@"--", @"");
		}
		
		NSString *string = nil;

//		NSLog(@"[%@ %@] it is an NSDate == %@, __mdFormatter == %@, __mdTimeFormatter == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), anObject, __mdFormatter, __mdTimeFormatter);

		if (relative) {
			NSCalendar *calendar = [NSCalendar currentCalendar];
			
			if ([calendar isDateInYesterday:anObject]) {
				/* Yesterday, %@ */
				NSString *timeString = (NSString *)CFBridgingRelease(CFDateFormatterCreateStringWithDate(NULL, __mdTimeFormatter, (CFDateRef)anObject));
				
				string = [[NSString alloc] initWithFormat:@"%@, %@", yesterday, timeString];
			} else if ([calendar isDateInToday:anObject]) {
				/* Today, %@ */
				NSString *timeString = (NSString *)CFBridgingRelease(CFDateFormatterCreateStringWithDate(NULL, __mdTimeFormatter, (CFDateRef)anObject));
				
				string = [[NSString alloc] initWithFormat:@"%@, %@", today, timeString];
			} else if ([calendar isDateInTomorrow:anObject]) {
				/* Tomorrow, %@ */
				NSString *timeString = (NSString *)CFBridgingRelease(CFDateFormatterCreateStringWithDate(NULL, __mdTimeFormatter, (CFDateRef)anObject));
				
				string = [[NSString alloc] initWithFormat:@"%@, %@", tomorrow, timeString];
			} else {
				string = (NSString *)CFBridgingRelease(CFDateFormatterCreateStringWithDate(NULL, __mdFormatter, (CFDateRef)anObject));
			}
			
		} else {
			string = (NSString *)CFBridgingRelease(CFDateFormatterCreateStringWithDate(NULL, __mdFormatter, (CFDateRef)anObject));
		}
		
		return string;
	}
	return nil;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	
	BOOL returnValue = NO;
	NSDate *date = nil;
	
	date = (NSDate *)CFBridgingRelease(CFDateFormatterCreateDateFromString(NULL, __mdFormatter, (CFStringRef)string, NULL));
	
	if (date) {
		returnValue = YES;
	}
	
	return returnValue;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)attrs {
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	return nil;
}

@end
