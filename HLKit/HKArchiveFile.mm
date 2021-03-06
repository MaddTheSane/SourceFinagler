//
//  HKArchiveFile.m
//  HLKit
//
//  Created by Mark Douma on 4/27/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKArchiveFile.h>
#import <HLKit/HKFile.h>
#import <HLKit/HKFolder.h>
#import <HL/HL.h>
#import "HKPrivateInterfaces.h"


using namespace HLLib;

#define HK_DEBUG 0

#define HK_DEFAULT_PACKAGE_TEST_LENGTH 8


typedef struct HKArchiveFileTest {
	HKArchiveFileType	fileType;
	NSUInteger			testDataLength;
	unsigned char		testData[HK_DEFAULT_PACKAGE_TEST_LENGTH];
} HKArchiveFileTest;


static HKArchiveFileTest HKArchiveFileTestTable[] = {
	{ HKArchiveFileTypeBSP, 4, { 0x1e, 0x00, 0x00, 0x00 } },
	{ HKArchiveFileTypeGCF, 8, { 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00 } },
	{ HKArchiveFileTypeNCF, 8, { 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00 } },
	{ HKArchiveFileTypePAK, 4, { 'P', 'A', 'C', 'K' } },
	{ HKArchiveFileTypeSGA, 8, { '_', 'A', 'R', 'C', 'H', 'I', 'V', 'E' } },
	{ HKArchiveFileTypeVBSP, 4, { 'V', 'B', 'S', 'P' } },
	{ HKArchiveFileTypeVPK, 4, { 0x34, 0x12, 0xaa, 0x55} },
	{ HKArchiveFileTypeWAD, 4, { 'W', 'A', 'D', '3' } },
	{ HKArchiveFileTypeXZP, 4, { 'p', 'i', 'Z', 'x' } },
	{ HKArchiveFileTypeZIP, 2, { 'P', 'K' } },
	{ HKArchiveFileTypeNone, 0, { } }
};


@implementation HKArchiveFile
@synthesize filePath;
@synthesize fileType;
@synthesize haveGatheredAllItems;
@synthesize readOnly=isReadOnly;
@synthesize version;


+ (HKArchiveFileType)fileTypeForData:(NSData *)aData {
#if HK_DEBUG
	NSLog(@"[%@ %@] aData == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), aData);
#endif
	NSUInteger dataLength = aData.length;
	if (dataLength == 0) {
		return HKArchiveFileTypeNone;
	}
	for (HKArchiveFileTest *packageTest = HKArchiveFileTestTable; packageTest->fileType != HKArchiveFileTypeNone; packageTest++) {
		if (packageTest->testDataLength <= dataLength && memcmp(aData.bytes, packageTest->testData, packageTest->testDataLength) == 0) {
			return packageTest->fileType;
		}
	}
	return HKArchiveFileTypeNone;
}


- (instancetype)initWithContentsOfFile:(NSString *)aPath {
//	return [self initWithContentsOfFile:aPath mode:HL_MODE_READ | HL_MODE_VOLATILE | HL_MODE_QUICK_FILEMAPPING showInvisibleItems:YES sortDescriptors:nil error:NULL];
	return [self initWithContentsOfFile:aPath mode:HL_MODE_READ | HL_MODE_VOLATILE showInvisibleItems:YES sortDescriptors:nil error:NULL];
}

- (instancetype)initWithContentsOfFile:(NSString *)aPath showInvisibleItems:(BOOL)showInvisibleItems sortDescriptors:(NSArray *)sortDescriptors  error:(NSError **)outError {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
//	return [self initWithContentsOfFile:aPath mode:HL_MODE_READ | HL_MODE_VOLATILE | HL_MODE_QUICK_FILEMAPPING showInvisibleItems:showInvisibleItems sortDescriptors:sortDescriptors error:outError];
	return [self initWithContentsOfFile:aPath mode:HL_MODE_READ | HL_MODE_VOLATILE showInvisibleItems:showInvisibleItems sortDescriptors:sortDescriptors error:outError];
}


- (instancetype)initWithContentsOfFile:(NSString *)aPath mode:(HLFileMode)permission showInvisibleItems:(BOOL)showInvisibleItems sortDescriptors:(NSArray *)sortDescriptors error:(NSError **)outError {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (aPath == nil) {
		NSLog(@"[%@ %@] path == nil!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return nil;
	}
	
	if ((self = [super init])) {
		filePath = [aPath copy];
		_privateData = 0;
		haveGatheredAllItems = NO;
		isReadOnly = !(permission & HL_MODE_WRITE);
	}
	return self;
}

- (HKFolder *)items {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return items;
}

- (HKItem *)itemAtPath:(NSString *)path {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [[self items] descendantAtPath:path];
}

- (NSArray *)allItems {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	if (!haveGatheredAllItems) {
		NSDate *startDate = [NSDate date];
		NSMutableArray *gatheredItems;
		
		@autoreleasepool {
			gatheredItems = [[NSMutableArray alloc] initWithCapacity:items.childNodes.count];
			[gatheredItems addObject:items];
			
			NSArray *childNodes = items.childNodes;
			for (HKItem *item in childNodes) {
				[gatheredItems addObject:item];
				
				if (!item.leaf) {
					[gatheredItems addObjectsFromArray:item.descendants];
				}
			}
			allItems = [gatheredItems copy];
		}
		
		haveGatheredAllItems = YES;
		
		NSLog(@"[%@ %@] ****** TIME to gather allItems == %.7f sec, gatheredItems count == %lu, allItems count == %lu", NSStringFromClass([self class]), NSStringFromSelector(_cmd), fabs(startDate.timeIntervalSinceNow), (unsigned long)gatheredItems.count, (unsigned long)allItems.count);
		
		startDate = nil;
	}
	return allItems;
}

@end
