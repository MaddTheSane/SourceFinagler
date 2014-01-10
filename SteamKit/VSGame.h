//
//  VSGame.h
//  Steam Kit
//
//  Created by Mark Douma on 6/13/2010.
//  Copyright © 2010-2014 Mark Douma LLC. All rights reserved.
//


#import <Foundation/NSObject.h>
#import <SteamKit/SteamKitDefines.h>


@class NSImage, NSString, NSURL, NSDictionary;


typedef NSUInteger VSGameID;


STEAMKIT_EXTERN NSString * const VSGameIDKey;
STEAMKIT_EXTERN NSString * const VSGameNameKey;
STEAMKIT_EXTERN NSString * const VSGameShortNameKey;
STEAMKIT_EXTERN NSString * const VSGameLongNameKey;

STEAMKIT_EXTERN NSString * const VSGameIconNameKey;



@interface VSGame : NSObject <NSCopying> {
	
@private
	NSURL					*executableURL;
	
	NSString				*displayName;
	
	NSImage					*icon;
	
	NSURL					*iconURL;
	
	NSDictionary			*infoDictionary;
	
	NSURL					*appManifestURL;
	
	NSURL					*sourceAddonsFolderURL;
	
	pid_t					processIdentifier;
	
	VSGameID				gameID;
	
	OSType					creatorCode;
	
	BOOL					helped;
	
	BOOL					running;
	
	
}


/* Indicates the URL to the game's executable. */
@property (readonly, retain) NSURL *executableURL;

/* Indicates the name of the game, suitable for presentation to the user. */
@property (readonly, retain) NSString *displayName;

/* Returns the icon of the game. */
@property (readonly, retain) NSImage *icon;

/* Returns the URL to the icon of the game. */
@property (readonly, retain) NSURL *iconURL;

/* A dictionary, constructed from the game's Info.plist file, that contains information about the game */
@property (readonly, retain) NSDictionary *infoDictionary;

/* The URL to the game's addons directory, or nil if the game doesn't support addons. */
@property (readonly, retain) NSURL *sourceAddonsFolderURL;

@property (readonly, assign) VSGameID gameID;

@property (readonly, assign) OSType creatorCode;

/* Indicates whether the game is currently helped. This is observable through KVO. */
@property (readonly, assign, getter=isHelped) BOOL helped;

/* Indicates whether the game is currently running. This is observable through KVO. */
@property (readonly, assign, getter=isRunning) BOOL running;

/* Indicates the process identifier (pid) of the game. Do not rely on this for comparing processes. Use isEqual: instead. Not all games have a pid. Games without a pid return -1 from this method. */
@property (readonly, assign) pid_t processIdentifier;


@property (readonly, assign) BOOL hasUpgradedLocation;


- (BOOL)isEqual:(id)anObject;
- (BOOL)isEqualToGame:(VSGame *)game;

@end


