//
//  HKNode.h
//  HLKit
//
//  Created by Mark Douma on 9/2/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HKNode : NSObject {
	__unsafe_unretained id container;	// not retained
	
	__unsafe_unretained HKNode *parent;	// not retained

    NSMutableArray		*childNodes;
	NSMutableArray		*visibleChildNodes;
	
	NSArray				*sortDescriptors;
	
	BOOL				isLeaf;
	
	BOOL				isVisible;
	BOOL				showInvisibleItems;	
}

- (instancetype)initWithParent:(HKNode *)aParent childNodes:(NSArray<HKNode*> *)theChildren sortDescriptors:(NSArray<NSSortDescriptor*> *)aSortDescriptors container:(id)aContainer NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) id container;
@property (nonatomic, assign) HKNode *parent;
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, assign) BOOL showInvisibleItems;
@property (nonatomic, assign, getter=isLeaf) BOOL leaf;

@property (nonatomic, copy) NSArray<NSSortDescriptor*> *sortDescriptors;

@property (nonatomic, assign, readonly, getter=isRootNode) BOOL rootNode;


- (void)insertChildNode:(HKNode *)child atIndex:(NSUInteger)index;
- (void)insertChildNodes:(NSArray *)newChildren atIndex:(NSUInteger)index;
- (void)removeChildNode:(HKNode *)child;
- (void)removeFromParent;

- (NSUInteger)indexOfChildNode:(HKNode *)child;
- (NSUInteger)indexOfChildNodeIdenticalTo:(HKNode *)child;

@property (readonly) NSUInteger countOfChildNodes;
@property (readonly, copy) NSArray<HKNode *> *childNodes;
- (HKNode *)childNodeAtIndex:(NSUInteger)index;

@property (readonly) NSUInteger countOfVisibleChildNodes;
@property (readonly, copy) NSArray<HKNode *> *visibleChildNodes;
- (HKNode *)visibleChildNodeAtIndex:(NSUInteger)index;


- (BOOL)isContainedInNodes:(NSArray<HKNode*> *)nodes;
- (BOOL)isDescendantOfNodes:(NSArray<HKNode*> *)nodes;

- (BOOL)isDescendantOfNode:(HKNode *)node;

- (void)setSortDescriptors:(NSArray<NSSortDescriptor*> *)aSortDescriptors recursively:(BOOL)recursively;

- (void)recursiveSortChildren;

- (void)initializeChildrenIfNeeded;

@end

