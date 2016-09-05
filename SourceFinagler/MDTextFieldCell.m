//
//  MDTextFieldCell.m
//  Source Finagler
//
//  Created by Mark Douma on 1/31/2008.
//  Copyright © 2008 Mark Douma. All rights reserved.
//  


#import "MDTextFieldCell.h"


#define MD_LEFT_EDGE_PADDING 16.0
#define MD_INSET_HORIZ		16.0		/* Distance image icon is inset from the left edge */
#define MD_INTER_SPACE		6.0		/* Distance between right edge of icon image and left edge of text */

#define MD_DEBUG 1


@interface MDTextFieldCell (MDPrivate)

- (NSPoint)calculatedImagePointForFrame:(NSRect)cellFrame imageSize:(NSSize)imageSize isFlipped:(BOOL)isFlipped;

- (NSRect)calculatedRichTextRectForFrame:(NSRect)cellFrame richText:(NSAttributedString *)richText fontSize:(CGFloat)fontSize imageSize:(NSSize)imageSize isFlipped:(BOOL)isFlipped;

@end


@implementation MDTextFieldCell

@synthesize highlightedActiveEnabledAttributes;
@synthesize highlightedActiveDisabledAttributes;
@synthesize highlightedInactiveEnabledAttributes;
@synthesize highlightedInactiveDisabledAttributes;
@synthesize enabledAttributes;
@synthesize disabledAttributes;


- (id)copyWithZone:(NSZone *)zone {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	MDTextFieldCell *cell = (MDTextFieldCell *)[super copyWithZone:zone];
	cell->image = nil;
	cell->highlightedActiveEnabledAttributes = nil;
	cell->highlightedActiveDisabledAttributes = nil;
	cell->highlightedInactiveEnabledAttributes = nil;
	cell->highlightedInactiveDisabledAttributes = nil;
	cell->enabledAttributes = nil;
	cell->disabledAttributes = nil;
	
	cell.image = image;
	
	cell->highlightedActiveEnabledAttributes = [highlightedActiveEnabledAttributes mutableCopy];
	cell->highlightedActiveDisabledAttributes = [highlightedActiveDisabledAttributes mutableCopy];
	cell->highlightedInactiveEnabledAttributes = [highlightedInactiveEnabledAttributes mutableCopy];
	cell->highlightedInactiveDisabledAttributes = [highlightedInactiveDisabledAttributes mutableCopy];
	cell->enabledAttributes = [enabledAttributes mutableCopy];
	cell->disabledAttributes = [disabledAttributes mutableCopy];
//	cell.highlightedActiveEnabledAttributes = highlightedActiveEnabledAttributes;
//	cell.highlightedActiveDisabledAttributes = highlightedActiveDisabledAttributes;
//	cell.highlightedInactiveEnabledAttributes = highlightedInactiveEnabledAttributes;
//	cell.highlightedInactiveDisabledAttributes = highlightedInactiveDisabledAttributes;
//	cell.enabledAttributes = enabledAttributes;
//	cell.disabledAttributes = disabledAttributes;
	
	return cell;
}


- (void)initAttributes {
#if MD_DEBUG
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	style.lineBreakMode = NSLineBreakByTruncatingMiddle;
	style.alignment = self.alignment;
	
	
	highlightedActiveEnabledAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.font,NSFontAttributeName,
										  style,NSParagraphStyleAttributeName,
										  [NSColor alternateSelectedControlTextColor],NSForegroundColorAttributeName, nil];
	
	highlightedActiveDisabledAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.font,NSFontAttributeName,
										   style,NSParagraphStyleAttributeName,
										   [NSColor colorWithCalibratedRed:208.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0],NSForegroundColorAttributeName, nil];
	
	highlightedInactiveEnabledAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.font,NSFontAttributeName,
											style,NSParagraphStyleAttributeName,
											[NSColor controlTextColor],NSForegroundColorAttributeName, nil];
	
	highlightedInactiveDisabledAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.font,NSFontAttributeName,
											 style,NSParagraphStyleAttributeName,
											 [[NSColor controlTextColor] colorWithAlphaComponent:0.5],NSForegroundColorAttributeName, nil];
	
	enabledAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.font,NSFontAttributeName,
						 style,NSParagraphStyleAttributeName,
						 self.textColor,NSForegroundColorAttributeName, nil];
	
	disabledAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.font,NSFontAttributeName,
						  style,NSParagraphStyleAttributeName,
						  [[NSColor controlTextColor] colorWithAlphaComponent:0.5],NSForegroundColorAttributeName, nil];
	
	
	
}



