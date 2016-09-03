//
//  TKFoundationAdditions.h
//  TKFoundationAdditions
//
//  Created by Mark Douma on 12/03/2007.
//  Copyright (c) 2007-2011 Mark Douma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>


#if defined(__cplusplus)
#define TKFOUNDATION_EXTERN extern "C"
#else
#define TKFOUNDATION_EXTERN extern
#endif

#if !defined(TK_INLINE)
    #if defined(__GNUC__)
        #define TK_INLINE static __inline__ __attribute__((always_inline))
    #elif defined(__MWERKS__) || defined(__cplusplus)
        #define TK_INLINE static inline
    #elif defined(_MSC_VER)
        #define TK_INLINE static __inline
    #elif TARGET_OS_WIN32
        #define TK_INLINE static __inline__
    #endif
#endif


enum {
	TKUndeterminedVersion	= -1,
	TKCheetah				= 0x1000,
	TKPuma					= 0x1010,
	TKJaguar				= 0x1020,
	TKPanther				= 0x1030,
	TKTiger					= 0x1040,
	TKLeopard				= 0x1050,
	TKSnowLeopard			= 0x1060,
	TKLion					= 0x1070,
	TKMountainLion			= 0x1080,
	TKUnknownKitty			= 0x1090,
	TKUnknownVersion		= 0x1100
};

	
	
TKFOUNDATION_EXTERN BOOL TKMouseInRects(NSPoint inPoint, NSArray *inRects, BOOL isFlipped);
TKFOUNDATION_EXTERN NSString *NSStringForAppleScriptListFromPaths(NSArray *paths);
TKFOUNDATION_EXTERN SInt32 TKGetSystemVersion();
	


//	Bookmark Data Creation Options
//	Options used when creating bookmark data.
//		Constants
//	NSURLBookmarkCreationPreferFileIDResolution
//		Option for specifying that an alias created with the bookmark data prefers resolving with its embedded file ID.
//		Available in Mac OS X v10.6 and later.
//		Declared in NSURL.h.
//		
//	NSURLBookmarkCreationMinimalBookmark
//		Option for specifying that an alias created with the bookmark data be created with minimal information, which may make it smaller but still able to resolve in certain ways.
//		Available in Mac OS X v10.6 and later.
//		Declared in NSURL.h.
//	NSURLBookmarkCreationSuitableForBookmarkFile
//		Option for specifying that the bookmark data include properties required to create Finder alias files.
//		Available in Mac OS X v10.6 and later.
//		Declared in NSURL.h.

enum {
	TKBookmarkCreationDefaultOptions			= 1
};
typedef NSUInteger TKBookmarkCreationOptions;


//	Constants
//	NSURLBookmarkResolutionWithoutUI
//		Option for specifying that no UI feedback accompany resolution of the bookmark data.
//		Available in Mac OS X v10.6 and later.
//		Declared in NSURL.h.
//	NSURLBookmarkResolutionWithoutMounting
//		Option for specifying that no volume should be mounted during resolution of the bookmark data.
//		Available in Mac OS X v10.6 and later.
//		Declared in NSURL.h.
enum {
	TKBookmarkResolutionDefaultOptions		= 1,
	TKBookmarkResolutionWithoutUI = ( 1UL << 8 )
};
typedef NSUInteger TKBookmarkResolutionOptions;


//@interface NSURL (TKAdditions)
//- (BOOL)getFSRef:(FSRef *)anFSRef;
//@end

@interface NSString (TKAdditions)
+ (instancetype)stringByResolvingBookmarkData:(NSData *)bookmarkData options:(TKBookmarkResolutionOptions)options bookmarkDataIsStale:(BOOL *)isStale error:(NSError **)outError;
- (NSData *)bookmarkDataWithOptions:(TKBookmarkCreationOptions)options error:(NSError **)outError;

#if (TARGET_CPU_PPC || TARGET_CPU_X86) && MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_4
+ (NSString *)stringWithFSSpec:(const FSSpec *)anFSSpec;
#endif

+ (NSString *)stringWithFSRef:(const FSRef *)anFSRef;
- (BOOL)getFSRef:(FSRef *)anFSRef error:(NSError **)anError;
@property (readonly) BOOL boolValue;
@property (readonly, copy) NSString *stringByAssuringUniqueFilename;
@property (readonly, copy) NSString *stringByAbbreviatingFilenameTo31Characters;
@property (readonly) NSSize sizeForStringWithSavedFrame;
+ (NSString *)stringWithPascalString:(ConstStr255Param)aPStr;
//- (BOOL)getFSSpec:(FSSpec *)anFSSpec;
- (BOOL)pascalString:(StringPtr)aBuffer length:(SInt16)aLength;

