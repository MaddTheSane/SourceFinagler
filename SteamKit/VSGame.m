//
//  VSGame.m
//  Source Finagler
//
//  Created by Mark Douma on 6/13/2010.
//  Copyright © 2010-2012 Mark Douma LLC. All rights reserved.
//


#import <SteamKit/VSGame.h>
#import <SteamKit/VSSteamManager.h>
#import <SteamKit/VSPrivateInterfaces.h>

#define VS_DEBUG 0

@implementation VSGame
@synthesize gameID, executableURL, icon, iconURL, displayName, infoDictionary, creatorCode, addonsFolderPath, processIdentifier;
@synthesize helped = isHelped;
@synthesize running = isRunning;

@dynamic executablePath;
@dynamic iconPath;

+ (instancetype)gameWithPath:(NSString *)aPath infoPlist:(NSDictionary *)anInfoPlist {
	return [[[self class] alloc] initWithPath:aPath infoPlist:anInfoPlist];
}

- (instancetype)initWithPath:(NSString *)aPath infoPlist:(NSDictionary *)anInfoPlist {
	if (aPath && anInfoPlist && (self = [super init])) {
		isHelped = NO;
		executableURL = [NSURL fileURLWithPath:aPath];
		creatorCode = [anInfoPlist[VSGameCreatorCodeKey] unsignedIntValue];
		infoDictionary = anInfoPlist[VSGameInfoPlistKey];
		gameID = [anInfoPlist[VSGameIDKey] unsignedIntegerValue];
		displayName = infoDictionary[(NSString *)kCFBundleNameKey];
		
		NSString *shortFolderName = anInfoPlist[VSGameShortNameKey];
		
		if (shortFolderName) {
			self.iconURL = [[[executableURL.URLByDeletingLastPathComponent
							   URLByAppendingPathComponent:shortFolderName]
							  URLByAppendingPathComponent:VSResourceNameKey]
							 URLByAppendingPathComponent:VSGameIconNameKey];
		}
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		BOOL isDir;
		
		if ([fileManager fileExistsAtPath:self.iconPath isDirectory:&isDir] && !isDir) {
			NSImage *iconImage = [[NSImage alloc] initByReferencingURL:iconURL];
			self.icon = iconImage;
		} else {
			NSLog(@"[%@ %@] file doesn't exist at iconPath == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.iconPath);
		}
		if ([anInfoPlist[VSGameSupportsAddonsKey] boolValue]) {
			NSString *addonsFolder = [[executableURL.URLByDeletingLastPathComponent
									   URLByAppendingPathComponent:shortFolderName]
									  URLByAppendingPathComponent:VSSourceAddonFolderNameKey].path;
			if ([fileManager fileExistsAtPath:addonsFolder isDirectory:&isDir] && isDir) {
				self.addonsFolderPath = addonsFolder;
			}
		}
		[self synchronizeHelped];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
#if VS_DEBUG
	NSLog(@"[%@ %@] why is this being called?", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	VSGame *copy = (VSGame *)[[[self class] allocWithZone:zone] init];
	copy.gameID = gameID;
	copy.creatorCode = creatorCode;
	copy.executableURL = executableURL;
	copy.icon = icon;
	copy.iconURL = iconURL;
	copy.displayName = displayName;
	copy.helped = isHelped;
	copy.infoDictionary = infoDictionary;
	copy.addonsFolderPath = addonsFolderPath;
	copy.running = isRunning;
	return copy;
}

- (void)synchronizeHelped {
#if VS_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	BOOL isDir;
	
	NSError *outError = nil;
	if ( !([fileManager fileExistsAtPath:executableURL.path isDirectory:&isDir] && !isDir)) {
		NSLog(@"[%@ %@] no file exists at %@!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), executableURL.path);
		return;
	}
	
	NSDictionary *attributes = [fileManager attributesOfItemAtPath:executableURL.path error:&outError];
	if (attributes == nil) {
		NSLog(@"[%@ %@] failed to get attributes of item at path == %@; error == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), executableURL.path, outError);
		return;
	}
	self.helped = ([attributes fileHFSCreatorCode] != 0);
	
}

- (NSString *)executablePath {
	return executableURL.path;
}

- (void)setExecutablePath:(NSString *)executablePath {
	self.executableURL = [NSURL fileURLWithPath:executablePath];
}

- (NSString *)iconPath {
	return iconURL.path;
}

- (void)setIconPath:(NSString *)iconPath {
	iconURL = [NSURL fileURLWithPath:iconPath];
}

- (NSString *)description {
	NSMutableString *description = [NSMutableString stringWithFormat:@"%@ -", super.description];
	
	[description appendFormat:@" %@", displayName];
//	[description appendFormat:@"gameID == %lu\n", gameID];
//	[description appendFormat:@"iconPath == %@\n", iconPath];
//	[description appendFormat:@"path == %@\n", path];
	[description appendFormat:@", isHelped == %@", (isHelped ? @"YES" : @"NO")];
	[description appendFormat:@", isRunning == %@", (isRunning ? @"YES" : @"NO")];
	return description;
}

- (BOOL)isEqual:(id)anObject {
	if (!anObject) {
		return NO;
	}
	if (![anObject isKindOfClass:[VSGame class]]) {
		return NO;
	}
	return [self isEqualToGame:anObject];
}

- (BOOL)isEqualToGame:(VSGame *)game {
#if VS_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	return (gameID == game.gameID && ([executableURL.path caseInsensitiveCompare:game.executablePath] == NSOrderedSame));
}

@end