- (instancetype)initTextCell:(NSString *)value {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if  ((self = [super initTextCell:value])) {
		leftEdgePadding = MD_LEFT_EDGE_PADDING;
		[self initAttributes];
	}
	return self;
}


- (instancetype)initImageCell:(NSImage *)value {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super initImageCell:value])) {
		image = value;
		leftEdgePadding = MD_LEFT_EDGE_PADDING;
		[self initAttributes];
	}
	return self;
}


- (instancetype)init {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super initTextCell:@""])) {
		leftEdgePadding = MD_LEFT_EDGE_PADDING;
	}
	return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ((self = [super initWithCoder:coder])) {
		
		leftEdgePadding = MD_LEFT_EDGE_PADDING;
		[self initAttributes];

	}
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:@((double) MD_LEFT_EDGE_PADDING) forKey:@"MDLeftEdgePadding"];
	[coder encodeObject:@(centerImageVertically) forKey:@"MDCenterImageVertically"];
}

@synthesize image;
@synthesize leftEdgePadding;
@synthesize centerImageVertically;


- (NSPoint)calculatedImagePointForFrame:(NSRect)cellFrame imageSize:(NSSize)imageSize isFlipped:(BOOL)isFlipped {
#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSPoint imagePoint = cellFrame.origin;
	imagePoint.x += leftEdgePadding;
	
	if (isFlipped) {
		if (imageSize.height == 16.0) {
			if (centerImageVertically) {
				imagePoint.y += (imageSize.height + ceil((cellFrame.size.height - imageSize.height)/2.0));
				
			} else {
				if (cellFrame.size.height >= 17.0 && cellFrame.size.height <= 18.0) {
					// in other words, if the font size is 15 pt or 16 pt
					imagePoint.y += imageSize.height;
				} else {
					imagePoint.y += (imageSize.height - 1.0);
				}
			}
		} else if (imageSize.height == 32.0) {
			imagePoint.y += imageSize.height;
		}
	} else {
		if (imageSize.height == 16.0) {
			if (cellFrame.size.height == 18.0) {
				imagePoint.y += 1.0;
			} else {
				
			}
		} else if (imageSize.height == 32.0) {

		}
	}
	return imagePoint;
}


- (NSRect)calculatedRichTextRectForFrame:(NSRect)cellFrame richText:(NSAttributedString *)richText fontSize:(CGFloat)fontSize imageSize:(NSSize)imageSize isFlipped:(BOOL)isFlipped {
#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSRect richTextRect = NSZeroRect;
	
	CGFloat fontBaselineFudge = 0.0;
	
	if (isFlipped) {
		if (fontSize >= 12.0 && fontSize <= 14.0) {
			fontBaselineFudge = -1.0;
		} else if (fontSize == 16.0) {
			fontBaselineFudge = 1.0;
		}
	} else {
		if (fontSize >= 12.0 && fontSize <= 14.0) {
			fontBaselineFudge = 1.0;
		} else if (fontSize == 16.0) {
			fontBaselineFudge = -1.0;
		}
	}
	
	CGFloat textMarginFudge = 0.0;
	CGFloat textWidthFudge = 0.0;
	
	if (image == nil) {
		if (self.alignment == NSLeftTextAlignment) {
			textMarginFudge = 15.0;
			textWidthFudge = -30.0;
		} else {
			textMarginFudge = 15.0;
			textWidthFudge = -30.0;
		}
	} else {
		if (self.alignment == NSLeftTextAlignment) {
//			textMarginFudge = 15.0;
			textWidthFudge = -15.0;
		} else {
			textMarginFudge = -15.0;
		}
	}
	
	richTextRect.size = [richText size];
	
	richTextRect.origin.x = cellFrame.origin.x + textMarginFudge;
	
	if (isFlipped) {
		richTextRect.origin.y = cellFrame.origin.y + fontBaselineFudge + floor((cellFrame.size.height - richTextRect.size.height)/2.0);
	} else {
		richTextRect.origin.y = cellFrame.origin.y - 1.0 + fontBaselineFudge + ceil((cellFrame.size.height - richTextRect.size.height)/2.0);
	}
	
	richTextRect.size.width = cellFrame.size.width + textWidthFudge;
	
	if (image) {
		richTextRect.origin.x += (leftEdgePadding + imageSize.width + MD_INTER_SPACE);
		richTextRect.size.width -= (leftEdgePadding + imageSize.width + MD_INTER_SPACE);
	}
	return richTextRect;
}


