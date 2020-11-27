//
//  VSSourceAddon.m
//  Source Finagler
//
//  Created by Mark Douma on 11/15/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import "VSSourceAddon.h"
#import <SteamKit/SteamKit.h>


@implementation VSSourceAddon

@synthesize path, fileName, fileIcon, gameName, gameIcon, problem;

+ (id)sourceAddonWithPath:(NSString *)aPath game:(VSGame *)aGame error:(NSError *)inError {
	return [[[self class] alloc] initWithPath:aPath game:aGame error:inError];
}

- (id)initWithPath:(NSString *)aPath game:(VSGame *)game error:(NSError *)inError {
	if ((self = [super init])) {
		path = [aPath copy];
		fileName = [path lastPathComponent];
		
		NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
		if (icon) [icon setSize:NSMakeSize(16.0, 16.0)];
		[self setFileIcon:icon];
		
		if (game) {
			if ([game displayName]) {
				[self setGameName:[game displayName]];
			}
			NSImage *icon = [game icon];
			if (icon) [icon setSize:NSMakeSize(16.0, 16.0)];
			[self setGameIcon:icon];
		}
		
		if (inError) {
//			NSString *domain = [inError domain];
			NSInteger errorCode = [inError code];
			
			switch (errorCode) {
				case VSSourceAddonErrorNotAValidAddonFile : {
					[self setProblem:NSLocalizedString(@"Not a valid Source addon file", @"")];
					break;
				}
					
				case VSSourceAddonErrorSourceFileIsDestinationFile : {
					[self setProblem:NSLocalizedString(@"This addon file is already installed", @"")];
					break;
				}
					
				case VSSourceAddonErrorNoAddonInfoFound : {
					[self setProblem:NSLocalizedString(@"No addoninfo.txt file could be found inside the Source addon file", @"")];
					break;
				}
					
				case VSSourceAddonErrorAddonInfoUnreadable : {
					[self setProblem:NSLocalizedString(@"Couldn't read the addoninfo.txt file inside the Source addon file", @"")];
					break;
				}
					
				case VSSourceAddonErrorNoGameIDFoundInAddonInfo : {
					[self setProblem:NSLocalizedString(@"Didn't find a valid game ID in the addoninfo.txt file inside the Source addon file", @"")];
					break;
				}
					
				case VSSourceAddonErrorGameNotFound : {
					NSInteger gameID = [[[inError userInfo] objectForKey:VSSourceAddonGameIDKey] integerValue];
					[self setProblem:[NSString stringWithFormat:NSLocalizedString(@"Could not locate installed game for Steam Game ID %ld", @""), gameID]];
					break;
				}
					
				default:
					[self setProblem:NSLocalizedString(@"Unknown error", @"")];
					break;
			}
		}
		
	}
	return self;
}


@end
