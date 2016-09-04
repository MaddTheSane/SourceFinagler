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

@synthesize gameID, executablePath, icon, iconPath, displayName, infoDictionary, creatorCode, addonsFolderPath, processIdentifier;
@synthesize helped = isHelped;
@synthesize running = isRunning;

@dynamic executableURL;

+ (instancetype)gameWithPath:(NSString *)aPath infoPlist:(NSDictionary *)anInfoPlist {
	return [[[[self class] alloc] initWithPath:aPath infoPlist:anInfoPlist] autorelease];
}


- (instancetype)initWithPath:(NSString *)aPath infoPlist:(NSDictionary *)anInfoPlist {
	if (aPath && anInfoPlist && (self = [super init])) {
		isHelped = NO;
		executablePath = [aPath retain];
		creatorCode = [anInfoPlist[VSGameCreatorCodeKey] unsignedIntValue];
		infoDictionary = [anInfoPlist[VSGameInfoPlistKey] retain];
		gameID = [anInfoPlist[VSGameIDKey] unsignedIntegerValue];
		displayName = [infoDictionary[(NSString *)kCFBundleNameKey] retain];
		
		NSString *shortFolderName = anInfoPlist[VSGameShortNameKey];
		
		if (shortFolderName) {
			self.iconPath = [[[executablePath.stringByDeletingLastPathComponent
								 stringByAppendingPathComponent:shortFolderName]
								stringByAppendingPathComponent:VSResourceNameKey]
							   stringByAppendingPathComponent:VSGameIconNameKey];
		}
		NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
		BOOL isDir;
		
		if ([fileManager fileExistsAtPath:iconPath isDirectory:&isDir] && !isDir) {
			NSImage *iconImage = [[[NSImage alloc] initByReferencingFile:iconPath] autorelease];
			self.icon = iconImage;
		} else {
			NSLog(@"[%@ %@] file doesn't exist at iconPath == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), iconPath);
		}
		if ([anInfoPlist[VSGameSupportsAddonsKey] boolValue]) {
			NSString *addonsFolder = [[executablePath.stringByDeletingLastPathComponent
									   stringByAppendingPathComponent:shortFolderName]
									  stringByAppendingPathComponent:VSSourceAddonFolderNameKey];
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
	copy.executablePath = executablePath;
	copy.icon = icon;
	copy.iconPath = iconPath;
	copy.displayName = displayName;
	copy.helped = isHelped;
	copy.infoDictionary = infoDictionary;
	copy.addonsFolderPath = addonsFolderPath;
	copy.running = isRunning;
	return copy;
}



- (void)dealloc {
	[executablePath release];
	[icon release];
	[iconPath release];
	[displayName release];
	[infoDictionary release];
	[addonsFolderPath release];
	[super dealloc];
}


- (void)synchronizeHelped {
#if VS_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	BOOL isDir;
	
	NSError *outError = nil;
	if ( !([fileManager fileExistsAtPath:executablePath isDirectory:&isDir] && !isDir)) {
		NSLog(@"[%@ %@] no file exists at %@!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), executablePath);
		[fileManager release];
		return;
	}
	
	NSDictionary *attributes = [fileManager attributesOfItemAtPath:executablePath error:&outError];
	if (attributes == nil) {
		NSLog(@"[%@ %@] failed to get attributes of item at path == %@; error == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), executablePath, outError);
		[fileManager release];
		return;
	}
	self.helped = ([attributes fileHFSCreatorCode] != 0);
	
	[fileManager release];
}

- (NSURL *)executableURL {
	return [NSURL fileURLWithPath:executablePath];
}

- (void)setExecutableURL:(NSURL *)aURL {
	
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
	return [self isEqualToGame:anObject];
}


- (BOOL)isEqualToGame:(VSGame *)game {
#if VS_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if ([game isKindOfClass:[self class]]) {
		return (gameID == game.gameID && ([executablePath isEqualToString:game.executablePath] || [executablePath.lowercaseString isEqualToString:game.executablePath.lowercaseString]));
	}
	return NO;
}



@end