- (void)setFont:(NSFont *)fontObj {
#if MD_DEBUG
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	highlightedActiveEnabledAttributes[NSFontAttributeName] = fontObj;
	highlightedActiveDisabledAttributes[NSFontAttributeName] = fontObj;
	highlightedInactiveEnabledAttributes[NSFontAttributeName] = fontObj;
	highlightedInactiveDisabledAttributes[NSFontAttributeName] = fontObj;
	enabledAttributes[NSFontAttributeName] = fontObj;
	disabledAttributes[NSFontAttributeName] = fontObj;
	super.font = fontObj;
}



- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
#if MD_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	NSSize	imageSize = NSZeroSize;
	NSPoint	imagePoint = NSZeroPoint;
	
	if (image) {
		imageSize = image.size;
		imagePoint = [self calculatedImagePointForFrame:cellFrame imageSize:imageSize isFlipped:controlView.flipped];
	}
	
	NSDictionary *attributes = nil;
	
	BOOL isEnabled = self.enabled;
	
	if (self.highlighted) {
		
		NSImage *tempImage = image;
		id tempObject = self.objectValue;
		
		[self setImage:nil];
		self.stringValue = @"";
		
		[super drawWithFrame:cellFrame inView:controlView];
		
		self.image = tempImage;
		self.objectValue = tempObject;
		
		if (controlView.window.keyWindow) {
			attributes = (isEnabled ? highlightedActiveEnabledAttributes : highlightedActiveDisabledAttributes);
			
		} else {
			attributes = (isEnabled ? highlightedInactiveEnabledAttributes : highlightedInactiveDisabledAttributes);
		}
		
	} else {
		attributes = (isEnabled ? enabledAttributes : disabledAttributes);
	}
	
	if (image) {
		BOOL isFlipped = controlView.flipped != image.isFlipped;
		if (isFlipped) {
			NSLog(@"isFlipped");
			[[NSGraphicsContext currentContext] saveGraphicsState];
			NSAffineTransform *transform = [[NSAffineTransform alloc] init];
			[transform translateXBy:0.0 yBy:(cellFrame.origin.y + cellFrame.size.height)];
			[transform scaleXBy:0.0 yBy:-1.0];
			[transform translateXBy:0.0 yBy:-cellFrame.origin.y];
			[transform concat];
		}
		[image drawAtPoint:imagePoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:(isEnabled ? 1.0 : 0.5)];
		if (isFlipped) [[NSGraphicsContext currentContext] restoreGraphicsState];
		
//		[image compositeToPoint:imagePoint operation:NSCompositeSourceOver fraction:(isEnabled ? 1.0 : 0.5)];
	}
	
	NSAttributedString *richText = [[NSAttributedString alloc] initWithString:self.stringValue attributes:attributes];
	
	NSRect richTextRect = [self calculatedRichTextRectForFrame:cellFrame richText:richText fontSize:self.font.pointSize imageSize:imageSize isFlipped:controlView.flipped];
	
	[richText drawInRect:richTextRect];
	
