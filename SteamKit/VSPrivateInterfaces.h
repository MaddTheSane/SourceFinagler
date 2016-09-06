//
//  VSPrivateInterfaces.h
//  Source Finagler
//
//  Created by Mark Douma on 6/1/2011.
//  Copyright (c) 2011 Mark Douma LLC. All rights reserved.
//

#import <SteamKit/SteamKitDefines.h>
#import <SteamKit/VSGame.h>


@interface VSGame ()

+ (instancetype)gameWithPath:(NSString *)aPath infoPlist:(NSDictionary<NSString*,id> *)anInfoPlist;
- (instancetype)initWithPath:(NSString *)aPath infoPlist:(NSDictionary<NSString*,id> *)anInfoPlist;


- (void)synchronizeHelped;

@property (readwrite, copy) NSString *executablePath;

/* Indicates the URL to the games's executable. */
@property (readwrite, strong) NSURL *executableURL;
@property (readwrite, copy) NSString *displayName;
@property (readwrite, copy) NSString *iconPath;

/* Returns the icon of the application. */
@property (readwrite, copy) NSImage *icon;


@property (readwrite, strong) NSDictionary *infoDictionary;
@property (readwrite, copy) NSString	*addonsFolderPath;

/* Indicates the process identifier (pid) of the application.  Do not rely on this for comparing processes.  Use isEqual: instead.  Not all applications have a pid.  Applications without a pid return -1 from this method. */
@property (readwrite, assign) pid_t processIdentifier;


@property (readwrite, assign) VSGameID	gameID;
@property (readwrite, assign) OSType creatorCode;
@property (readwrite, assign, getter=isHelped) BOOL helped;
@property (readwrite, assign, getter=isRunning) BOOL running;


@end
