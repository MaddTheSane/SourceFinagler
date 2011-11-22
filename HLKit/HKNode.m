//
//  HKNode.m
//  Source Finagler
//
//  Created by Mark Douma on 9/2/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKNode.h>
#import <HLKit/HKFoundationAdditions.h>


#define HK_DEBUG 0

@interface HKNode (HKPrivate)
- (BOOL)isDescendantOfNodeOrIsEqualToNode:(HKNode *)node;
@end


@implementation HKNode

@synthesize container, parent, isVisible, isLeaf, sortDescriptors;
@dynamic showInvisibleItems;

- (id)initWithParent:(HKNode *)aParent children:(NSArray *)theChildren sortDescriptors:(NSArray *)aSortDescriptors container:(id)aContainer {
	if ((self = [super init])) {
		parent = aParent;
		container = aContainer;
		isVisible = YES;
		showInvisibleItems = NO;
		
		sortDescriptors = [aSortDescriptors retain];
		
		if (theChildren) {
			children = [[NSMutableArray arrayWithArray:theChildren] retain];
			visibleChildren = [[NSMutableArray alloc] init];
			for (HKNode *child in children) {
				if ([child isVisible]) [visibleChildren addObject:child];
			}
			[children makeObjectsPerformSelector:@selector(setParent:) withObject:self];
			
			[children sortUsingDescriptors:sortDescriptors];
			[visibleChildren sortUsingDescriptors:sortDescriptors];
		}
	}
	return self;
}


- (void)dealloc {
	container = nil;
	parent = nil;
    [children release];
	[visibleChildren release];
	[sortDescriptors release];
    [super dealloc];
}

- (BOOL)isRootNode {
	return (parent == nil);
}


- (void)setNilValueForKey:(NSString *)key {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ([key isEqualToString:@"isLeaf"]) {
		isLeaf = NO;
	} else if ([key isEqualToString:@"isVisible"]) {
		isVisible = NO;
	} else if ([key isEqualToString:@"showInvisibleItems"]) {
		showInvisibleItems = NO;
	} else {
		[super setNilValueForKey:key];
	}
}


- (void)initializeChildrenIfNeeded {
	if (children == nil && visibleChildren == nil) {
		children = [[NSMutableArray alloc] init];
		visibleChildren = [[NSMutableArray alloc] init];
	}
}


- (void)insertChild:(HKNode *)child atIndex:(NSUInteger)index {
	[self initializeChildrenIfNeeded];
	
	[child setParent:self];
	
    [children insertObject:child atIndex:index];
	[children sortUsingDescriptors:sortDescriptors];
	
	if ([child isVisible]) {
		[visibleChildren addObject:child];
		[visibleChildren sortUsingDescriptors:sortDescriptors];
	}
}



- (void)insertChildren:(NSArray *)newChildren atIndex:(NSUInteger)index {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	[self initializeChildrenIfNeeded];

	[newChildren makeObjectsPerformSelector:@selector(setParent:) withObject:self];
	
    [children insertObjectsFromArray:newChildren atIndex:index];
	
	for (HKNode *child in children) {
		if ([child isVisible]) {
			[visibleChildren addObject:child];
		}
	}
	
	[children sortUsingDescriptors:sortDescriptors];
	[visibleChildren sortUsingDescriptors:sortDescriptors];
	
}


