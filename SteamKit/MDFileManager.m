//
//  MDFileManager.m
//  Font Finagler
//
//  Created by Mark Douma on 11/20/2006.
//  Copyright © 2006 Mark Douma. All rights reserved.
//  


#import "MDFileManager.h"
#import "TKFoundationAdditions.h"
#include <CoreServices/CoreServices.h>


#define MD_DEBUG 0

NSString * const MDFileLabelNumber		= @"MDFileLabelNumber";
NSString * const MDFileHasCustomIcon	= @"MDFileHasCustomIcon";
NSString * const MDFileIsStationery		= @"MDFileIsStationery";
NSString * const MDFileNameLocked		= @"MDFileNameLocked";
NSString * const MDFileIsPackage		= @"MDFileIsPackage";
NSString * const MDFileIsInvisible		= @"MDFileIsInvisible";
NSString * const MDFileIsAliasFile		= @"MDFileIsAliasFile";


static OSErr FSGetTotalForkSizes(const FSRef *ref,
								 UInt64 *totalLogicalSize,	/* can be NULL */
								 UInt64 *totalPhysicalSize,	/* can be NULL */
								 ItemCount *forkCount);		/* can be NULL */


static NSArray *fileAttributeKeys = nil;
static MDFileManager *sharedManager = nil;


@implementation MDFileManager

+ (void)initialize {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		fileAttributeKeys = [[NSArray alloc] initWithObjects:MDFileLabelNumber, MDFileHasCustomIcon,
							 MDFileIsStationery, MDFileNameLocked, MDFileIsPackage, MDFileIsInvisible, MDFileIsAliasFile, nil];
	});
}

+ (MDFileManager *)defaultManager {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (sharedManager == nil) {
		sharedManager = [[super allocWithZone:NULL] init];
	}
	return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [[self defaultManager] retain];
}

- (id)init {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super init])) {
		fileManager = [[NSFileManager alloc] init];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;	//denotes an object that cannot be released
}

- (oneway void)release {
	// do nothing
}

