//
//  HKFolder.mm
//  HLKit
//
//  Created by Mark Douma on 9/1/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKFolder.h>
#import <HLKit/HKFile.h>
#import <HLKit/HKFoundationAdditions.h>
#import <HL/HL.h>

#import "HKPrivateInterfaces.h"

using namespace HLLib;

#define HK_DEBUG 0

#define HK_LAZY_INIT 1

@interface HKFolder (Private)
- (void)populateChildrenIfNeeded;
@end


@implementation HKFolder
{
@private
	CDirectoryFolder *_privateData;
}

- (instancetype)initWithParent:(HKFolder *)aParent directoryFolder:(const CDirectoryFolder *)aFolder showInvisibleItems:(BOOL)showInvisibles sortDescriptors:(NSArray *)aSortDescriptors container:(id)aContainer {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super initWithParent:aParent childNodes:nil sortDescriptors:aSortDescriptors container:aContainer])) {
		_privateData = (CDirectoryFolder *)aFolder;
		isLeaf = NO;
		isExtractable = YES;
		isVisible = YES;
		size = @-1LL;
		countOfVisibleChildNodes = NSNotFound;
		self.showInvisibleItems = showInvisibles;
		
#if !(HK_LAZY_INIT)
		const hlChar *cName = _privateData->GetName();
		if (cName) name = [[NSString stringWithCString:cName encoding:NSUTF8StringEncoding] retain];
		nameExtension = [[name pathExtension] retain];
		kind = [NSLocalizedString(@"Folder", @"") retain];
		fileType = HKFileTypeOther;
#endif
	}
	return self;
}

#if (HK_LAZY_INIT)

- (NSString *)name {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (name == nil) {
		const hlChar *cName = _privateData->GetName();
		if (cName) name = @(cName);
	}
	return name;
}

- (NSString *)nameExtension {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (nameExtension == nil) nameExtension = self.name.pathExtension;
	return nameExtension;
}

//- (NSString *)type {
//#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
//	if (type == nil) {
//		type = (NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[self nameExtension], NULL);
//	}
//	return type;
//}

- (NSString *)kind {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (kind == nil) kind = NSLocalizedString(@"Folder", @"");
	return kind;
}


- (HKFileType)fileType {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (fileType == HKFileTypeNone) fileType = HKFileTypeOther;
	return fileType;
}

#endif


- (NSInteger)countOfChildNodes {
	return (NSUInteger)_privateData->GetCount();
}

- (NSInteger)countOfVisibleChildNodes {
	if (countOfVisibleChildNodes == NSNotFound) {
		countOfVisibleChildNodes = 0;
		NSUInteger numChildren = _privateData->GetCount();
		for (NSInteger i = 0; i < numChildren; i++) {
			CDirectoryItem *item = _privateData->GetItem(int(i));
			HLDirectoryItemType itemType = item->GetType();
			if (itemType == HL_ITEM_FOLDER) {
				countOfVisibleChildNodes++;
			} else if (itemType == HL_ITEM_FILE) {
				if (static_cast<const CDirectoryFile *>(item)->GetExtractable()) {
					countOfVisibleChildNodes++;
				}
			}
		}
	}
	return countOfVisibleChildNodes;
}

- (void)populateChildrenIfNeeded {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (childNodes == nil && visibleChildNodes == nil) {
		[self initializeChildrenIfNeeded];
		
		NSMutableArray *tempChildren = [[NSMutableArray alloc] init];
		
		hlUInt count = _privateData->GetCount();
		
		for (NSUInteger i = 0; i < count; i++) {
			const CDirectoryItem *item = _privateData->GetItem(int(i));
			HLDirectoryItemType itemType = item->GetType();
			
			HKItem *child = nil;
			
			if (itemType == HL_ITEM_FOLDER) {
				child = [[HKFolder alloc] initWithParent:self directoryFolder:static_cast<const CDirectoryFolder *>(item) showInvisibleItems:showInvisibleItems sortDescriptors:sortDescriptors container:container];
			} else if (itemType == HL_ITEM_FILE) {
				child = [[HKFile alloc] initWithParent:self directoryFile:static_cast<const CDirectoryFile *>(item) container:container];
			}
			if (child) {
				[tempChildren addObject:child];
			}
		}
		[self insertChildNodes:tempChildren atIndex:0];
	}
}

