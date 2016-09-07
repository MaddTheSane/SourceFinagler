//
//  MDMetalBevelView.m
//  Source Finagler
//
//  Created by Mark Douma on 4/4/2006.
//  Copyright © 2007 Mark Douma. All rights reserved.
//



#import "MDMetalBevelView.h"


#define MD_DEBUG 0

@implementation MDMetalBevelView
@synthesize drawsBackground;

- (instancetype)initWithFrame:(NSRect)frame {
#if MD_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
		
	if ((self = [super initWithFrame:frame])) {
		drawsBackground = NO;
	}
    return self;
}

- (void)drawRect:(NSRect)rect {
	
//	[super drawRect:rect]; // ??
	
	[[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0] set];
	[NSBezierPath fillRect:rect];
	
	BOOL isMain = self.window.mainWindow;
	
	if (drawsBackground) {
		if (isMain) {
			[[NSColor colorWithCalibratedRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0] set];
		} else {
			[[NSColor colorWithCalibratedRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0] set];
		}
		
		[NSBezierPath setDefaultLineWidth:2.0];
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(0.0,rect.size.height) toPoint:NSMakePoint(rect.size.width, rect.size.height)];
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(0.0,0.0) toPoint:NSMakePoint(rect.size.width, 0.0)];
		
	} else {
		[super drawRect:rect];
		
	}
}

- (void)setDrawsBackground:(BOOL)value {
	drawsBackground = value;
	[self setNeedsDisplay:YES];
}

@end
