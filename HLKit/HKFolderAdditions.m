//
//  HKFolderAdditions.m
//  Source Finagler
//
//  Created by Mark Douma on 9/30/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import <HLKit/HKFolderAdditions.h>
#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@implementation HKFolder (MDAdditions)

- (NSImage *)image {
	NSImage *image = [HKItem copiedImageForItem:self];
	[image setSize:NSMakeSize(128.0, 128.0)];
	return image;
}

- (QTMovie *)movie {
	return nil;
}


@end
