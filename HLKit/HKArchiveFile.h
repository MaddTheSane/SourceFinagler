//
//  HKArchiveFile.h
//  Source Finagler
//
//  Created by Mark Douma on 4/27/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//


#import <Foundation/Foundation.h>


@class HKItem, HKFolder;

enum {
	HKArchiveFileNoType			= 0,
	HKArchiveFileBSPType		= 1,
	HKArchiveFileGCFType		= 2,
	HKArchiveFilePAKType		= 3,
	HKArchiveFileVBSPType		= 4,
	HKArchiveFileWADType		= 5,
	HKArchiveFileXZPType		= 6,
	HKArchiveFileZIPType		= 7,
	HKArchiveFileNCFType		= 8,
	HKArchiveFileVPKType		= 9
};
typedef NSUInteger HKArchiveFileType;


@interface HKArchiveFile : NSObject {
	
	NSString				*filePath;
	
	HKFolder				*items;
	NSMutableArray			*allItems;
	
	NSString				*version;
	
	HKArchiveFileType		fileType;
	
	BOOL					haveGatheredAllItems;
	
	BOOL					isReadOnly;
	
@protected
	void *_privateData;
	
}

+ (HKArchiveFileType)fileTypeForData:(NSData *)aData;


- (id)initWithContentsOfFile:(NSString *)aPath;
- (id)initWithContentsOfFile:(NSString *)aPath showInvisibleItems:(BOOL)showInvisibleItems sortDescriptors:(NSArray *)sortDescriptors error:(NSError **)outError;


@property (retain, readonly) NSString *filePath;

@property (assign, readonly) HKArchiveFileType fileType;

@property (assign, readonly) BOOL isReadOnly;
@property (assign, readonly) BOOL haveGatheredAllItems;


@property (retain) NSString *version;


- (HKFolder *)items;
- (HKItem *)itemAtPath:(NSString *)aPath;

- (NSArray *)allItems;


@end


