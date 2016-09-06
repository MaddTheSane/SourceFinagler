//
//  MDSteamAppsRelocatorController.m
//  Source Finagler
//
//  Created by Mark Douma on 6/13/2010.
//  Copyright 2010 Mark Douma LLC. All rights reserved.
//

//#if TARGET_CPU_X86 || TARGET_CPU_X86_64

#import "MDSteamAppsRelocatorController.h"
#import "TKAppKitAdditions.h"
//#import "MDFolderManager.h"
#import "MDFolderManager.h"
#import "VSSteamManager.h"
#import "MDProcessManager.h"


#define VS_DEBUG 1


// default "SteamApps" path is now
/*		/Users/~/Library/Application Support/Steam/SteamApps/			*/


NSString * const MDSteamBundleIdentifierKey = @"com.valvesoftware.steam";


@implementation MDSteamAppsRelocatorController
@synthesize currentURL;
@synthesize proposedNewPath;
@synthesize canCreate;
@synthesize steamIsRunning;
@synthesize steamDidLaunch;


- (instancetype)init {
	if ((self = [super init])) {
		steamManager = [VSSteamManager defaultManager];
		
		NSString *currentPath = steamManager.steamAppsPath;
		
		if (currentPath) {
			self.currentURL = [NSURL fileURLWithPath:currentPath];
		} 
		
		self.steamIsRunning = MDInfoForProcessWithBundleIdentifier(MDSteamBundleIdentifierKey) != nil;
		
		[[NSWorkspace sharedWorkspace].notificationCenter addObserver:self selector:@selector(applicationDidLaunch:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
		[[NSWorkspace sharedWorkspace].notificationCenter addObserver:self selector:@selector(applicationDidTerminate:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSWorkspace sharedWorkspace].notificationCenter removeObserver:self];
}

- (NSString *)title {
	return NSLocalizedString(@"Steam Apps Re-locator", @"");
}

- (NSString *)viewSizeAutosaveName {
	return @"steamAppsRelocatorView";
}

- (void)awakeFromNib {
#if VS_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	minWinSize = [TKViewController windowSizeForViewWithSize:self.view.frame.size];
	maxWinSize = NSMakeSize(FLT_MAX, minWinSize.height);
	
	if (steamIsRunning) {
		[statusField setStringValue:NSLocalizedString(@"Steam cannot be running", @"")];
	}
}

- (void)applicationDidLaunch:(NSNotification *)notification {
#if VS_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSDictionary *userInfo = notification.userInfo;
	if ([userInfo[@"NSApplicationBundleIdentifier"] isEqualToString:MDSteamBundleIdentifierKey]) {
		[self setSteamIsRunning:YES];
		[statusField setStringValue:NSLocalizedString(@"Steam cannot be running", @"")];
		
		if (currentURL == nil) {
			steamDidLaunch = YES;
			[self performSelector:@selector(updateSteamPath:) withObject:nil afterDelay:5.0];
		}
	}
}

- (void)updateSteamPath:(id)sender {
#if VS_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (steamDidLaunch) {
		NSString *currentPath = steamManager.steamAppsPath;
		if (currentPath) {
			self.currentURL = [NSURL fileURLWithPath:currentPath];
			steamDidLaunch = NO;
		} else {
			[self performSelector:@selector(updateSteamPath:) withObject:nil afterDelay:5.0];
		}
	}
}

- (void)applicationDidTerminate:(NSNotification *)notification {
#if VS_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSDictionary *userInfo = notification.userInfo;
	if ([userInfo[@"NSApplicationBundleIdentifier"] isEqualToString:MDSteamBundleIdentifierKey]) {
		[self setSteamIsRunning:NO];
		statusField.stringValue = @"";
	}
}

- (IBAction)quitSteam:(id)sender {
#if VS_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSDictionary *errorMessage = nil;
	NSAppleEventDescriptor *result = nil;
	
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell app \"Steam\" to quit"];
	if (script) {
		result = [script executeAndReturnError:&errorMessage];
		if (errorMessage) {
			NSLog(@"%@, result == %@", errorMessage, result);
		}
	}
}


//- (void)appControllerDidLoadNib:(id)sender {
//#if VS_DEBUG
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//#endif
//	NSUserDefaults *uD = [NSUserDefaults standardUserDefaults];
//	if ([uD objectForKey:MDSteamAppsRelocatorViewSizeKey] == nil) [uD setObject:[self.view stringWithSavedFrame] forKey:MDSteamAppsRelocatorViewSizeKey];
//	[self.view setFrameFromString:[uD objectForKey:MDSteamAppsRelocatorViewSizeKey]];
//	[super appControllerDidLoadNib:self];
//}


//- (void)cleanup {
//	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//	[[NSUserDefaults standardUserDefaults] setObject:[self.view stringWithSavedFrame] forKey:MDSteamAppsRelocatorViewSizeKey];
//}


- (void)controlTextDidChange:(NSNotification *)notification {
//	NSLog(@"[%@ %@] newPath == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), newPath);
	self.proposedNewPath = newPathField.stringValue.stringByStandardizingPath;
	
	NSString *status = nil;
	
	BOOL isValid = [steamManager isProposedRelocationPathValid:proposedNewPath errorDescription:&status];
	
	self.canCreate = isValid;
	if (status) {
		statusField.stringValue = status;
	}
}

- (IBAction)revealInFinder:(id)sender {
#if VS_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (currentURL) {
		[[NSWorkspace sharedWorkspace] revealInFinder:@[currentURL.path]];
	}
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename {
#if VS_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	if (currentURL) {
		if ([filename isEqualToString:currentURL.path]) {
			NSLog(@"returning no");
			return NO;
		}
	}
	
	if ([filename isEqualToString:[steamManager defaultSteamAppsPath]]) {
		return NO;
	}
	return YES;
}


- (IBAction)browse:(id)sender {
#if VS_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanelWithTitle:[NSString stringWithFormat:@"Locate %@", VSSteamAppsDirectoryNameKey]
													 message:[NSString stringWithFormat:@"Locate the copy of your “%@” folder you created in Step 2.", VSSteamAppsDirectoryNameKey]
										   actionButtonTitle:@"Open"
									 allowsMultipleSelection:NO
										canChooseDirectories:YES
													delegate:self];
	[openPanel setResolvesAliases:NO];
	
	NSInteger result = [openPanel runModal];
	
	if (result == NSFileHandlingPanelOKButton) {
		NSArray *fileURLs = openPanel.URLs;
		if (fileURLs && fileURLs.count) {
			NSString *filePath = [fileURLs[0] path];
			self.proposedNewPath = filePath;
		}
		
		NSString *status = nil;
		
		BOOL isValid = [steamManager isProposedRelocationPathValid:proposedNewPath errorDescription:&status];
		
		self.canCreate = isValid;
		if (status) {
			statusField.stringValue = status;
		}
	}
	
//	NSInteger result = [openPanel runModalForDirectory:nil file:nil types:nil];
}


- (IBAction)createSteamAppsShortcut:(id)sender {
#if VS_DEBUG
	NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
	NSError *error = nil;
	if ([steamManager relocateSteamAppsToPath:proposedNewPath error:&error]) {
		statusField.stringValue = @"Success";
		[self setCanCreate:NO];
		self.currentURL = [NSURL fileURLWithPath:proposedNewPath];
		[statusField performSelector:@selector(setStringValue:) withObject:@"" afterDelay:10.0];
		
	} else {
		NSLog(@"[%@ %@] error == %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
		
	}
}

@end
//#endif
