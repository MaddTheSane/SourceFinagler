//
//  MDImageTextCell.m
//  Source Finagler
//
//  Created by Mark Douma on 6/28/2005.
//  Copyright 2005 Mark Douma. All rights reserved.
//


#import "MDImageTextCell.h"


#define MD_INSET_HORIZ		6.0		/* Distance image icon is inset from the left edge */
#define MD_INTER_SPACE		4.0		/* Distance between right edge of icon image and left edge of text */
#define MD_BOTTOM_PADDING	1.0		/* Distance between bottom of image and bottom of cell */


#define MD_DEBUG 0


@implementation MDImageTextCell

@synthesize image;

- (instancetype)init {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super init])) {
		self.lineBreakMode = NSLineBreakByTruncatingMiddle;
	}
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	MDImageTextCell *cell = (MDImageTextCell *)[super copyWithZone:zone];
	cell->image = nil;
	cell.image = image;
	return cell;
}

- (NSRect)imageRectForBounds:(NSRect)bounds {
#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	bounds.origin.x += MD_INSET_HORIZ;
//	NSImage *image = [self image];
#if MD_DEBUG
//	NSLog(@"[%@ %@] image == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), image);
#endif
	
	NSSize imageSize = self.image.size;
	bounds.size.width = imageSize.width;
	bounds.size.height = imageSize.height;
	bounds.origin.y += trunc((bounds.size.height - imageSize.height) / 2.0);
	return bounds;
}


- (NSRect)titleRectForBounds:(NSRect)bounds {
#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSSize imageSize = self.image.size;
	bounds.origin.x += (MD_INSET_HORIZ + imageSize.width + MD_INTER_SPACE);
	bounds.size.width -= (MD_INSET_HORIZ + imageSize.width + MD_INTER_SPACE);
	return [super titleRectForBounds:bounds];
}


- (NSSize)cellSizeForBounds:(NSRect)aRect {
#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSSize cellSize = [super cellSizeForBounds:aRect];
	NSSize imageSize = self.image.size;
	cellSize.width += (MD_INSET_HORIZ + imageSize.width + MD_INTER_SPACE);
	cellSize.height = (MD_BOTTOM_PADDING + imageSize.height);
	return cellSize;
}



- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSRect imageRect = [self imageRectForBounds:cellFrame];
	NSSize imageSize = self.image.size;
	if (self.image) {
//		NSLog(@"[%@ %@] drawing image", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		[self.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	}
	CGFloat inset = (MD_INSET_HORIZ + imageSize.width + MD_INTER_SPACE);
	cellFrame.origin.x += inset;
	cellFrame.size.width -= inset;
	cellFrame.origin.y += 1.0; // looks better ?
	cellFrame.size.height -= 1.0;
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
