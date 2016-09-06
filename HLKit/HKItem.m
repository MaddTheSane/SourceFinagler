//  HKItem.m
//  HLKit
//
//  Created by Mark Douma on 11/20/2009.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

//  Based, in part, on "TreeNode":

/*
    TreeNode.m
    Copyright (c) 2001-2006, Apple Computer, Inc., all rights reserved.
    Author: Chuck Pisula

    Milestones:
    * 03-01-2001: Initial creation by Chuck Pisula
    * 02-17-2006: Cleaned up the code. Corbin Dunn.

    Generic Tree node structure (TreeNode).
    
    TreeNode is a node in a doubly linked tree data structure.  TreeNode's have weak references to their parent (to avoid retain 
    cycles since parents retain their children).  Each node has 0 or more children and a reference to a piece of node data. The TreeNode provides method to manipulate and extract structural information about a tree.  For instance, TreeNode implements: insertChild:atIndex:, removeChild:, isDescendantOfNode:, and other useful operations on tree nodes.
    TreeNode provides the structure and common functionality of trees and is expected to be subclassed.
*/

/*
 IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc. ("Apple") in
 consideration of your agreement to the following terms, and your use, installation, 
 modification or redistribution of this Apple software constitutes acceptance of these 
 terms.  If you do not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject to these 
 terms, Apple grants you a personal, non-exclusive license, under Apple’s copyrights in 
 this original Apple software (the "Apple Software"), to use, reproduce, modify and 
 redistribute the Apple Software, with or without modifications, in source and/or binary 
 forms; provided that if you redistribute the Apple Software in its entirety and without 
 modifications, you must retain this notice and the following text and disclaimers in all 
 such redistributions of the Apple Software.  Neither the name, trademarks, service marks 
 or logos of Apple Computer, Inc. may be used to endorse or promote products derived from 
 the Apple Software without specific prior written permission from Apple. Except as expressly
 stated in this notice, no other rights or licenses, express or implied, are granted by Apple
 herein, including but not limited to any patent rights that may be infringed by your 
 derivative works or by other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO WARRANTIES, 
 EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, 
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS 
 USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL 
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, 
 REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND 
 WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR 
 OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import <HLKit/HKItem.h>
#import "HKFoundationAdditions.h"
#import <HLKit/HKArchiveFile.h>

#define HK_DEBUG 0

NSString * const HKErrorDomain				= @"HKErrorDomain";
NSString * const HKErrorMessageKey			= @"HKErrorMessage";
NSString * const HKSystemErrorMessageKey	= @"HKSystemErrorMessage";

static BOOL iconsInitialized = NO;
static NSImage *folderImage = nil;
static NSImage *fileImage = nil;
static NSMutableDictionary *icons = nil;

static void HKInitializeIcons() {
	if (iconsInitialized == NO) {
		icons = [[NSMutableDictionary alloc] init];
		if (folderImage == nil) {
			folderImage = [[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)] retain];
		}
		if (fileImage == nil) {
			fileImage = [[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericDocumentIcon)] retain];
		}
		iconsInitialized = YES;
	}
}


@implementation HKItem


+ (void)initialize {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (iconsInitialized == NO) HKInitializeIcons();
}


+ (NSImage *)iconForItem:(HKItem *)item {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSImage *image = nil;
	if ([item isLeaf]) {
		NSString *fileNameExtension = [item nameExtension];
		if ([fileNameExtension isEqualToString:@""]) {
			image = fileImage;
		} else {
			image = [icons objectForKey:fileNameExtension];
			if (image == nil) {
				image = [[NSWorkspace sharedWorkspace] iconForFileType:fileNameExtension];
				if (image) [icons setObject:image forKey:fileNameExtension];
			}
		}
	} else {
		return folderImage;
	}
	return image;
}



+ (NSImage *)copiedImageForItem:(HKItem *)anItem {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSImage *image = [[self class] iconForItem:anItem];
	NSImage *copiedImage = [[image copy] autorelease];
	return copiedImage;
}



@synthesize name, nameExtension, kind, size,
		type, isExtractable, isEncrypted,
		fileType, dimensions, version, compression,
		hasAlpha, hasMipmaps;

@dynamic path;

- (id)init {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self initWithParent:nil childNodes:nil sortDescriptors:nil container:nil];
}


- (id)initWithParent:(HKNode *)aParent childNodes:(NSArray *)theChildren sortDescriptors:(NSArray *)aSortDescriptors container:(id)aContainer {
	if ((self = [super initWithParent:aParent childNodes:theChildren sortDescriptors:aSortDescriptors container:aContainer])) {
		fileType = HKFileTypeNone;
	}
	return self;
}


- (void)dealloc {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[name release];
	[nameExtension release];
	[kind release];
	[size release];
	[path release];
	[type release];
	[dimensions release];
	[version release];
	[compression release];
	[hasAlpha release];
	[hasMipmaps release];
	[super dealloc];
}


- (NSString *)path {
	if (path) return path;
	if (parent && ![parent isRootNode]) {
		NSString *parentsPath = [(HKItem *)parent path];
		[self setPath:[parentsPath stringByAppendingPathComponent:name]];
		return path;
	}
	
	if (container) {
		[self setPath:[@"/" stringByAppendingPathComponent:name]];
		return path;
	}
	return nil;
}


- (void)setPath:(NSString *)aPath {
	NSString *copy = [aPath copy];
	[path release];
	path = copy;
}

- (NSString *)pathRelativeToItem:(HKItem *)referenceItem {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	if (parent == referenceItem) return name;
	
	NSString *relativePath = nil;
	
	HKItem *theItem = self;
	
	while ((theItem = (HKItem *)[theItem parent])) {
		if (theItem == referenceItem) {
			// **
			if (relativePath == nil) relativePath = name;
			break;
		}
		NSString *itemName = [theItem name];
		//**
		if (relativePath == nil) relativePath = name;
		
		if (itemName) relativePath = [itemName stringByAppendingPathComponent:relativePath];
	}
	return relativePath;
}


- (BOOL)writeToFile:(NSString *)aPath assureUniqueFilename:(BOOL)assureUniqueFilename resultingPath:(NSString **)resultingPath error:(NSError **)outError {
	NSLog(@"[%@ %@] (HKItem) subclasses must implement!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
													 reason:[NSString stringWithFormat:@"[%@ %@] (HKItem) subclasses must implement!", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]
												   userInfo:nil];
	[exception raise];
	return NO;
}


// -------------------------------------------------------------------------------
//	Override this for any non-object values
// -------------------------------------------------------------------------------
- (void)setNilValueForKey:(NSString *)key {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ([key isEqualToString:@"isExtractable"]) {
		isExtractable = NO;
	} else if ([key isEqualToString:@"isEncrypted"]) {
		isEncrypted = NO;
	} else if ([key isEqualToString:@"fileType"]) {
		fileType = HKFileTypeNone;
	} else {
		[super setNilValueForKey:key];
	}
}


// -------------------------------------------------------------------------------
//	Generates an array of all descendants.
// -------------------------------------------------------------------------------
- (NSArray *)descendants {
	NSLog(@"[%@ %@] (HKItem) subclasses must override!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
													 reason:[NSString stringWithFormat:@"[%@ %@] (HKItem) subclasses must implement!", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]
												   userInfo:nil];
	[exception raise];
	return nil;
}

- (NSArray *)visibleDescendants {
	NSLog(@"[%@ %@] subclasses must override!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
													 reason:[NSString stringWithFormat:@"[%@ %@] (HKItem) subclasses must implement!", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]
												   userInfo:nil];
	[exception raise];
	return nil;
}

//static NSString * const HKFileTypeDescription[] = {
//						@"HKFileTypeNone",
//						@"HKFileTypeHTML",
//						@"HKFileTypeText",
//						@"HKFileTypeImage",
//						@"HKFileTypeSound",
//						@"HKFileTypeMovie",
//						@"HKFileTypeOther",
//						@"HKFileTypeNotExtractable"
//};

- (NSString *)description {
//	NSMutableString *description = [NSMutableString stringWithString:[super description]];
	NSMutableString *description = [NSMutableString stringWithFormat:@"<%@> %@", NSStringFromClass([self class]), name];
//	[description appendFormat:@", %@", name];
//	[description appendFormat:@", %@", [self path]];
	
//	NSMutableString *description = [NSMutableString stringWithString:@"{\n"];
////	[description appendFormat:@"%@\n\t", [super description]];
//	[description appendFormat:@"\tname == %@\n", name];
//	[description appendFormat:@"\tpath == %@\n", [self path]];
////	if (!isLeaf) [description appendFormat:@"\tshowInvisibleItems == %@\n", (showInvisibleItems ? @"YES" : @"NO")];
////	if (!isLeaf) [description appendFormat:@"\tsortDescriptors == %@\n", sortDescriptors];
//	[description appendFormat:@"}\n"];
	
	
//	[description appendFormat:@"\n\tnameExtension == %@", nameExtension];
//	[description appendFormat:@"\n\tkind == %@", kind];
//	[description appendFormat:@"\n\tsize == %@", size];
//	[description appendFormat:@"\n\ttype == %@", type];
//	[description appendFormat:@"\n\fileType == %@", HKFileTypeDescription[fileType]];
//	[description appendFormat:@"\n\tisVisible == %@", (isVisible ? @"YES" : @"NO")];
	
	return description;
}


@end



// -------------------------------------------------------------------------------
//	Finds the receiver's parent from the nodes contained in the array.
// -------------------------------------------------------------------------------
//- (id)parentFromArray:(NSArray *)array {
//#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
//	id result = nil;
//	for (HKItem *node in array) {
//		if (node == self) {     // If we are in the root array, return nil
//			break;
//		}
//		if ([[node childNodes] containsObjectIdenticalTo:self]) {
//			result = node;
//			break;
//		}
//		if (![node isLeaf]) {
//			HKItem *innerNode = [self parentFromArray:[node childNodes]];
//			if (innerNode) {
//				result = innerNode;
//				break;
//			}
//		}
//	}
//
//	return result;
//}



// -------------------------------------------------------------------------------
//	Returns the index path of within the given array,
//	useful for drag and drop.
// -------------------------------------------------------------------------------
//- (NSIndexPath *)indexPathInArray:(NSArray *)array {
//#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
//	NSIndexPath	*indexPath = nil;
//	NSMutableArray  *reverseIndexes = [NSMutableArray array];
//	id aParent, doc = self;
//	NSInteger index;
//
//	while (aParent = [doc parentFromArray:array]) {
//		index = [[aParent childNodes] indexOfObjectIdenticalTo:doc];
//		if (index == NSNotFound) {
//			return nil;
//		}
//		[reverseIndexes addObject:[NSNumber numberWithInteger:index]];
//		doc = aParent;
//	}
//
//	// If parent is nil, we should just be in the parent array
//	index = [array indexOfObjectIdenticalTo:doc];
//	if (index == NSNotFound) {
//		return nil;
//	}
//	[reverseIndexes addObject:[NSNumber numberWithInteger:index]];
//
//	// Now build the index path
//	NSEnumerator *re = [reverseIndexes reverseObjectEnumerator];
//	NSNumber *indexNumber;
//	while (indexNumber = [re nextObject]) {
//		if (indexPath == nil) {
//			indexPath = [NSIndexPath indexPathWithIndex:[indexNumber integerValue]];
//		} else {
//			indexPath = [indexPath indexPathByAddingIndex:[indexNumber integerValue]];
//		}
//	}
//
//	return indexPath;
//}

