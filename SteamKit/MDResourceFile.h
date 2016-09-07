//
//  MDResourceFile.h
//  Font Finagler
//
//  Created by Mark Douma on 7/22/2007.
//  Copyright © 2007 Mark Douma. All rights reserved.
//


#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>

@class MDResource;

typedef NS_ENUM(UInt8, MDFork) {
	MDAnyFork		= 0,
	MDResourceFork	= 1,
	MDDataFork		= 2
};


typedef NS_OPTIONS(char, MDPermission) {
	MDCurrentAllowablePermission		= 0x00,
	MDReadPermission					= 0x01,
	MDWritePermission					= 0x02,
	MDReadWritePermission				= 0x03
};


NS_ENUM(NSInteger) {
	MDResourceFileCorruptResourceFileError				= 4998,
};

extern NSString *__nonnull const MDResourceFileErrorDomain;


@interface MDResourceFile : NSObject {
	NSString					*filePath;
	ResFileRefNum				fileReference;
	MDFork						fork;
	MDPermission				permission;
	
	MDResource					*plistResource;
	MDResource					*customIconResource;
	
}

NS_ASSUME_NONNULL_BEGIN

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
