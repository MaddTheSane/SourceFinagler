//
//  TKFoundationAdditions.h
//  TKFoundationAdditions
//
//  Created by Mark Douma on 12/03/2007.
//  Copyright (c) 2007-2011 Mark Douma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>

NS_ASSUME_NONNULL_BEGIN

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

	
	
TKFOUNDATION_EXTERN BOOL TKMouseInRects(NSPoint inPoint, NSArray<NSValue*> *inRects, BOOL isFlipped);
TKFOUNDATION_EXTERN NSString *NSStringForAppleScriptListFromPaths(NSArray<NSString*> *paths);
	


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

typedef NS_OPTIONS(NSUInteger, TKBookmarkCreationOptions) {
	TKBookmarkCreationUseAliasManager			= ( 1UL << 0 ),
	TKBookmarkCreationMinimalBookmark			= ( 1UL << 9 ),
	TKBookmarkCreationSuitableForBookmarkFile	= ( 1UL << 10 ),
	TKBookmarkCreationWithSecurityScope NS_ENUM_AVAILABLE(10_7, NA) = ( 1UL << 11 ),
	TKBookmarkCreationSecurityScopeAllowOnlyReadAccess NS_ENUM_AVAILABLE(10_7, NA) = ( 1UL << 12 ),
	TKBookmarkCreationDefaultOptions			= TKBookmarkCreationUseAliasManager,
};


//	Constants
//	NSURLBookmarkResolutionWithoutUI
//		Option for specifying that no UI feedback accompany resolution of the bookmark data.
//		Available in Mac OS X v10.6 and later.
//		Declared in NSURL.h.
//	NSURLBookmarkResolutionWithoutMounting
//		Option for specifying that no volume should be mounted during resolution of the bookmark data.
//		Available in Mac OS X v10.6 and later.
//		Declared in NSURL.h.
typedef NS_OPTIONS(NSUInteger, TKBookmarkResolutionOptions) {
	TKBookmarkResolutionDefaultOptions		= 1,
	TKBookmarkResolutionWithoutUI			= ( 1UL << 8 ), /**< don't perform any user interaction during bookmark resolution */
	TKBookmarkResolutionWithoutMounting		= ( 1UL << 9 ), /**< don't mount a volume during bookmark resolution */
	TKBookmarkResolutionWithSecurityScope NS_ENUM_AVAILABLE(10_7, NA) = ( 1UL << 10 ) /**< use the secure information included at creation time to provide the ability to access the resource in a sandboxed process */
};


//@interface NSURL (TKAdditions)
//- (BOOL)getFSRef:(FSRef *)anFSRef;
//@end

@interface NSString (TKAdditions)
+ (nullable instancetype)stringByResolvingBookmarkData:(NSData *)bookmarkData options:(TKBookmarkResolutionOptions)options bookmarkDataIsStale:(BOOL *)isStale error:(NSError **)outError;
- (nullable NSData *)bookmarkDataWithOptions:(TKBookmarkCreationOptions)options error:(NSError **)outError;

+ (nullable NSString *)stringWithFSRef:(const FSRef *)anFSRef __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_0, __MAC_10_8, __IPHONE_NA, __IPHONE_NA) NS_SWIFT_UNAVAILABLE("no throws");
+ (nullable NSString *)stringWithFSRef:(const FSRef *)anFSRef error:(NSError *__nullable*__nullable)anError __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_0, __MAC_10_8, __IPHONE_NA, __IPHONE_NA);
- (BOOL)getFSRef:(FSRef *)anFSRef error:(NSError *__nullable*__nullable)anError __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_0, __MAC_10_8, __IPHONE_NA, __IPHONE_NA);

@property (readonly, copy) NSString *stringByAssuringUniqueFilename;
@property (readonly, copy) NSString *stringByAbbreviatingFilenameTo31Characters;
@property (readonly) NSSize sizeForStringWithSavedFrame;
+ (NSString *)stringWithPascalString:(ConstStr255Param)aPStr;
+ (NSString *)stringWithPascalString:(ConstStr255Param)aPStr encoding:(CFStringEncoding)encoding;
//- (BOOL)getFSSpec:(FSSpec *)anFSSpec;
- (BOOL)pascalString:(StringPtr)aBuffer length:(SInt16)aLength;
- (BOOL)pascalString:(StringPtr)aBuffer length:(SInt16)aLength encoding:(CFStringEncoding)encoding;

- (NSComparisonResult)caseInsensitiveNumericalCompare:(NSString *)string;
- (NSComparisonResult)localizedCaseInsensitiveNumericalCompare:(NSString *)string;

