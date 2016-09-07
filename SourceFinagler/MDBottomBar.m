//
//  MDBottomBar.m
//  Source Finagler
//
//  Created by Mark Douma on 10/29/2008.
//  Copyright 2008 Mark Douma. All rights reserved.
//

#include <math.h>
#include <tgmath.h>
#import "MDBottomBar.h"
#import "MDFileSizeFormatter.h"

#define MD_DISABLED_OPACITY 0.1

#pragma mark view
#define MD_DEBUG 0


@implementation MDBottomBar

- (instancetype)initWithFrame:(NSRect)frame {
	if ((self = [super initWithFrame:frame])) {
		formatter = [[MDFileSizeFormatter alloc] init];
	}
	return self;
}

- (void)setSelectedIndexes:(NSIndexSet *)anIndexSet totalCount:(NSNumber *)aTotalCount freeSpace:(NSNumber *)aFreeSpace {
#if MD_DEBUG
	NSLog(@" \"%@\" [%@ %@]", [[[[self window] windowController] document] displayName], NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	selectedIndexes = anIndexSet;
	totalCount = aTotalCount;
	freeSpace = aFreeSpace;
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
	
	BOOL isMainWindow = self.window.mainWindow;
	
//	BOOL debug = YES;
//	
//	if (debug) {
//		[[NSColor redColor] set];
//		[NSBezierPath fillRect:rect];
//	}
	
	
	NSString *stringValue = nil;
	
	if (selectedIndexes.count == 0) {
		if (totalCount.unsignedIntegerValue == 0 || totalCount.unsignedIntegerValue >= 2) {
			
			stringValue = [NSString stringWithFormat:NSLocalizedString(@"%@ items, %@ available", @""), totalCount, [formatter stringForObjectValue:freeSpace]];
			
		} else if (totalCount.unsignedIntegerValue == 1) {
			
			stringValue = [NSString stringWithFormat:NSLocalizedString(@"%@ item, %@ available", @""), totalCount, [formatter stringForObjectValue:freeSpace]];
		}
	} else if (selectedIndexes.count == 1) {
		
		stringValue = [NSString stringWithFormat:NSLocalizedString(@"%lu(single) of %@ selected, %@ available", @"String for when only 1 item is selected"), (unsigned long)selectedIndexes.count, totalCount, [formatter stringForObjectValue:freeSpace]];
		
	} else if (selectedIndexes.count >= 2) {
		
		stringValue = [NSString stringWithFormat:NSLocalizedString(@"%lu(multiple) of %@ selected, %@ available", @"String for when more than one item is selected"), (unsigned long)selectedIndexes.count, totalCount, [formatter stringForObjectValue:freeSpace]];
	}

	
	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	style.lineBreakMode = NSLineBreakByTruncatingMiddle;
	
	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowOffset = NSMakeSize(0.0, -1.0);
	
	shadow.shadowColor = [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.41];
	
	NSColor *textColor = nil;
	
	if (isMainWindow) {
		textColor = [NSColor controlTextColor];
	} else {
		textColor = [NSColor disabledControlTextColor];
	}
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]],NSFontAttributeName, style,NSParagraphStyleAttributeName, shadow,NSShadowAttributeName, textColor,NSForegroundColorAttributeName, nil];
	
	NSAttributedString *richText = [[NSAttributedString alloc] initWithString:stringValue attributes:attributes];
	
	NSRect richTextRect = NSZeroRect;
	
	richTextRect.size = [richText size];
	richTextRect.origin.x = ceil( (rect.size.width - richTextRect.size.width)/2.0);
	
	richTextRect.origin.y = ceil( (rect.size.height - richTextRect.size.height)/2.0);
	
	[richText drawInRect:richTextRect];
	
}

@end