- (id)autorelease {
	return self;
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)outError {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (path == nil) return nil;
	if (outError) *outError = nil;
	
	NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:outError];
	if (attributes == nil)
		return nil;
	
	FSRef itemRef;
	
	if (![path getFSRef:&itemRef error:outError]) return attributes;
	
	FSCatalogInfo catalogInfo;
	OSErr err = noErr;
	
	err = FSGetCatalogInfo(&itemRef, kFSCatInfoNodeFlags | kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL);
	
	if (err != noErr) {
		NSLog(@"[%@ %@] FSGetCatalogInfo() returned %hi", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
		if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		return attributes;
	}
	
	NSMutableDictionary *mAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
	
	NSUInteger	labelColor		= 0;
	UInt16		hasCustomIcon	= 0;
	UInt16		isStationery	= 0;
	UInt16		nameLocked		= 0;
	UInt16		isPackage		= 0;
	UInt16		isInvisible		= 0;
	UInt16		isAlias			= 0;
	UInt64		totalFileSize	= 0;
	
	if (catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) {
		FolderInfo	*fInfo =  (FolderInfo *)&catalogInfo.finderInfo;
		
		labelColor		= fInfo->finderFlags & kColor;
		labelColor = (labelColor >> 1L);
		
		hasCustomIcon	= (fInfo->finderFlags & kHasCustomIcon);
		hasCustomIcon = (hasCustomIcon >> 10L);
		
		nameLocked		= (fInfo->finderFlags & kNameLocked);
		nameLocked = (nameLocked >> 12L);
		
		isPackage		= (fInfo->finderFlags & kHasBundle);
		isPackage = (isPackage >> 13L);
		
		isInvisible		= (fInfo->finderFlags & kIsInvisible);
		isInvisible = (isInvisible >> 14L);
		
		mAttributes[MDFileLabelNumber] = @(labelColor);
		mAttributes[MDFileHasCustomIcon] = @((BOOL)!!hasCustomIcon);
		mAttributes[MDFileNameLocked] = @((BOOL)!!nameLocked);
		mAttributes[MDFileIsPackage] = @((BOOL)!!isPackage);
		mAttributes[MDFileIsInvisible] = @((BOOL)!!isInvisible);
	} else {
		FileInfo	*fInfo = (FileInfo *)&catalogInfo.finderInfo;
		
		labelColor		= fInfo->finderFlags & kColor;
		labelColor = (labelColor >> 1L);
		
		hasCustomIcon	= (fInfo->finderFlags & kHasCustomIcon);
		hasCustomIcon = (hasCustomIcon >> 10L);
		
		isStationery	= (fInfo->finderFlags & kIsStationery);
		isStationery = (isStationery >> 11L);
		
		nameLocked		= (fInfo->finderFlags & kNameLocked);
		nameLocked = (nameLocked >> 12L);
		
		isInvisible		= (fInfo->finderFlags & kIsInvisible);
		isInvisible = (isInvisible >> 14L);
		
		isAlias			= (fInfo->finderFlags & kIsAlias);
		isAlias = (isAlias >> 15L);
		
		mAttributes[MDFileLabelNumber] = @(labelColor);
		mAttributes[MDFileHasCustomIcon] = @((BOOL)!!hasCustomIcon);
		mAttributes[MDFileIsStationery] = @((BOOL)!!isStationery);
		mAttributes[MDFileNameLocked] = @((BOOL)!!nameLocked);
		mAttributes[MDFileIsInvisible] = @((BOOL)!!isInvisible);
		mAttributes[MDFileIsAliasFile] = @((BOOL)!!isAlias);
		
		err = FSGetTotalForkSizes(&itemRef, &totalFileSize, NULL, NULL);
		if (err == noErr) {
			NSNumber *totalFileSizeNum = [[NSNumber alloc] initWithUnsignedLongLong:totalFileSize];
			mAttributes[NSFileSize] = totalFileSizeNum;
			[totalFileSizeNum release];
		} else {
			NSLog(@"[%@ %@] FSGetTotalForkSizes() returned %hi", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
			if (outError) *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		}
	}
	NSDictionary *rAttributes = [mAttributes copy];
	[mAttributes release];
	
	return [rAttributes autorelease];
}

- (BOOL)setAttributes:(NSDictionary *)attributes ofItemAtPath:(NSString *)path error:(NSError **)error {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (error)
		*error = nil;
	if (attributes == nil || path == nil)
		return NO;
	
	NSArray *keys = attributes.allKeys;
	id matchingKey = [keys firstObjectCommonWithArray:fileAttributeKeys];
	
	if (matchingKey) {
		FSRef itemRef;
		
		if (![path getFSRef:&itemRef error:error])
			return NO;
		
		FSCatalogInfo catalogInfo;
		OSErr err = noErr;
		
		err = FSGetCatalogInfo(&itemRef, kFSCatInfoNodeFlags | kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL);
		
		if (err != noErr) {
			NSLog(@"[%@ %@] FSGetCatalogInfo() returned %hi", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
			if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
			return NO;
		}
		
		id labelColorNum = attributes[MDFileLabelNumber];
		if (labelColorNum && [labelColorNum isKindOfClass:[NSNumber class]]) {
			
			NSUInteger labelColor = ((NSNumber *)labelColorNum).unsignedIntegerValue;
			
			if (labelColor <= MDFileLabelOrange) {
				labelColor = (labelColor << 1L);
				
				if (catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) {
					FolderInfo *fInfo = (FolderInfo *)&catalogInfo.finderInfo;
					fInfo->finderFlags &= ~kColor;
					fInfo->finderFlags |= (labelColor & kColor);
				} else {
					FileInfo *fInfo = (FileInfo *)&catalogInfo.finderInfo;
					fInfo->finderFlags &= ~kColor;
					fInfo->finderFlags |= (labelColor & kColor);
				}
			} else {
				NSLog(@"[%@ %@] Invalid value (%lu) passed for MDFileLabelColor; must be in the range 0 - 7", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (unsigned long)labelColor);
			}
		}
		
		id setCustomIconNum = attributes[MDFileHasCustomIcon];
		if (setCustomIconNum && [setCustomIconNum isKindOfClass:[NSNumber class]]) {
			BOOL setCustomIcon = ((NSNumber *)setCustomIconNum).boolValue;
			if (catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) {
				if (setCustomIcon) {
					((FolderInfo *)&catalogInfo.finderInfo)->finderFlags |= kHasCustomIcon;
				} else {
					((FolderInfo *)&catalogInfo.finderInfo)->finderFlags &= ~kHasCustomIcon;
				}
			} else {
				if (setCustomIcon) {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags |= kHasCustomIcon;
				} else {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags &= ~kHasCustomIcon;
				}
			}
		}
		
		id setIsStationeryNum = attributes[MDFileIsStationery];
		if (setIsStationeryNum && [setIsStationeryNum isKindOfClass:[NSNumber class]]) {
			BOOL setIsStationery = ((NSNumber *)setIsStationeryNum).boolValue;
			if (catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) {
				
			} else {
				if (setIsStationery) {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags |= kIsStationery;
				} else {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags &= ~kIsStationery;
				}
			}
		}
		
		id setNameLockedNum = attributes[MDFileNameLocked];
		if (setNameLockedNum && [setNameLockedNum isKindOfClass:[NSNumber class]]) {
			BOOL setNameLocked = ((NSNumber *)setNameLockedNum).boolValue;
			if (catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) {
				if (setNameLocked) {
					((FolderInfo *)&catalogInfo.finderInfo)->finderFlags |= kNameLocked;
				} else {
					((FolderInfo *)&catalogInfo.finderInfo)->finderFlags &= ~kNameLocked;
				}
			} else {
				if (setNameLocked) {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags |= kNameLocked;
				} else {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags &= ~kNameLocked;
				}
			}
		}
		
		id setIsPackageNum = attributes[MDFileIsPackage];
		if (setIsPackageNum && [setIsPackageNum isKindOfClass:[NSNumber class]]) {
			BOOL setIsPackage = ((NSNumber *)setIsPackageNum).boolValue;
			if (catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) {
				if (setIsPackage) {
					((FolderInfo *)&catalogInfo.finderInfo)->finderFlags |= kHasBundle;
				} else {
					((FolderInfo *)&catalogInfo.finderInfo)->finderFlags &= ~kHasBundle;
				}
			} else {
				
			}
		}
		
		id setIsInvisibleNum = attributes[MDFileIsInvisible];
		if (setIsInvisibleNum && [setIsInvisibleNum isKindOfClass:[NSNumber class]]) {
			BOOL setIsInvisible = ((NSNumber *)setIsInvisibleNum).boolValue;
			if (catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) {
				if (setIsInvisible) {
					((FolderInfo *)&catalogInfo.finderInfo)->finderFlags |= kIsInvisible;
				} else {
					((FolderInfo *)&catalogInfo.finderInfo)->finderFlags &= ~kIsInvisible;
				}
			} else {
				if (setIsInvisible) {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags |= kIsInvisible;
				} else {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags &= ~kIsInvisible;
				}
			}
		}
		
		id setIsAliasNum = attributes[MDFileIsAliasFile];
		if (setIsAliasNum && [setIsAliasNum isKindOfClass:[NSNumber class]]) {
			BOOL setIsAlias = ((NSNumber *)setIsAliasNum).boolValue;
			if (catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) {
				
			} else {
				if (setIsAlias) {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags |= kIsAlias;
				} else {
					((FileInfo *)&catalogInfo.finderInfo)->finderFlags &= ~kIsAlias;
				}
			}
		}
		
		err = FSSetCatalogInfo(&itemRef, kFSCatInfoFinderInfo, &catalogInfo);
		
		if (err != noErr) {
			NSLog(@"[%@ %@] FSSetCatalogInfo() returned %hi", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
			if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
			return NO;
		}
	}
	
	NSMutableDictionary *normalAttributes = [attributes mutableCopy];
	
	[normalAttributes removeObjectsForKeys:fileAttributeKeys];
	
	if (normalAttributes.count) {
		if (![fileManager setAttributes:normalAttributes ofItemAtPath:path error:error]) {
			[normalAttributes release];
			return NO;
		}
	}
	[normalAttributes release];
	return YES;
}

- (NSDictionary *)fileAttributesAtPath:(NSString *)path traverseLink:(BOOL)linkFlag {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:NULL];
	NSMutableDictionary *mAttributes = [attributes mutableCopy];
	
	FSRef fileRef;
	
	if ([path getFSRef:&fileRef error:NULL]) {
		OSErr err = noErr;
		UInt64	totalFileSize;
		
		err = FSGetTotalForkSizes(&fileRef, &totalFileSize, NULL, NULL);
		if (err == noErr) {
			mAttributes[NSFileSize] = @(totalFileSize);
		}
	}
	NSDictionary *rAttributes = [mAttributes copy];
	[mAttributes release];
	return [rAttributes autorelease];
}

- (BOOL)isDeletableFileAtPath:(NSString *)path {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL isDeletable = [fileManager isDeletableFileAtPath:path];
	
	if (isDeletable) {
		
		NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:NULL];
		if (attributes && [attributes fileIsImmutable]) {
			isDeletable = NO;
		}
	}
	return isDeletable;
}

@end

static OSErr FSGetTotalForkSizes(const FSRef *ref,
						  UInt64 *totalLogicalSize,	/* can be NULL */
						  UInt64 *totalPhysicalSize,	/* can be NULL */
						  ItemCount *forkCount)		/* can be NULL */ {
	
	OSErr			err;
	CatPositionRec	forkIterator;
	SInt64			forkSize;
	SInt64			*forkSizePtr;
	UInt64			forkPhysicalSize;
	UInt64			*forkPhysicalSizePtr;
	
	/* Determine if forkSize needed */
	if (totalLogicalSize != NULL) {
		*totalLogicalSize = 0;
		forkSizePtr = &forkSize;
	} else {
		forkSizePtr = NULL;
	}
	
	/* Determine if forkPhysicalSize is needed */
	if (totalPhysicalSize != NULL) {
		*totalPhysicalSize = 0;
		forkPhysicalSizePtr = &forkPhysicalSize;
	} else {
		forkPhysicalSizePtr = NULL;
	}
	
	/* zero fork count if returning it */
	if (forkCount != NULL) {
		*forkCount = 0;
	}
	
	/* Iterate through the forks to get the sizes */
	forkIterator.initialize = 0;
	
	do 	{
		err = FSIterateForks(ref, &forkIterator, NULL, forkSizePtr, forkPhysicalSizePtr);
		if (err == noErr) {
			if (totalLogicalSize != NULL) {
				*totalLogicalSize += forkSize;
			}
			if (totalPhysicalSize != NULL) {
				*totalPhysicalSize += forkPhysicalSize;
			}
			
			if (forkCount != NULL) {
				++*forkCount;
			}
		}
	} while (err == noErr);
	
	/* any error result other than errFSNoMoreItems is serious */
	require(err == errFSNoMoreItems, FSIterateForks);
	
	/* Normal exit */
	err = noErr;
	
FSIterateForks:
	return err;
}

@implementation NSDictionary (MDFileAttributes)

/* files & folders	*/
- (NSInteger)fileLabelColor {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSInteger labelColor = MDFileLabelUnsupported;
	NSNumber *labelColorNum = self[MDFileLabelNumber];
	if (labelColorNum) {
		labelColor = labelColorNum.integerValue;
	}
	return labelColor;
}

/* files & folders	*/
- (BOOL)fileHasCustomIcon {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL setCustomIcon = NO;
	NSNumber *setCustomIconNum = self[MDFileHasCustomIcon];
	if (setCustomIconNum) {
		setCustomIcon = setCustomIconNum.boolValue;
	}
	return setCustomIcon;
}

/* files only		*/
- (BOOL)fileIsStationery {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL isStationery = NO;
	NSNumber *isStationeryNum = self[MDFileIsStationery];
	if (isStationeryNum) {
		isStationery = isStationeryNum.boolValue;
	}
	return isStationery;
}

/* files & folders	(value isn't used by OS X) */
- (BOOL)fileNameLocked {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL nameLocked = NO;
	NSNumber *nameLockedNum = self[MDFileNameLocked];
	if (nameLockedNum) {
		nameLocked = nameLockedNum.boolValue;
	}
	return nameLocked;
}

/* folders only		(maps to kHasBundle, which for files means a 'BNDL' resource, and is therefore obsolete in OS X) */
- (BOOL)fileIsPackage {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL isPackage = NO;
	NSNumber *isPackageNum = self[MDFileIsPackage];
	if (isPackageNum) {
		isPackage = isPackageNum.boolValue;
	}
	return isPackage;
}

/* files & folders */
- (BOOL)fileIsInvisible {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	BOOL isInvisible = NO;
	NSNumber *isInvisibleNum = self[MDFileIsInvisible];
	if (isInvisibleNum) {
		isInvisible = isInvisibleNum.boolValue;
	}
	return isInvisible;
}

/* files only		*/
- (BOOL)fileIsAlias {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	BOOL fileIsAlias = NO;
	NSNumber *fileIsAliasNum = self[MDFileIsAliasFile];
	if (fileIsAliasNum) {
		fileIsAlias = fileIsAliasNum.boolValue;
	}
	return fileIsAlias;
}

@end