- (BOOL)containsString:(NSString *)aString;

- (NSString *)stringByReplacing:(NSString *)value with:(NSString *)newValue;
@property (readonly, copy) NSString *slashToColon;
@property (readonly, copy) NSString *colonToSlash;

@property (readonly, copy) NSString *displayPath;

@end



@interface NSUserDefaults (TKSortDescriptorAdditions)

- (void)setSortDescriptors:(NSArray<NSSortDescriptor*> *)sortDescriptors forKey:(NSString *)key;
- (nullable NSArray<NSSortDescriptor*> *)sortDescriptorsForKey:(NSString *)key;

@end

@interface NSDictionary (TKSortDescriptorAdditions)

- (nullable NSArray<NSSortDescriptor*> *)sortDescriptorsForKey:(NSString *)key;

@end

@interface NSMutableDictionary (TKSortDescriptorAdditions)

- (void)setSortDescriptors:(NSArray<NSSortDescriptor*> *)sortDescriptors forKey:(NSString *)key;

@end

@interface NSURL (TKAdditions)
+ (nullable NSURL*)URLWithFSRef:(const FSRef *)anFSRef __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_0, __MAC_10_8, __IPHONE_NA, __IPHONE_NA);
- (BOOL)getFSRef:(FSRef *)anFSRef error:(NSError *__nullable*__nullable)anError __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_0, __MAC_10_8, __IPHONE_NA, __IPHONE_NA);
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

@interface NSMutableDictionary<KeyType, ObjectType> (TKThreadSafety)

- (ObjectType)threadSafeObjectForKey:(KeyType)aKey usingLock:(NSLock *)aLock;

- (void)threadSafeRemoveObjectForKey:(KeyType)aKey usingLock:(NSLock *)aLock;

- (void)threadSafeSetObject:(ObjectType)anObject forKey:(KeyType)aKey usingLock:(NSLock *)aLock;

@end


//@interface NSArray (TKAdditions)
//- (BOOL)containsObjectIdenticalTo:(id)object;
//@end
//
@interface NSMutableArray<ObjectType> (TKAdditions)
- (void)insertObjectsFromArray:(NSArray<ObjectType> *)array atIndex:(NSUInteger)anIndex;
@end

@interface NSObject (TKDeepMutableCopy)
- (id)deepMutableCopy NS_RETURNS_RETAINED;
@end


#define TK_BUILDING_WITH_FOUNDATION_NSDATE_ADDITIONS 0

#if (TK_BUILDING_WITH_FOUNDATION_NSDATE_ADDITIONS)

@interface NSDate (TKAdditions)
+ (instancetype)dateByRoundingDownToNearestMinute;
+ (instancetype)dateByRoundingUpToNearestMinute;
+ (instancetype)dateByAddingTwoAndRoundingUpToNearestMinute;
+ (instancetype)midnightYesterdayMorning;
+ (instancetype)midnightThisMorning;
+ (instancetype)midnightTonight;
+ (instancetype)midnightTomorrowNight;
- (BOOL)isEarlierThanDate:(NSDate *)aDate;
- (BOOL)isLaterThanDate:(NSDate *)aDate;
- (BOOL)isEarlierThanOrEqualToDate:(NSDate *)aDate;
- (BOOL)isLaterThanOrEqualToDate:(NSDate *)aDate;
- (instancetype)dateByRoundingDownToNearestMinute;
- (instancetype)dateByRoundingUpToNearestMinute;
- (instancetype)dateByAddingTwoAndRoundingUpToNearestMinute;
- (instancetype)midnightOfMorning;
- (instancetype)midnightOfEvening;
- (instancetype)midnightOfYesterdayMorning;
- (instancetype)midnightOfTomorrowEvening;
- (instancetype)baseWeekly; //!< take receiver's time of day and shift it to the first day of the week
//- (id)baseWeeklyForDate:(id)aDate; // basically the reverse of -baseWeekly; given that the receiver is a baseWeekly's time of day, transpose the time to the specified 'aDate'
- (instancetype)baseMonthly; //!< take receiver's time of day and shift it to the first day of the month
- (instancetype)dateByTransposingToCurrentDay;
- (instancetype)dateByTransposingToFirstDayOfCurrentWeek;
- (instancetype)dateByTransposingToFirstDayOfCurrentMonth;
- (instancetype)dateBySynchronizingToTimeOfDayOfDate:(NSDate *)aDate;
@end
#endif

NS_ASSUME_NONNULL_END

