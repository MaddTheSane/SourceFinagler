//
//  HKNode.h
//  HLKit
//
//  Created by Mark Douma on 9/2/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HKNode : NSObject {
	__weak id container;	// not retained
	
	__weak HKNode *parent;	// not retained

    NSMutableArray		*childNodes;
	NSMutableArray		*visibleChildNodes;
	
	NSArray				*sortDescriptors;
	
	BOOL				isLeaf;
	
	BOOL				isVisible;
	BOOL				showInvisibleItems;	
}

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithParent:(nullable HKNode *)aParent childNodes:(nullable NSArray<HKNode*> *)theChildren sortDescriptors:(nullable NSArray<NSSortDescriptor*> *)aSortDescriptors container:(nullable id)aContainer NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak, nullable) id container;
@property (nonatomic, weak, nullable) HKNode *parent;
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, assign) BOOL showInvisibleItems;
@property (nonatomic, assign, getter=isLeaf) BOOL leaf;

@property (nonatomic, copy) NSArray<NSSortDescriptor*> *sortDescriptors;

@property (nonatomic, assign, readonly, getter=isRootNode) BOOL rootNode;


- (void)insertChildNode:(HKNode *)child atIndex:(NSInteger)index;
- (void)insertChildNodes:(NSArray<HKNode*> *)newChildren atIndex:(NSInteger)index;
- (void)removeChildNode:(HKNode *)child;
- (void)removeFromParent;

- (NSInteger)indexOfChildNode:(HKNode *)child;
- (NSInteger)indexOfChildNodeIdenticalTo:(HKNode *)child;

@property (readonly) NSInteger countOfChildNodes;
@property (readonly, copy) NSArray<HKNode *> *childNodes;
- (HKNode *)childNodeAtIndex:(NSInteger)index;

@property (readonly) NSInteger countOfVisibleChildNodes;
@property (readonly, copy) NSArray<HKNode *> *visibleChildNodes;
- (HKNode *)visibleChildNodeAtIndex:(NSInteger)index;


- (BOOL)isContainedInNodes:(NSArray<HKNode*> *)nodes;
- (BOOL)isDescendantOfNodes:(NSArray<HKNode*> *)nodes;

- (BOOL)isDescendantOfNode:(HKNode *)node;

- (void)setSortDescriptors:(NSArray<NSSortDescriptor*> *)aSortDescriptors recursively:(BOOL)recursively;

- (void)recursiveSortChildren;

- (void)initializeChildrenIfNeeded;

@end

NS_ASSUME_NONNULL_END
