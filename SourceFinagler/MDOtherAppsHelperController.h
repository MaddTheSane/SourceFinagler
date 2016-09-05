//
//  MDMouseAppHelperController.h
//  Source Finagler
//
//  Created by Mark Douma on 6/13/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

//#if TARGET_CPU_X86 || TARGET_CPU_X86_64

#import "TKViewController.h"
#import <SteamKit/SteamKit.h>

@class MDTableView;


typedef NS_OPTIONS(NSUInteger, MDMouseSoftware) {
	MDMouseSoftwareNone			= 0,
	MDMouseSoftwareUSBOverdrive	= 1 << 1,
	MDMouseSoftwareSteerMouse	= 1 << 2,
	MDMouseSoftwareLogitech		= 1 << 3
};


@interface MDOtherAppsHelperController : TKViewController <NSTableViewDelegate, VSSteamManagerDelegate> {
	IBOutlet NSArrayController	*gamesController;
	IBOutlet NSButton			*helpButton;
	IBOutlet MDTableView		*tableView;
	
	IBOutlet NSView				*usbOverdriveView;
	IBOutlet NSButton			*usbOverdriveIconButton;
	
	IBOutlet NSWindow			*usbOverdriveWindow;
	
	
	NSMutableArray<VSGame*>		*games;
	
	VSSteamManager				*steamManager;
	
	MDMouseSoftware				mouseSoftware;
	
	BOOL						enableSourceFinaglerAgent;
}


@property (readonly, copy) NSArray<VSGame*> *games;
@property (readonly) NSUInteger countOfGames;
- (VSGame*)objectInGamesAtIndex:(NSUInteger)theIndex;

- (IBAction)showUSBOverdriveTip:(id)sender;
- (IBAction)ok:(id)sender;


- (IBAction)helpApps:(id)sender;
- (IBAction)restoreToDefault:(id)sender;

- (IBAction)toggleHelpApps:(id)sender;

@property (assign) BOOL enableSourceFinaglerAgent;

@property (copy) NSArray<NSSortDescriptor*> *sortDescriptors;


- (IBAction)toggleEnableAgent:(id)sender;

- (IBAction)refresh:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)launchGame:(id)sender;

@end

//#endif
