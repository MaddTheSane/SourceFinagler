//
//  HKArchiveFile.h
//  HLKit
//
//  Created by Mark Douma on 4/27/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//


#import <Foundation/Foundation.h>


@class HKItem, HKFolder;

typedef NS_ENUM(NSUInteger, HKArchiveFileType) {
	HKArchiveFileNoType			= 0,
	HKArchiveFileBSPType		= 1,
	HKArchiveFileGCFType		= 2,
	HKArchiveFilePAKType		= 3,
	HKArchiveFileVBSPType		= 4,
	HKArchiveFileWADType		= 5,
	HKArchiveFileXZPType		= 6,
	HKArchiveFileZIPType		= 7,
	HKArchiveFileNCFType		= 8,
	HKArchiveFileVPKType		= 9,
	HKArchiveFileSGAType		= 10
};


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

NS_ASSUME_NONNULL_BEGIN

+ (HKArchiveFileType)fileTypeForData:(NSData *)aData;


- (nullable instancetype)initWithContentsOfFile:(NSString *)aPath;
- (nullable instancetype)initWithContentsOfFile:(NSString *)aPath showInvisibleItems:(BOOL)showInvisibleItems sortDescriptors:(nullable NSArray<NSSortDescriptor*> *)sortDescriptors error:(NSError *__nullable*__nullable)outError;


@property (copy, readonly) NSString *filePath;

@property (nonatomic, readonly, assign) HKArchiveFileType fileType;

@property (nonatomic, readonly, assign, getter=isReadOnly) BOOL readOnly;
@property (nonatomic, readonly, assign) BOOL haveGatheredAllItems;


@property (copy, nullable) NSString *version;


@property (readonly, strong) HKFolder *items;
- (nullable HKItem *)itemAtPath:(NSString *)aPath;

@property (readonly, copy) NSArray<HKItem*> *allItems;

@end

NS_ASSUME_NONNULL_END
