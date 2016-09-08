//
//  VSSteamManager.h
//  Source Finagler
//
//  Created by Mark Douma on 6/13/2010.
//  Copyright © 2010-2012 Mark Douma LLC. All rights reserved.
//


#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>
#import <SteamKit/SteamKitDefines.h>


@class NSString, NSError, NSDictionary, NSMutableDictionary, NSArray;
@class VSGame;


@protocol VSSteamManagerDelegate <NSObject>
- (void)gameDidLaunch:(VSGame *)game;
- (void)gameDidTerminate:(VSGame *)game;

@end


typedef NS_OPTIONS(NSUInteger, VSGameLaunchOptions) {
	VSGameLaunchNoOptions						= 0,
	VSGameLaunchHelpingGame						= 1 << 0,
	VSGameLaunchDefault							= VSGameLaunchHelpingGame
};

typedef NS_ENUM(NSUInteger, VSSteamAppsRelocationType) {
	VSSteamAppsUnknownRelocation	= 0,
	VSSteamAppsNoRelocation			= 1,
	VSSteamAppsSymlinkRelocation	= 2
};

typedef NS_ENUM(NSUInteger, VSSourceFinaglerLaunchAgentStatus) {
	VSSourceFinaglerLaunchAgentInstalled			= 0,
	VSSourceFinaglerLaunchAgentUpdateNeeded			= 1,
	VSSourceFinaglerLaunchAgentNotInstalled			= 2,
	VSSourceFinaglerLaunchAgentStatusUnknown		= 3
};


@interface VSSteamManager : NSObject {
	
	NSString									*defaultSteamAppsPath;
	
	NSString									*steamAppsPath;
	
	VSSteamAppsRelocationType					steamAppsRelocationType;
	
	NSDictionary								*gameBundleIdentifiersAndGames;
	NSArray										*executableNames;
	
	NSMutableDictionary							*gamePathsAndGames;
	NSMutableDictionary							*runningGamePathsAndGames;
	
	
	__unsafe_unretained id <VSSteamManagerDelegate> delegate;						// non-retained
	
	
	VSSourceFinaglerLaunchAgentStatus			sourceFinaglerLaunchAgentStatus;
	NSString									*sourceFinaglerLaunchAgentPath;
	
	
	NSTimeInterval								timeToLocateSteamApps;
	
	BOOL										monitoringGames;
}

/** Get the shared instance of VSSteamManager. This method will create an instance of \c VSSteamManager if it has not been created yet. You should not attempt to instantiate instances of \c VSSteamManager yourself, and you should not attempt to subclass <code>VSSteamManager</code>. */
+ (VSSteamManager *)defaultManager; // singleton
#if __has_feature(objc_class_property)
@property (readonly, retain) VSSteamManager *defaultManager;
#endif

@property (assign) id <VSSteamManagerDelegate> delegate;


- (NSString *)defaultSteamAppsPath;

@property (readonly, copy) NSString *defaultSteamAppsPath;
@property (readonly, copy) NSString *steamAppsPath;

@property (readonly) VSSteamAppsRelocationType steamAppsRelocationType;

- (BOOL)isProposedRelocationPathValid:(NSString *)proposedPath errorDescription:(NSString **)errorDescription;
- (BOOL)relocateSteamAppsToPath:(NSString *)aPath error:(NSError **)outError;


@property (readonly, copy) NSArray<VSGame *> *games;
@property (readonly, copy) NSArray<VSGame *> *runningGames;

- (VSGame *)gameWithPath:(NSString *)aPath;


@property (assign) BOOL monitoringGames;


+ (VSGameLaunchOptions)defaultPersistentOptions;
+ (void)setDefaultPersistentOptions:(VSGameLaunchOptions)options;
#if __has_feature(objc_class_property)
@property (class) VSGameLaunchOptions defaultPersistentOptions;
#endif

- (VSGameLaunchOptions)persistentOptionsForGame:(VSGame *)game;
- (BOOL)setPersistentOptions:(VSGameLaunchOptions)options forGame:(VSGame *)game error:(NSError **)outError;


- (BOOL)helpGame:(VSGame *)game forUSBOverdrive:(BOOL)yorn updateLaunchAgent:(BOOL)updateLaunchAgent error:(NSError **)outError;
- (BOOL)unhelpGame:(VSGame *)game error:(NSError **)outError;

- (BOOL)launchGame:(VSGame *)game options:(VSGameLaunchOptions)options error:(NSError **)outError;

@property (readonly) VSSourceFinaglerLaunchAgentStatus sourceFinaglerLaunchAgentStatus;

@property (readonly, copy) NSString *sourceFinaglerLaunchAgentPath;

- (BOOL)installSourceFinaglerLaunchAgentWithError:(NSError **)outError;
- (BOOL)updateSourceFinaglerLaunchAgentWithError:(NSError **)outError;
- (BOOL)uninstallSourceFinaglerLaunchAgentWithError:(NSError **)outError;

@end

typedef NS_ENUM(NSUInteger, VSSourceAddonInstallMethod) {
	VSSourceAddonInstallByMoving	= 1,
	VSSourceAddonInstallByCopying	= 2
};

NS_ENUM(NSInteger) {
	VSSourceAddonNotAValidAddonFileError				= 6000,
	VSSourceAddonSourceFileIsDestinationFileError		= 6001,
	VSSourceAddonNoAddonInfoFoundError					= 6002,
	VSSourceAddonAddonInfoUnreadableError				= 6003,
	VSSourceAddonNoGameIDFoundInAddonInfoError			= 6004,
	VSSourceAddonGameNotFoundError						= 6005
};

@interface VSSteamManager (VSAddonsSupport)

- (BOOL)installAddonAtPath:(NSString *)sourceFilePath method:(VSSourceAddonInstallMethod)installMethod resultingPath:(NSString **)resultingPath resultingGame:(VSGame **)resultingGame overwrite:(BOOL)overwriteExisting error:(NSError **)outError;

@end



@interface VSSteamManager (VSOtherAppsHelperAdditions)

// force a refresh
- (void)locateSteamApps;

@end


STEAMKIT_EXTERN NSString * const VSGameIDKey;
STEAMKIT_EXTERN NSString * const VSGameSupportsAddonsKey;
STEAMKIT_EXTERN NSString * const VSGameNameKey;
STEAMKIT_EXTERN NSString * const VSGameShortNameKey;
STEAMKIT_EXTERN NSString * const VSGameLongNameKey;
STEAMKIT_EXTERN NSString * const VSGameCreatorCodeKey;
STEAMKIT_EXTERN NSString * const VSGameBundleIdentifierKey;
STEAMKIT_EXTERN NSString * const VSGameInfoPlistKey;


STEAMKIT_EXTERN NSString * const VSResourceNameKey;
STEAMKIT_EXTERN NSString * const VSGameIconNameKey;

STEAMKIT_EXTERN NSString * const VSSteamAppsDirectoryNameKey;


STEAMKIT_EXTERN NSString * const VSSourceAddonErrorDomain;

STEAMKIT_EXTERN NSString * const VSSourceAddonGameIDKey;



STEAMKIT_EXTERN NSString * const VSSourceAddonFolderNameKey;

// SourceFinaglerAgent