- (NSComparisonResult)caseInsensitiveNumericalCompare:(NSString *)string;
- (NSComparisonResult)localizedCaseInsensitiveNumericalCompare:(NSString *)string;

- (BOOL)containsString:(NSString *)aString;

- (NSString *)stringByReplacing:(NSString *)value with:(NSString *)newValue;
@property (readonly, copy) NSString *slashToColon;
@property (readonly, copy) NSString *colonToSlash;

@property (readonly, copy) NSString *displayPath;

@end



@interface NSUserDefaults (TKSortDescriptorAdditions)

- (void)setSortDescriptors:(NSArray *)sortDescriptors forKey:(NSString *)key;
- (NSArray *)sortDescriptorsForKey:(NSString *)key;

@end

@interface NSDictionary (TKSortDescriptorAdditions)

- (NSArray *)sortDescriptorsForKey:(NSString *)key;

@end

@interface NSMutableDictionary (TKSortDescriptorAdditions)

- (void)setSortDescriptors:(NSArray *)sortDescriptors forKey:(NSString *)key;

@end




@interface NSIndexSet (TKAdditions)
+ (instancetype)indexSetWithIndexSet:(NSIndexSet *)indexes;

- (NSIndexSet *)indexesIntersectingIndexes:(NSIndexSet *)indexes;

@end


@interface NSMutableIndexSet (TKAdditions)
- (void)setIndexes:(NSIndexSet *)indexes;
@end


@interface NSData (TKDescriptionAdditions)

@property (readonly, copy) NSString *stringRepresentation;
@property (readonly, copy) NSString *enhancedDescription;

@end


#if !defined(TEXTUREKIT_EXTERN)

@interface NSData (TKAdditions)
@property (readonly, copy) NSString *sha1HexHash;
@property (readonly, copy) NSData *sha1Hash;


@end

@interface NSBundle (TKAdditions)
- (NSString *)checksumForAuxiliaryLibrary:(NSString *)dylibName;
@end
#endif


////////////////////////////////////////////////////////////////
////    NSMutableDictionary CATEGORY FOR THREAD-SAFETY
////////////////////////////////////////////////////////////////

@interface NSMutableDictionary (TKThreadSafety)

- (id)threadSafeObjectForKey:(id)aKey usingLock:(NSLock *)aLock;

- (void)threadSafeRemoveObjectForKey:(id)aKey usingLock:(NSLock *)aLock;

- (void)threadSafeSetObject:(id)anObject forKey:(id)aKey usingLock:(NSLock *)aLock;

@end


//@interface NSArray (TKAdditions)
//- (BOOL)containsObjectIdenticalTo:(id)object;
//@end
//
@interface NSMutableArray (TKAdditions)
- (void)insertObjectsFromArray:(NSArray *)array atIndex:(NSUInteger)anIndex;
@end




@interface NSObject (TKDeepMutableCopy)
@property (readonly, strong) id deepMutableCopy NS_RETURNS_RETAINED;
@end


#define TK_BUILDING_WITH_FOUNDATION_NSDATE_ADDITIONS 0

#if (TK_BUILDING_WITH_FOUNDATION_NSDATE_ADDITIONS)

@interface NSDate (TKAdditions)
+ (id)dateByRoundingDownToNearestMinute;
+ (id)dateByRoundingUpToNearestMinute;
+ (id)dateByAddingTwoAndRoundingUpToNearestMinute;
+ (id)midnightYesterdayMorning;
+ (id)midnightThisMorning;
+ (id)midnightTonight;
+ (id)midnightTomorrowNight;
- (BOOL)isEarlierThanDate:(NSDate *)aDate;
- (BOOL)isLaterThanDate:(NSDate *)aDate;
- (BOOL)isEarlierThanOrEqualToDate:(NSDate *)aDate;
- (BOOL)isLaterThanOrEqualToDate:(NSDate *)aDate;
- (id)dateByRoundingDownToNearestMinute;
- (id)dateByRoundingUpToNearestMinute;
- (id)dateByAddingTwoAndRoundingUpToNearestMinute;
- (id)midnightOfMorning;
- (id)midnightOfEvening;
- (id)midnightOfYesterdayMorning;
- (id)midnightOfTomorrowEvening;
- (id)baseWeekly; // take receiver's time of day and shift it to the first day of the week
//- (id)baseWeeklyForDate:(id)aDate; // basically the reverse of -baseWeekly; given that the receiver is a baseWeekly's time of day, transpose the time to the specified 'aDate'
- (id)baseMonthly; // take receiver's time of day and shift it to the first day of the month
- (id)dateByTransposingToCurrentDay;
- (id)dateByTransposingToFirstDayOfCurrentWeek;
- (id)dateByTransposingToFirstDayOfCurrentMonth;
- (id)dateBySynchronizingToTimeOfDayOfDate:(NSDate *)aDate;
@end
#endif

