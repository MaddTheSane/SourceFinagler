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
	
	HKArchiveFileNoType			NS_SWIFT_UNAVAILABLE("Use .none instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeNone instead") = 0,
	HKArchiveFileBSPType		NS_SWIFT_UNAVAILABLE("Use .BSP instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeBSP instead") = 1,
	HKArchiveFileGCFType		NS_SWIFT_UNAVAILABLE("Use .GCF instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeGCF instead") = 2,
	HKArchiveFilePAKType		NS_SWIFT_UNAVAILABLE("Use .PAK instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypePAK instead") = 3,
	HKArchiveFileVBSPType		NS_SWIFT_UNAVAILABLE("Use .VBSP instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeVBSP instead") = 4,
	HKArchiveFileWADType		NS_SWIFT_UNAVAILABLE("Use .WAD instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeWAD instead") = 5,
	HKArchiveFileXZPType		NS_SWIFT_UNAVAILABLE("Use .XYP instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeXZP instead") = 6,
	HKArchiveFileZIPType		NS_SWIFT_UNAVAILABLE("Use .ZIP instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeZIP instead") = 7,
	HKArchiveFileNCFType		NS_SWIFT_UNAVAILABLE("Use .NCF instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeNCF instead") = 8,
	HKArchiveFileVPKType		NS_SWIFT_UNAVAILABLE("Use .VPK instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeVPK instead") = 9,
	HKArchiveFileSGAType		NS_SWIFT_UNAVAILABLE("Use .SGA instead") DEPRECATED_MSG_ATTRIBUTE("Use HKArchiveFileTypeSGA instead") = 10
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
