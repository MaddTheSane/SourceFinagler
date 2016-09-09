//
//  MDImageView.m
//  Source Finagler
//
//  Created by Mark Douma on 10/10/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import "MDImageView.h"


@implementation MDImageView

@synthesize image;

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
    }
    return self;
}

- (void)dealloc {
	[image release];
	[super dealloc];
}


- (void)awakeFromNib {
	[self setImage:[NSImage imageNamed:@"sound"]];
}

- (BOOL)isOpaque {
	return NO;
}

- (void)setImage:(NSImage *)anImage {
	[anImage retain];
	[image release];
	image = anImage;
	[self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
	if (image == nil) {
		return [super drawRect:dirtyRect];
	}
	NSRect frame = [self frame];
	[image setSize:NSMakeSize(frame.size.width, frame.size.height)];
    [image drawAtPoint:NSMakePoint(0.0, 0.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

@end
