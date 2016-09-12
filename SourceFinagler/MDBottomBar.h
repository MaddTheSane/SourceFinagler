//
//  MDBottomBar.h
//  Source Finagler
//
//  Created by Mark Douma on 10/29/2008.
//  Copyright 2008 Mark Douma. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MDBottomBar : NSView {
	NSIndexSet				*selectedIndexes;
	NSNumber				*totalCount;
	NSNumber				*freeSpace;
	NSByteCountFormatter	*formatter;
}
- (void)setSelectedIndexes:(NSIndexSet *)anIndexSet totalCount:(NSNumber *)aTotalCount freeSpace:(NSNumber *)aFreeSpace;

@end
