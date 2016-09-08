//
//  VSGameAdditions.m
//  Source Finagler
//
//  Created by Mark Douma on 5/29/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import "VSGameAdditions.h"


@implementation VSGame (VSAdditions)

- (NSString *)helpedStateString {
	return (self.helped ? @"Helped" : @"Not helped");
}

- (NSColor *)helpedStateColor {
	if (self.helped) {
		return [NSColor controlTextColor];
	}
	return [NSColor colorWithCalibratedRed:183.0/255.0 green:130.0/255.0 blue:0.0/255.0 alpha:1.0];
}

- (NSImage *)runningStateImage {
	if (self.running)
		return [NSImage imageNamed:NSImageNameStatusAvailable];
	return nil;
}

+ (NSSet *)keyPathsForValuesAffectingRunningStateImage {
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	return [NSSet setWithObjects:@"running", nil];
}

@end
