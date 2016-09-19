//
//  MDCopyOperation.h
//  Source Finagler
//
//  Created by Mark Douma on 9/7/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MDHLDocument.h"

NS_ASSUME_NONNULL_BEGIN

@class HKItem;

extern NSString * const MDCopyOperationKey;
extern NSString * const MDCopyOperationDestinationKey;
extern NSString * const MDCopyOperationTotalBytesKey;
extern NSString * const MDCopyOperationCurrentBytesKey;
extern NSString * const MDCopyOperationTotalItemCountKey;
extern NSString * const MDCopyOperationCurrentItemIndexKey;
extern NSString * const MDCopyOperationTagKey;

extern NSString * const MDCopyOperationStageKey;

typedef NS_ENUM(NSUInteger, MDCopyOperationStage) {
	MDCopyOperationStagePreparing		= 1,
	MDCopyOperationStageCopying			= 2,
	MDCopyOperationStageFinishing		= 3,
	MDCopyOperationStageCancelled		= 4
};

@interface MDCopyOperation : NSObject {
	double							zeroBytes;
	double							currentBytes;
	double							totalBytes;
	
	NSString						*messageText;
	NSString						*informativeText;
	
	NSImage							*icon;
	
	MDHLDocument					*__weak source;
	id								destination; ///< can be \c MDHLDocument or an \c NSString (path)
	
	NSDictionary					*itemsAndPaths;
	
	NSInteger						tag;
	
	BOOL							isRolledOver;
	
	BOOL							indeterminate;
	
	BOOL							isCancelled;
}

+ (instancetype)operationWithSource:(MDHLDocument *)aSource destination:(id)aDestination itemsAndPaths:(NSDictionary<NSString*,HKItem*> *)anItemsAndPaths tag:(NSInteger)aTag;

- (instancetype)initWithSource:(MDHLDocument *)aSource destination:(id)aDestination itemsAndPaths:(NSDictionary<NSString*,HKItem*> *)anItemsAndPaths tag:(NSInteger)aTag NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (assign, getter=isIndeterminate) BOOL indeterminate;
@property (assign, getter=isRolledOver) BOOL rolledOver;

@property (assign, getter=isCancelled)	BOOL cancelled;

@property (assign) double zeroBytes;
@property (assign) double currentBytes;
@property (assign) double totalBytes;


@property (copy) NSString *messageText;
@property (copy) NSString *informativeText;

@property (strong) NSImage *icon;

@property (readonly, weak) MDHLDocument *source;
//! can be \c MDHLDocument or an \c NSString (path)
@property (readonly, strong) id destination;
@property (readonly, strong) NSDictionary<NSString*,HKItem*> *itemsAndPaths;

@property (readonly, assign) NSInteger tag;

@end

NS_ASSUME_NONNULL_END