- (void)_removeChildrenIdenticalTo:(NSArray *)theChildren {
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	[theChildren makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
	for (HKNode *child in theChildren) {
		[children removeObjectIdenticalTo:child];
		[visibleChildren removeObjectIdenticalTo:child];
	}
}


- (void)removeChild:(HKNode *)child {
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSUInteger index = [self indexOfChild:child];
    if (index != NSNotFound) {
        [self _removeChildrenIdenticalTo:[NSArray arrayWithObject:[self childAtIndex:index]]];
    }
}

- (void)removeFromParent {
    [parent removeChild:self];
}

- (NSUInteger)indexOfChild:(HKNode *)child {
    return [children indexOfObject:child];
}

- (NSUInteger)indexOfChildIdenticalTo:(HKNode *)child {
    return [children indexOfObjectIdenticalTo:child];
}

- (NSUInteger)countOfChildren {
    return [children count];
}

- (NSArray *)children {
	return [[children copy] autorelease];
}

- (HKNode *)childAtIndex:(NSUInteger)index {
    return [children objectAtIndex:index];
}


- (NSUInteger)countOfVisibleChildren {
	return [visibleChildren count];
}

- (NSArray *)visibleChildren {
	return [[visibleChildren copy] autorelease];
}


- (HKNode *)visibleChildAtIndex:(NSUInteger)index {
	return [visibleChildren objectAtIndex:index];
}



// -------------------------------------------------------------------------------
//	Returns YES if self is contained anywhere inside the children or children of
//	sub-nodes of the nodes contained inside the given array.
// -------------------------------------------------------------------------------
- (BOOL)isContainedInNodes:(NSArray *)nodes {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	// returns YES if we are contained anywhere inside the array passed in, including inside sub-nodes
	
	for (HKNode *node in nodes) {
		if (node == self) {
			return YES;             // we found ourselves
		}
		// check all the sub-nodes
		if (![node isLeaf]) {
			if ([self isContainedInNodes:[node children]]) {
				return YES;
			}
		}
	}
	return NO;
}

// -------------------------------------------------------------------------------
//	Returns YES if any node in the array passed in is an ancestor of ours.
// -------------------------------------------------------------------------------
- (BOOL)isDescendantOfNodes:(NSArray *)nodes {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	for (HKNode *node in nodes) {
		// check all the sub-nodes
		if (![node isLeaf]) {
			if ([self isContainedInNodes:[node children]]) {
				return YES;
			}
		}
	}
	return NO;
}



- (BOOL)isDescendantOfNodeOrIsEqualToNode:(HKNode *)node {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (node == self) {
		return YES;
	}
	if (![node isLeaf]) {
		if ([parent isDescendantOfNodeOrIsEqualToNode:node]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL)isDescendantOfNode:(HKNode *)node {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (![node isLeaf]) {
		if ([parent isDescendantOfNodeOrIsEqualToNode:node]) {
			return YES;
		}
	}
	return NO;
}


- (void)setShowInvisibleItems:(BOOL)value {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	showInvisibleItems = value;
	if (!isLeaf && children) {
		for (HKNode *child in children) {
			if (![child isLeaf]) [child setShowInvisibleItems:showInvisibleItems];
		}
	}
}

- (BOOL)showInvisibleItems {
#if HK_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return showInvisibleItems;
}


- (void)setSortDescriptors:(NSArray *)aSortDescriptors {
#if HK_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return [self setSortDescriptors:aSortDescriptors recursively:YES];
}


- (void)setSortDescriptors:(NSArray *)aSortDescriptors recursively:(BOOL)recursively {
#if HK_DEBUG
	NSLog(@"[%@ %@] aSortDescriptors == %@, recursively == %@; sortDescriptors == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), aSortDescriptors, recursively ? @"YES" : @"NO", sortDescriptors);
#endif
	
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	if (!isLeaf) {
		[aSortDescriptors retain];
		[sortDescriptors release];
		sortDescriptors = aSortDescriptors;
		
		if (children && recursively) {
			[children makeObjectsPerformSelector:@selector(setSortDescriptors:) withObject:sortDescriptors];
		}
	}
}


- (void)recursiveSortChildren {
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	if (!isLeaf) {
		if (children) {
#if HK_DEBUG
//		NSLog(@"[%@ %@] children (before) == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), children);
#endif
			
			[children sortUsingDescriptors:sortDescriptors];
			[visibleChildren sortUsingDescriptors:sortDescriptors];
			
#if HK_DEBUG
//			NSLog(@"[%@ %@] children (after) == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), children);
#endif
			
			[children makeObjectsPerformSelector:@selector(recursiveSortChildren)];
		}
	}
}


@end



