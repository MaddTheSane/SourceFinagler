//
//  HKFolder.h
//  HLKit
//
//  Created by Mark Douma on 9/1/2010.
//  Copyright (c) 2009-2012 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKItem.h>


@interface HKFolder : HKItem {
	NSUInteger			countOfVisibleChildNodes;
}

- (HKItem *)descendantAtPath:(NSString *)aPath;

- (NSDictionary<NSString*,HKItem*> *)visibleDescendantsAndPathsRelativeToItem:(HKItem *)parentItem;

@end
