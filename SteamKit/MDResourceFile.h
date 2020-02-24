//
//  MDResourceFile.h
//  Font Finagler
//
//  Created by Mark Douma on 7/22/2007.
//  Copyright © 2007 Mark Douma. All rights reserved.
//


#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>

NS_ASSUME_NONNULL_BEGIN

@class MDResource;

typedef NS_ENUM(UInt8, MDFork) {
	MDForkAny		= 0,
	MDForkResource	= 1,
	MDForkData		= 2
};


typedef NS_OPTIONS(char, MDPermission) {
	MDPermissionCurrentAllowable		= 0x00,
	MDPermissionRead					= 0x01,
	MDPermissionWrite					= 0x02,
	MDPermissionReadWrite				= 0x03
};

extern NSErrorDomain __nonnull const MDResourceFileErrorDomain;

NS_ERROR_ENUM(MDResourceFileErrorDomain) {
	MDResourceFileCorruptResourceFileError				= 4998,
};



@interface MDResourceFile : NSObject {
	NSString					*filePath;
	ResFileRefNum				fileReference;
	MDFork						fork;
	MDPermission				permission;
	
	MDResource					*plistResource;
	MDResource					*customIconResource;
	
}

//! read-only; which fork is determined automatically
- (nullable instancetype)initWithContentsOfFile:(NSString *)aPath error:(NSError *__nullable*__nullable)outError;
- (nullable instancetype)initWithContentsOfURL:(NSURL *)aURL error:(NSError *__nullable*__nullable)outError;


//! read/write; the 'updating' comes from NSFileHandle
- (nullable instancetype)initForUpdatingWithContentsOfFile:(NSString *)aPath fork:(MDFork)aFork error:(NSError *__nullable*__nullable)outError;
- (nullable instancetype)initForUpdatingWithContentsOfURL:(NSURL *)aURL fork:(MDFork)aFork error:(NSError *__nullable*__nullable)outError;


- (nullable instancetype)initWithContentsOfFile:(NSString *)aPath permission:(MDPermission)aPermission fork:(MDFork)aFork error:(NSError *__nullable*__nullable)outError;
- (nullable instancetype)initWithContentsOfURL:(NSURL *)aURL permission:(MDPermission)aPermission fork:(MDFork)aFork error:(NSError *__nullable*__nullable)outError;


@property (readonly) ResFileRefNum fileReference;
@property (readonly, copy) NSString *filePath;
@property (readonly) MDFork fork;
@property (readonly) MDPermission permission;


@property (readonly, retain, nullable) MDResource *plistResource;
@property (readonly, retain, nullable) MDResource *customIconResource;

- (BOOL)addResource:(MDResource *)aResource error:(NSError *__nullable*__nullable)outError;
- (BOOL)removeResource:(MDResource *)aResource error:(NSError *__nullable*__nullable)outError;

- (void)closeResourceFile;

@end

NS_ASSUME_NONNULL_END
