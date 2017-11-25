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
	HKArchiveFileTypeNone		= 0,
	HKArchiveFileTypeBSP		= 1,
	HKArchiveFileTypeGCF		= 2,
	HKArchiveFileTypePAK		= 3,
	HKArchiveFileTypeVBSP		= 4,
	HKArchiveFileTypeWAD		= 5,
	HKArchiveFileTypeXZP		= 6,
	HKArchiveFileTypeZIP		= 7,
	HKArchiveFileTypeNCF		= 8,
	HKArchiveFileTypeVPK		= 9,
	HKArchiveFileTypeSGA		= 10,
	
};
static const HKArchiveFileType HKArchiveFileNoType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeNone", macosx(10.0, 10.2)) = HKArchiveFileTypeNone;
static const HKArchiveFileType HKArchiveFileBSPType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeBSP", macosx(10.0, 10.2)) = HKArchiveFileTypeBSP;
static const HKArchiveFileType HKArchiveFileGCFType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeGCF", macosx(10.0, 10.2)) = HKArchiveFileTypeGCF;
static const HKArchiveFileType HKArchiveFilePAKType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypePAK", macosx(10.0, 10.2)) = HKArchiveFileTypePAK;
static const HKArchiveFileType HKArchiveFileVBSPType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeVBSP", macosx(10.0, 10.2)) = HKArchiveFileTypeVBSP;
static const HKArchiveFileType HKArchiveFileWADType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeWAD", macosx(10.0, 10.2)) = HKArchiveFileTypeWAD;
static const HKArchiveFileType HKArchiveFileXZPType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeXZP", macosx(10.0, 10.2)) = HKArchiveFileTypeXZP;
static const HKArchiveFileType HKArchiveFileZIPType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeZIP", macosx(10.0, 10.2)) = HKArchiveFileTypeZIP;
static const HKArchiveFileType HKArchiveFileNCFType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeNCF", macosx(10.0, 10.2)) = HKArchiveFileTypeNCF;
static const HKArchiveFileType HKArchiveFileVPKType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeVPK", macosx(10.0, 10.2)) = HKArchiveFileTypeVPK;
static const HKArchiveFileType HKArchiveFileSGAType API_DEPRECATED_WITH_REPLACEMENT("HKArchiveFileTypeSGA", macosx(10.0, 10.2)) = HKArchiveFileTypeSGA;


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
