//
//  MDSteamAppsRelocatorController.h
//  Source Finagler
//
//  Created by Mark Douma on 6/13/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

#import "TKViewController.h"

@class VSSteamManager;

@interface MDSteamAppsRelocatorController : TKViewController <NSOpenSavePanelDelegate> {
	
	IBOutlet NSTextField		*statusField;
	IBOutlet NSTextField		*newPathField;
	
	NSURL						*currentURL;
	NSString					*proposedNewPath;
	
	VSSteamManager				*steamManager;
	BOOL						canCreate;
	BOOL						steamIsRunning;
	BOOL						steamDidLaunch;
}

@property (nonatomic, assign) BOOL canCreate;
@property (nonatomic, strong) NSURL *currentURL;
@property (nonatomic, strong) NSString *proposedNewPath;
@property (nonatomic, assign) BOOL steamIsRunning;
@property (nonatomic, assign) BOOL steamDidLaunch;

- (IBAction)browse:(id)sender;
- (IBAction)createSteamAppsShortcut:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)quitSteam:(id)sender;

@end
