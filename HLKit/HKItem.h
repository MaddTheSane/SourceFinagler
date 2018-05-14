//
//  HKItem.h
//  HLKit
//
//  Created by Mark Douma on 11/20/2009.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKNode.h>
#import <HLKit/HLKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

HLKIT_EXTERN NSErrorDomain const HKErrorDomain;
HLKIT_EXTERN NSErrorUserInfoKey const HKErrorMessageKey;
HLKIT_EXTERN NSErrorUserInfoKey const HKSystemErrorMessageKey;


typedef NS_ERROR_ENUM(HKErrorDomain, HKErrors) {
	HKErrorNotExtractable = 1
};

typedef NS_ENUM(NSUInteger, HKFileType) {
	HKFileTypeNone				= 0,
	HKFileTypeHTML				= 1,
	HKFileTypeText				= 2,
	HKFileTypeImage				= 3,
	HKFileTypeSound				= 4,
	HKFileTypeMovie				= 5,
	HKFileTypeOther				= 6,
	HKFileTypeNotExtractable	= 7
};


@interface HKItem : HKNode {
	NSString			*name;
	NSString			*nameExtension;
	NSString			*kind;
	NSNumber			*size;
	
	NSString			*path;
	
	// for images
	NSString			*dimensions;
	NSString			*version;
	NSString			*compression;
	NSString			*hasAlpha;
	NSString			*hasMipmaps;
	
	
	NSString			*type; //!< UTI
	HKFileType			fileType;
	
	BOOL				isExtractable;
	BOOL				isEncrypted;
	
}

+ (NSImage *)iconForItem:(HKItem *)anItem;
+ (NSImage *)copiedImageForItem:(HKItem *)anItem;

- (BOOL)writeToFile:(NSString *)aPath assureUniqueFilename:(BOOL)assureUniqueFilename resultingPath:(NSString *__nullable*__nullable)resultingPath error:(NSError **)outError;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nameExtension;
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSNumber *size;

@property (nonatomic, copy, nullable) NSString *path;

//! UTI
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *dimensions;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *compression;
@property (nonatomic, copy, setter=setAlpha:) NSString *hasAlpha;
@property (nonatomic, copy) NSString *hasMipmaps;

@property (nonatomic, assign, getter=isExtractable) BOOL extractable;
@property (nonatomic, assign, getter=isEncrypted) BOOL encrypted;
@property (nonatomic, assign) HKFileType fileType;


- (NSString *)pathRelativeToItem:(HKItem *)anItem;

@property (readonly, copy) NSArray<HKItem*> *descendants;
@property (readonly, copy) NSArray<HKItem*> *visibleDescendants;

//- (id)parentFromArray:(NSArray *)array;
//- (NSIndexPath *)indexPathInArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
