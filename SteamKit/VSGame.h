//
//  VSGame.h
//  Source Finagler
//
//  Created by Mark Douma on 6/13/2010.
//  Copyright © 2010-2012 Mark Douma LLC. All rights reserved.
//


#include <sys/types.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSDictionary.h>
#import <AppKit/NSImage.h>


typedef NSUInteger VSGameID;


@interface VSGame : NSObject <NSCopying>

/** Indicates the path to the game's executable. */
@property (readonly, copy) NSString *executablePath;

/** Indicates the URL to the game's executable. */
@property (readonly, strong) NSURL *executableURL;

/** Indicates the name of the game, suitable for presentation to the user. */
@property (readonly, copy) NSString *displayName;

/** Returns the icon of the game. */
@property (readonly, copy) NSImage *icon;

/** Returns the path to the icon of the game. */
@property (readonly, copy) NSString *iconPath;

/** A dictionary, constructed from the game's Info.plist file, that contains information about the game */
@property (readonly, strong) NSDictionary<NSString*,id> *infoDictionary;

/** The path to the game's addons directory, or nil if the game doesn't support addons. */
@property (readonly, copy) NSString *addonsFolderPath;

@property (readonly) VSGameID gameID;

@property (readonly) OSType creatorCode;

/** Indicates whether the game is currently helped. This is observable through KVO. */
@property (readonly, getter=isHelped) BOOL helped;

/** Indicates whether the game is currently running. This is observable through KVO. */
@property (readonly, getter=isRunning) BOOL running;

/** Indicates the process identifier (pid) of the game. Do not rely on this for comparing processes. Use isEqual: instead. Not all games have a pid. Games without a pid return -1 from this method. */
@property (readonly) pid_t processIdentifier;

- (BOOL)isEqual:(id)anObject;
- (BOOL)isEqualToGame:(VSGame *)game;

@end