//	[[NSColor greenColor] set];
//	[NSBezierPath strokeRect:richTextRect];
	
//	[self hitRectsForFrame:cellFrame isFlipped:[controlView isFlipped]];
//	
//	[[[NSColor greenColor] colorWithAlphaComponent:0.37] set];
//	
//	NSEnumerator *enumerator = [hitRects objectEnumerator];
//	NSValue *hitRectValue;
//	
//	while (hitRectValue = [enumerator nextObject]) {
//		NSRect hitRect = [hitRectValue rectValue];
//		[NSBezierPath fillRect:hitRect];
//	}
}



- (NSSize)cellSize {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	NSSize cellSize = super.cellSize;
	
	if (image == nil) {
		cellSize.width += 30.0;
	} else {
		NSSize imageSize = image.size;
		cellSize.width += (31.0 + imageSize.width + MD_INTER_SPACE);
	}
	return cellSize;
}


- (void)drawWithFrame:(NSRect)cellFrame inImage:(NSImage *)dragImage {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
#if MD_DEBUG
	[dragImage lockFocus];
//	[[[NSColor grayColor] colorWithAlphaComponent:0.37] set];
	[[[NSColor redColor] colorWithAlphaComponent:0.37] set];
	[NSBezierPath fillRect:cellFrame];
	[dragImage unlockFocus];
#endif
	
	NSSize	imageSize = NSZeroSize;
	NSPoint imagePoint = NSZeroPoint;
	
	if (image) {
		imageSize = image.size;
		imagePoint = [self calculatedImagePointForFrame:cellFrame imageSize:imageSize isFlipped:[dragImage isFlipped]];
		
		[dragImage lockFocus];
		[image compositeToPoint:imagePoint operation:NSCompositeSourceOver fraction:0.37];
		[dragImage unlockFocus];
	}
	
	NSDictionary *attributes = @{NSFontAttributeName: self.font, NSForegroundColorAttributeName: [[NSColor controlTextColor] colorWithAlphaComponent:0.37]};
	
	NSAttributedString *richText = [[NSAttributedString alloc] initWithString:self.stringValue attributes:attributes];
	
	NSRect richTextRect = [self calculatedRichTextRectForFrame:cellFrame richText:richText fontSize:self.font.pointSize imageSize:imageSize isFlipped:[dragImage isFlipped]];
	
	[dragImage lockFocus];
	[richText drawInRect:richTextRect];
	[dragImage unlockFocus];
}


	
- (NSArray *)hitRectsForFrame:(NSRect)cellFrame isFlipped:(BOOL)isFlipped {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	NSMutableArray *hitRects = [NSMutableArray array];
	
	NSSize	imageSize = NSZeroSize;
	NSPoint imagePoint = NSZeroPoint;
	NSRect	imageFrame = NSZeroRect;
	
	if (image) {
		imageSize = image.size;
		imagePoint = [self calculatedImagePointForFrame:cellFrame imageSize:imageSize isFlipped:isFlipped];
		
		imageFrame = NSMakeRect(imagePoint.x, imagePoint.y, imageSize.width, imageSize.height);
		
		[hitRects addObject:[NSValue valueWithRect:imageFrame]];
	}
	
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	style.lineBreakMode = NSLineBreakByTruncatingMiddle;
	style.alignment = self.alignment;
	
	NSDictionary *attributes = @{NSFontAttributeName: self.font, NSParagraphStyleAttributeName: style};
	
	NSAttributedString *richText = [[NSAttributedString alloc] initWithString:self.stringValue attributes:attributes];
	
	NSRect richTextRect = [self calculatedRichTextRectForFrame:cellFrame richText:richText fontSize:self.font.pointSize imageSize:imageSize isFlipped:isFlipped];
	
	[hitRects addObject:[NSValue valueWithRect:richTextRect]];
	
	return [hitRects copy];
}


@end