- (HKItem *)descendantAtPath:(NSString *)aPath {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (aPath == nil) return nil;
	
	[self populateChildrenIfNeeded];
	
	NSArray *pathComponents = aPath.pathComponents;
	
	NSMutableArray *revisedPathComponents = [NSMutableArray array];
	
	for (NSString *component in pathComponents) {
		if (![component isEqualToString:@"/"]) [revisedPathComponents addObject:component];
	}
	
#if HK_DEBUG
	NSMutableString *description = [NSMutableString stringWithString:@""];
	[description appendFormat:@"path == %@\n", aPath];
	[description appendFormat:@"pathComponents == %@\n", pathComponents];
	[description appendFormat:@"revisedPathComponents == %@\n", revisedPathComponents];
	NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), description);
#endif
	
	NSUInteger count = revisedPathComponents.count;
	
	if (count == 0)
		return nil;
	
	NSString *targetName = revisedPathComponents[0];
	NSString *remainingPath = nil;
	
	if (count > 1) remainingPath = [NSString pathWithComponents:[revisedPathComponents subarrayWithRange:NSMakeRange(1, (count - 1))]];
	
	for (HKItem *child in childNodes) {
		if ([child.name isEqualToString:targetName]) {
			if (remainingPath == nil) {
				return child;
			}
			// if there's remaining path left, and the child isn't a folder, then bail
			if (child.leaf) return nil;
			
			return [(HKFolder *)child descendantAtPath:remainingPath];
		}
	}
	
	return nil;
}

- (NSArray *)descendants {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self populateChildrenIfNeeded];
	
	NSMutableArray  *descendants = [[NSMutableArray alloc] init];
	
	for (HKItem *node in childNodes) {
		[descendants addObject:node];
		
		if (!node.leaf) {
			[descendants addObjectsFromArray:node.descendants];   // Recursive - will go down the chain to get all
		}
	}

	return descendants;
}

- (NSArray *)visibleDescendants {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self populateChildrenIfNeeded];
	
	NSMutableArray *visibleDescendants = [[NSMutableArray alloc] init];
	
	for (HKItem *node in visibleChildNodes) {
		[visibleDescendants addObject:node];
		if (!node.leaf) {
			[visibleDescendants addObjectsFromArray:node.visibleDescendants];	// Recursive - will go down the chain to get all
		}
	}
	
	return visibleDescendants;
}

- (NSDictionary *)visibleDescendantsAndPathsRelativeToItem:(HKItem *)parentItem {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSMutableDictionary *visibleDescendantsAndPaths = [[NSMutableDictionary alloc] init];
	
	NSArray *visibleDescendants = self.visibleDescendants;
	
	for (HKItem *item in visibleDescendants) {
		NSString *itemPath = [item pathRelativeToItem:parentItem];
		if (itemPath) {
			visibleDescendantsAndPaths[itemPath] = item;
		}
	}
	return [visibleDescendantsAndPaths copy];
}

- (HKNode *)childNodeAtIndex:(NSInteger)index {
	[self populateChildrenIfNeeded];
	return [super childNodeAtIndex:index];
}

- (HKNode *)visibleChildNodeAtIndex:(NSInteger)index {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self populateChildrenIfNeeded];
	return [super visibleChildNodeAtIndex:index];
}

- (NSArray *)childNodes {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self populateChildrenIfNeeded];
    return [childNodes copy];
}


- (NSArray *)visibleChildNodes {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self populateChildrenIfNeeded];
	return [visibleChildNodes copy];
}

- (BOOL)writeToFile:(NSString *)aPath assureUniqueFilename:(BOOL)assureUniqueFilename resultingPath:(NSString **)resultingPath error:(NSError **)outError {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (outError) *outError = nil;
	
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	if (![fileManager createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:outError]) {
		NSLog(@"[%@ %@] failed to create directory at %@!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), aPath);
		return NO;
	}
	if (resultingPath) *resultingPath = aPath;
	return YES;
	
}

@end
