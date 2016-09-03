//
//  VSGameAdditions.h
//  Source Finagler
//
//  Created by Mark Douma on 5/29/2011.
//  Copyright 2011 Mark Douma LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SteamKit/SteamKit.h>

@interface VSGame (VSAdditions)

@property (readonly, copy) NSString *helpedStateString;
@property (readonly, copy) NSColor *helpedStateColor;

@property (readonly, copy) NSImage *runningStateImage;


@end
