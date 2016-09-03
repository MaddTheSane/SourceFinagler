//
//  MDResourceFile.h
//  Font Finagler
//
//  Created by Mark Douma on 7/22/2007.
//  Copyright © 2007 Mark Douma. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

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

extern NSString * const MDResourceFileErrorDomain;


@interface MDResourceFile : NSObject {
	NSString					*filePath;
	ResFileRefNum				fileReference;
	MDFork						fork;
	MDPermission				permission;
	
	MDResource					*plistResource;
	MDResource					*customIconResource;
	
}

// read-only; which fork is determined automatically
- (instancetype)initWithContentsOfFile:(NSString *)aPath error:(NSError **)outError;
- (instancetype)initWithContentsOfURL:(NSURL *)aURL error:(NSError **)outError;


// read/write; the 'updating' comes from NSFileHandle
- (instancetype)initForUpdatingWithContentsOfFile:(NSString *)aPath fork:(MDFork)aFork error:(NSError **)outError;
- (instancetype)initForUpdatingWithContentsOfURL:(NSURL *)aURL fork:(MDFork)aFork error:(NSError **)outError;


- (instancetype)initWithContentsOfFile:(NSString *)aPath permission:(MDPermission)aPermission fork:(MDFork)aFork error:(NSError **)outError;
- (instancetype)initWithContentsOfURL:(NSURL *)aURL permission:(MDPermission)aPermission fork:(MDFork)aFork error:(NSError **)outError;


- (ResFileRefNum)fileReference;
- (NSString *)filePath;
@property (readonly) MDFork fork;
@property (readonly) MDPermission permission;


- (MDResource *)plistResource;
- (MDResource *)customIconResource;

- (BOOL)addResource:(MDResource *)aResource error:(NSError **)outError;
- (BOOL)removeResource:(MDResource *)aResource error:(NSError **)outError;

- (void)closeResourceFile;

@end


